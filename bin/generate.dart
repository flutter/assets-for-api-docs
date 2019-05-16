// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:args/args.dart';
import 'package:animation_metadata/animation_metadata.dart';
import 'package:path/path.dart' as path;
import 'package:platform/platform.dart' as platform_pkg;
import 'package:process/process.dart';

final String repoRoot = path.dirname(path.fromUri(Platform.script));

/// Exception class for when a process fails to run, so we can catch
/// it and provide something more readable than a stack trace.
class ProcessRunnerException implements Exception {
  ProcessRunnerException(this.message, [this.result]);

  final String message;
  final ProcessResult result;
  int get exitCode => result?.exitCode ?? -1;

  @override
  String toString() {
    String output = runtimeType.toString();
    if (message != null) {
      output += ': $message';
    }
    final String stderr = result?.stderr ?? '';
    if (stderr.isNotEmpty) {
      output += ':\n$stderr';
    }
    return output;
  }
}

/// A helper class for classes that want to run a process, optionally have the
/// stderr and stdout reported as the process runs, and capture the stdout
/// properly without dropping any.
class ProcessRunner {
  ProcessRunner({
    ProcessManager processManager,
    this.defaultWorkingDirectory,
    this.platform: const platform_pkg.LocalPlatform(),
  }) : processManager = processManager ?? const LocalProcessManager() {
    environment = new Map<String, String>.from(platform.environment);
  }

  /// The platform to use for a starting environment.
  final platform_pkg.Platform platform;

  /// Set the [processManager] in order to inject a test instance to perform
  /// testing.
  final ProcessManager processManager;

  /// Sets the default directory used when `workingDirectory` is not specified
  /// to [runProcess].
  final Directory defaultWorkingDirectory;

  /// The environment to run processes with.
  Map<String, String> environment;

  /// Run the command and arguments in `commandLine` as a sub-process from
  /// `workingDirectory` if set, or the [defaultWorkingDirectory] if not. Uses
  /// [Directory.current] if [defaultWorkingDirectory] is not set.
  ///
  /// Set `failOk` if [runProcess] should not throw an exception when the
  /// command completes with a a non-zero exit code.
  Future<List<int>> runProcess(
    List<String> commandLine, {
    Directory workingDirectory,
    bool printOutput: true,
    bool failOk: false,
    Stream<List<int>> stdin,
  }) async {
    workingDirectory ??= defaultWorkingDirectory ?? Directory.current;
    if (printOutput) {
      stderr.write('Running "${commandLine.join(' ')}" in ${workingDirectory.path}.\n');
    }
    final List<int> output = <int>[];
    final Completer<Null> stdoutComplete = new Completer<Null>();
    final Completer<Null> stderrComplete = new Completer<Null>();
    final Completer<Null> stdinComplete = new Completer<Null>();

    Process process;
    Future<int> allComplete() async {
      if (stdin != null) {
        await stdinComplete.future;
        await process.stdin.close();
      }
      await stderrComplete.future;
      await stdoutComplete.future;
      return process.exitCode;
    }

    try {
      process = await processManager.start(
        commandLine,
        workingDirectory: workingDirectory.absolute.path,
        environment: environment,
      );
      if (stdin != null) {
        stdin.listen((List<int> data) {
          process.stdin.add(data);
        }, onDone: () async => stdinComplete.complete());
      }
      process.stdout.listen(
        (List<int> event) {
          output.addAll(event);
          if (printOutput) {
            stdout.add(event);
          }
        },
        onDone: () async => stdoutComplete.complete(),
      );
      if (printOutput) {
        process.stderr.listen(
          (List<int> event) {
            stderr.add(event);
          },
          onDone: () async => stderrComplete.complete(),
        );
      } else {
        stderrComplete.complete();
      }
    } on ProcessException catch (e) {
      final String message = 'Running "${commandLine.join(' ')}" in ${workingDirectory.path} '
          'failed with:\n${e.toString()}';
      throw new ProcessRunnerException(message);
    } on ArgumentError catch (e) {
      final String message = 'Running "${commandLine.join(' ')}" in ${workingDirectory.path} '
          'failed with:\n${e.toString()}';
      throw new ProcessRunnerException(message);
    }

    final int exitCode = await allComplete();
    if (exitCode != 0 && !failOk) {
      final String message = 'Running "${commandLine.join(' ')}" in ${workingDirectory.path} failed';
      throw new ProcessRunnerException(
        message,
        new ProcessResult(0, exitCode, null, 'returned $exitCode'),
      );
    }
    return output;
  }
}

class WorkerJob {
  WorkerJob(
    this.args, {
    this.workingDirectory,
    bool printOutput,
  }) : printOutput = printOutput ?? false;

  /// The arguments for the process, including the command name as args[0].
  final List<String> args;

  /// The working directory that the command should be executed in.
  final Directory workingDirectory;

  /// Whether or not this command should print it's stdout when it runs.
  final bool printOutput;

  @override
  String toString() {
    return args.join(' ');
  }
}

/// A pool of worker processes that will keep [numWorkers] busy until all of the
/// (presumably single-threaded) processes are finished.
class ProcessPool {
  ProcessPool({this.numWorkers, this.processManager}) {
    numWorkers ??= Platform.numberOfProcessors;
    processManager ??= const LocalProcessManager();
    processRunner ??= new ProcessRunner(processManager: processManager);
  }

  ProcessManager processManager;
  ProcessRunner processRunner;
  int numWorkers;
  List<WorkerJob> pendingJobs = <WorkerJob>[];
  List<WorkerJob> failedJobs = <WorkerJob>[];
  Map<WorkerJob, Future<List<int>>> inProgressJobs = <WorkerJob, Future<List<int>>>{};
  Map<WorkerJob, List<int>> completedJobs = <WorkerJob, List<int>>{};
  Completer<Map<WorkerJob, List<int>>> completer;

  void _printReport() {
    final int totalJobs = completedJobs.length + inProgressJobs.length + pendingJobs.length;
    final String percent = totalJobs == 0 ? '100' : ((100 * completedJobs.length) ~/ totalJobs).toString().padLeft(3);
    final String completed = completedJobs.length.toString().padLeft(3);
    final String total = totalJobs.toString().padRight(3);
    final String inProgress = inProgressJobs.length.toString().padLeft(2);
    final String pending = pendingJobs.length.toString().padLeft(3);
    stdout.write('Jobs: $percent% done, $completed/$total completed, $inProgress in progress, $pending pending.  \r');
  }

  Future<List<int>> _scheduleJob(WorkerJob job) async {
    final Completer<List<int>> jobDone = new Completer<List<int>>();
    List<int> output;
    try {
      completedJobs[job] = await processRunner.runProcess(
        job.args,
        workingDirectory: job.workingDirectory,
        printOutput: job.printOutput,
      );
    } catch (e) {
      failedJobs.add(job);
      print('\nJob $job failed: $e');
    } finally {
      inProgressJobs.remove(job);
      if (pendingJobs.isNotEmpty) {
        final WorkerJob newJob = pendingJobs.removeAt(0);
        inProgressJobs[newJob] = _scheduleJob(newJob);
      } else {
        if (inProgressJobs.isEmpty) {
          completer.complete(completedJobs);
        }
      }
      jobDone.complete(output);
      _printReport();
    }
    return jobDone.future;
  }

  Future<Map<WorkerJob, List<int>>> startWorkers(List<WorkerJob> jobs) async {
    assert(inProgressJobs.isEmpty);
    assert(failedJobs.isEmpty);
    assert(completedJobs.isEmpty);
    if (jobs == null || jobs.isEmpty) {
      return <WorkerJob, List<int>>{};
    }
    completer = new Completer<Map<WorkerJob, List<int>>>();
    pendingJobs = jobs;
    for (int i = 0; i < numWorkers; ++i) {
      if (pendingJobs.isEmpty) {
        break;
      }
      final WorkerJob job = pendingJobs.removeAt(0);
      inProgressJobs[job] = _scheduleJob(job);
    }
    return completer.future.then((Map<WorkerJob, List<int>> result) {
      stdout.write('\n');
      stdout.flush();
      return result;
    });
  }
}

/// Generates diagrams from dart programs for use in the online documentation.
///
/// Runs a dart program to generate diagrams, and the optimizes the output
/// before moving the images into place for updating.
class DiagramGenerator {
  DiagramGenerator({
    ProcessRunner processRunner,
    this.temporaryDirectory,
    this.cleanup = true,
  }) : processRunner = processRunner ?? new ProcessRunner() {
    temporaryDirectory ??= Directory.systemTemp.createTempSync('api_generate_');
    print('Dart path: $generatorMain');
    print('Temp directory: ${temporaryDirectory.path}');
  }

  static const String flutterCommand = 'flutter';
  static const String optiPngCommand = 'optipng';
  static const String ffmpegCommand = 'ffmpeg';
  static const String adbCommand = 'adb';

  /// The path to the dart program to be run for generating the diagram.
  static final String generatorDir = path.join(
    projectDir,
    'utils',
    'diagram_generator',
  );

  /// The path to the dart program to be run for generating the diagram.
  static final String generatorMain = path.join(
    'lib',
    'main.dart',
  );

  /// The class that the app runs as.
  static const String appClass = 'io.flutter.api.diagramgenerator';

  /// The path to the top of the repo.
  static String get projectDir {
    return path.dirname(path.dirname(path.absolute(path.fromUri(Platform.script))));
  }

  /// The output asset directory for all the categories.
  static String get assetDir {
    return path.join(projectDir, 'assets');
  }

  /// Whether or not to cleanup the temporaryDirectory after generating diagrams.
  final bool cleanup;

  /// The function used to run processes to completion.
  final ProcessRunner processRunner;

  /// The temporary directory used to write screenshots and cropped out images
  /// into.
  Directory temporaryDirectory;

  Future<Null> generateDiagrams(List<String> categories, List<String> names) async {
    final DateTime startTime = new DateTime.now();
    await _createScreenshots(categories, names);
    final List<File> outputFiles = await _combineAnimations(await _transferImages());
    await _optimizeImages(outputFiles);
    if (cleanup) {
      await temporaryDirectory.delete(recursive: true);
    }
    print('Elapsed time for diagram generation: ${new DateTime.now().difference(startTime)}');
  }

  Future<Null> _createScreenshots(List<String> categories, List<String> names) async {
    print('Creating images.');
    final List<String> filters = <String>[];
    for (String category in categories) {
      filters.add('--category');
      filters.add(category);
    }
    for (String name in names) {
      filters.add('--name');
      filters.add(path.basenameWithoutExtension(name));
    }
    final List<String> filterArgs = filters.isNotEmpty
        ? <String>['--route', 'args:${Uri.encodeComponent(filters.join(' '))}']
        : <String>[];
    final List<String> args = <String>[flutterCommand, 'run'] + filterArgs;
    await processRunner.runProcess(args, workingDirectory: new Directory(generatorDir));
  }

  Future<List<File>> _transferImages() async {
    print('Collecting images from device.');
    final List<String> args = <String>[
      adbCommand,
      'exec-out',
      'run-as',
      '$appClass',
      'tar',
      'c',
      '-C',
      'app_flutter/diagrams',
      '.',
    ];
    final List<int> tarData = await processRunner.runProcess(
      args,
      workingDirectory: temporaryDirectory,
      printOutput: false,
    );
    final List<File> files = <File>[];
    for (ArchiveFile file in new TarDecoder().decodeBytes(tarData)) {
      if (file.isFile) {
        files.add(new File(file.name));
        new File(path.join(temporaryDirectory.absolute.path, file.name))
          ..createSync(recursive: true)
          ..writeAsBytesSync(file.content);
      }
    }
    return files;
  }

  Stream<List<int>> _concatInputs(List<File> files) async* {
    for (File file in files) {
      final Stream<List<int>> fileStream = file.openRead();
      await for (List<int> block in fileStream) {
        yield block;
      }
    }
  }

  Future<List<File>> _buildMoviesFromMetadata(List<AnimationMetadata> metadataList) async {
    final Directory destDir = new Directory(assetDir);
    final List<File> outputs = <File>[];
    for (AnimationMetadata metadata in metadataList) {
      final String prefix = '${metadata.category}/${metadata.name}';
      final File destination = new File(path.join(destDir.path, '$prefix.mp4'));
      if (destination.existsSync()) {
        destination.deleteSync();
      }
      print('Converting ${metadata.name} animation to mp4.');
      await processRunner.runProcess(
        <String>[
          ffmpegCommand,
          '-loglevel', 'fatal', // Only print fatal errors.
          '-framerate', metadata.frameRate.toStringAsFixed(2),
          '-i', '-', // read in the concatenated frame files from stdin.
          // Yes, specify the -framerate flag twice: once for input, once for output.
          '-framerate', metadata.frameRate.toStringAsFixed(2),
          '-tune', 'animation', // Optimize the encoder for cell animation.
          '-preset', 'veryslow', // Use the slowest (best quality) compression preset.
          '-crf', '1', // almost lossless quality (can't use lossless '0' because Safari doesn't support it)
          '-c:v', 'libx264', // encode to mp4 H.264
          '-y', // overwrite output
          '-vf', 'format=yuv420p', // video format set to YUV420 color space for compatibility.
          destination.path, // output movie.
        ],
        workingDirectory: temporaryDirectory,
        stdin: _concatInputs(metadata.frameFiles),
        printOutput: true,
      );
      outputs.add(destination);
    }
    return outputs;
  }

  Future<List<File>> _combineAnimations(List<File> inputFiles) async {
    final List<File> metadataFiles = inputFiles.where((File input) {
      return input.path.endsWith('.json');
    }).toList();
    // Collect all the animation frames that are in the metadata files so that
    // we can eliminate them from the other files that were transferred.
    final Set<String> animationFiles = <String>{};
    final List<AnimationMetadata> metadataList = <AnimationMetadata>[];
    for (File metadataFile in metadataFiles) {
      if (!metadataFile.isAbsolute) {
        metadataFile = new File(
          path.normalize(
            path.join(temporaryDirectory.absolute.path, metadataFile.path),
          ),
        );
      }
      final AnimationMetadata metadata = new AnimationMetadata.fromFile(metadataFile);
      metadataList.add(metadata);
      animationFiles.add(metadata.metadataFile.absolute.path);
      animationFiles.addAll(metadata.frameFiles.map((File file) => file.absolute.path));
    }
    final List<File> staticFiles = inputFiles.where((File input) {
      if (!input.isAbsolute) {
        input = new File(
          path.normalize(
            path.join(temporaryDirectory.absolute.path, input.path),
          ),
        );
      } else {
        input = new File(path.normalize(input.path));
      }
      return !animationFiles.contains(input.absolute.path);
    }).toList();
    final List<File> convertedFiles = await _buildMoviesFromMetadata(metadataList);
    return staticFiles..addAll(convertedFiles);
  }

  Future<Null> _optimizeImages(List<File> files) async {
    final Directory destDir = new Directory(assetDir);
    final List<WorkerJob> jobs = <WorkerJob>[];
    for (File imagePath in files) {
      if (!imagePath.path.endsWith('.png')) {
        continue;
      }
      final File destination = new File(path.join(destDir.path, imagePath.path));
      if (destination.existsSync()) {
        destination.deleteSync();
      }
      jobs.add(new WorkerJob(
        <String>[
          optiPngCommand,
          '-zc1-9',
          '-zm1-9',
          '-zs0-3',
          '-f0-5',
          imagePath.path,
          '-out',
          destination.path,
        ],
        workingDirectory: temporaryDirectory,
      ));
    }
    if (jobs.isNotEmpty) {
      final ProcessPool pool = new ProcessPool();
      await pool.startWorkers(jobs);
    }
  }
}

Future<Null> main(List<String> arguments) async {
  final ArgParser parser = new ArgParser();
  parser.addFlag('help', help: 'Print help.');
  parser.addFlag('keep-tmp', help: "Don't cleanup after a run (don't remove temporary directory).");
  parser.addOption('tmpdir', help: 'Specify a temporary directory to use (implies --keep-tmp)');
  parser.addMultiOption('category', help: 'Specify the categories of diagrams that should be '
      'generated. The category is the name of the subdirectory of the assets/ directory in which '
      'the images will be placed, as determined by the DiagramStep.category property.');
  parser.addMultiOption('name', help: 'Specify the name of diagrams that should be generated. The '
      'name is the basename of the output file and may be specified with or without the suffix.');
  final ArgResults flags = parser.parse(arguments);

  if (flags['help']) {
    print('generate.dart [flags]');
    print(parser.usage);
    exit(0);
  }

  bool keepTemporaryDirectory = flags['keep-tmp'];
  Directory temporaryDirectory;
  if (flags['tmpdir'] != null && flags['tmpdir'].isNotEmpty) {
    temporaryDirectory = new Directory(flags['tmpdir']);
    temporaryDirectory.createSync(recursive: true);
    keepTemporaryDirectory = true;
  }

  new DiagramGenerator(
    temporaryDirectory: temporaryDirectory,
    cleanup: !keepTemporaryDirectory,
  )..generateDiagrams(flags['category'], flags['name']);
}

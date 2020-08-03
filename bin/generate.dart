// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:args/args.dart';
import 'package:animation_metadata/animation_metadata.dart';
import 'package:path/path.dart' as path;
import 'package:platform/platform.dart' as platform_pkg;
import 'package:process/process.dart';

final String repoRoot = path.dirname(path.fromUri(Platform.script));
const platform_pkg.Platform defaultPlatform = platform_pkg.LocalPlatform();

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
    final String stderr = (result?.stderr ?? '') as String;
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
    this.platform = defaultPlatform,
  }) : processManager = processManager ?? const LocalProcessManager() {
    environment = Map<String, String>.from(platform.environment);
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
    bool printOutput = true,
    bool failOk = false,
    Stream<List<int>> stdin,
  }) async {
    workingDirectory ??= defaultWorkingDirectory ?? Directory.current;
    if (printOutput) {
      stderr.write('Running "${commandLine.join(' ')}" in ${workingDirectory.path}.\n');
    }
    final List<int> output = <int>[];
    final Completer<void> stdoutComplete = Completer<void>();
    final Completer<void> stderrComplete = Completer<void>();
    final Completer<void> stdinComplete = Completer<void>();

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
      throw ProcessRunnerException(message);
    } on ArgumentError catch (e) {
      final String message = 'Running "${commandLine.join(' ')}" in ${workingDirectory.path} '
          'failed with:\n${e.toString()}';
      throw ProcessRunnerException(message);
    }

    final int exitCode = await allComplete();
    if (exitCode != 0 && !failOk) {
      final String message =
          'Running "${commandLine.join(' ')}" in ${workingDirectory.path} failed';
      throw ProcessRunnerException(
        message,
        ProcessResult(0, exitCode, null, 'returned $exitCode'),
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
    this.stdin,
  }) : printOutput = printOutput ?? false;

  /// The arguments for the process, including the command name as args[0].
  final List<String> args;

  /// The working directory that the command should be executed in.
  final Directory workingDirectory;

  /// Whether or not this command should print it's stdout when it runs.
  final bool printOutput;

  /// If set, the stream to read the stdin input from for this job.
  Stream<List<int>> stdin;

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
    processRunner ??= ProcessRunner(processManager: processManager);
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
    final String percent =
        totalJobs == 0 ? '100' : ((100 * completedJobs.length) ~/ totalJobs).toString().padLeft(3);
    final String completed = completedJobs.length.toString().padLeft(3);
    final String total = totalJobs.toString().padRight(3);
    final String inProgress = inProgressJobs.length.toString().padLeft(2);
    final String pending = pendingJobs.length.toString().padLeft(3);
    stdout.write(
        'Jobs: $percent% done, $completed/$total completed, $inProgress in progress, $pending pending.  \r');
  }

  Future<List<int>> _scheduleJob(WorkerJob job) async {
    final Completer<List<int>> jobDone = Completer<List<int>>();
    List<int> output;
    try {
      completedJobs[job] = await processRunner.runProcess(
        job.args,
        workingDirectory: job.workingDirectory,
        printOutput: job.printOutput,
        stdin: job.stdin,
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
    completer = Completer<Map<WorkerJob, List<int>>>();
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
    String device,
    ProcessRunner processRunner,
    this.temporaryDirectory,
    this.cleanup = true,
  })  : device = device ?? '',
        processRunner = processRunner ?? ProcessRunner() {
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
  static const String appClass = 'dev.flutter.diagram_generator';

  /// The path to the top of the repo.
  static String get projectDir {
    return path.dirname(path.dirname(path.absolute(path.fromUri(Platform.script))));
  }

  /// The output asset directory for all the categories.
  static String get assetDir {
    return path.join(projectDir, 'assets');
  }

  /// The device identifier to use when building the diagrams.
  final String device;

  /// Whether or not to cleanup the temporaryDirectory after generating diagrams.
  final bool cleanup;

  /// The function used to run processes to completion.
  final ProcessRunner processRunner;

  /// The temporary directory used to write screenshots and cropped out images
  /// into.
  Directory temporaryDirectory;

  /// The device ID to use when transferring results from Android.
  String deviceId = '';

  /// The targetPlatform from the `flutter devices` output of the device we're
  /// targeting.
  String deviceTargetPlatform = '';

  Future<void> generateDiagrams(List<String> categories, List<String> names) async {
    final DateTime startTime = DateTime.now();
    if (!await _findIdForDeviceName()) {
      stderr.writeln('Unable to find device ID for device $device. Are you sure it is attached?');
      return;
    }

    await _createScreenshots(categories, names);
    final List<File> outputFiles = await _combineAnimations(await _transferImages());
    await _optimizeImages(outputFiles);
    if (cleanup) {
      await temporaryDirectory.delete(recursive: true);
    }
    print('Elapsed time for diagram generation: ${DateTime.now().difference(startTime)}');
  }

  Future<void> _createScreenshots(List<String> categories, List<String> names) async {
    print('Creating images.');
    final List<String> filters = <String>[];
    for (final String category in categories) {
      filters.add('--category');
      filters.add(category);
    }
    for (final String name in names) {
      filters.add('--name');
      filters.add(path.basenameWithoutExtension(name));
    }
    if (deviceId == 'linux') {
      filters.add('--outputDir');
      filters.add(temporaryDirectory.absolute.path);
    }
    final List<String> filterArgs = filters.isNotEmpty
        ? <String>['--route', 'args:${Uri.encodeComponent(filters.join(' '))}']
        : <String>[];
    final List<String> deviceArgs = <String>['-d', deviceId];
    final List<String> args = <String>[flutterCommand, 'run'] + filterArgs + deviceArgs;
    await processRunner.runProcess(args, workingDirectory: Directory(generatorDir));
  }

  Future<bool> _findIdForDeviceName() async {
    final List<int> rawJson = await processRunner.runProcess(
      <String>[
        flutterCommand,
        'devices',
        '--machine',
      ],
      workingDirectory: temporaryDirectory,
      printOutput: false,
    );

    final List<dynamic> devices = jsonDecode(utf8.decode(rawJson)) as List<dynamic>;
    for (final Map<String, dynamic> entry in devices.cast<Map<String, dynamic>>()) {
      if ((entry['name'] as String).toLowerCase().startsWith(device.toLowerCase()) ||
          (entry['id'] as String) == device) {
        deviceId = entry['id'] as String;
        deviceTargetPlatform = (entry['targetPlatform'] as String).toLowerCase();
        return true;
      }
    }
    return false;
  }

  Future<List<File>> _transferImages() async {
    final List<File> files = <File>[];
    if (deviceTargetPlatform.startsWith('android')) {
      print('Collecting images from device.');
      final List<String> args = <String>[
        adbCommand,
        '-s',
        deviceId,
        'exec-out',
        'run-as',
        appClass,
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
      for (final ArchiveFile file in TarDecoder().decodeBytes(tarData)) {
        if (file.isFile) {
          files.add(File(file.name));
          File(path.join(temporaryDirectory.absolute.path, file.name))
            ..createSync(recursive: true)
            ..writeAsBytesSync(file.content as List<int>);
        }
      }
    } else {
      await for (final FileSystemEntity entity
          in temporaryDirectory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final String relativePath = path.relative(entity.path, from: temporaryDirectory.path);
          files.add(File(relativePath));
        }
      }
    }
    return files;
  }

  Stream<List<int>> _concatInputs(List<File> files) async* {
    for (final File file in files) {
      final Stream<List<int>> fileStream = file.openRead();
      await for (final List<int> block in fileStream) {
        yield block;
      }
    }
  }

  Future<List<File>> _buildMoviesFromMetadata(List<AnimationMetadata> metadataList) async {
    final Directory destDir = Directory(assetDir);
    final List<File> outputs = <File>[];
    final List<WorkerJob> jobs = <WorkerJob>[];
    for (final AnimationMetadata metadata in metadataList) {
      final String prefix = '${metadata.category}/${metadata.name}';
      final File destination = File(path.join(destDir.path, '$prefix.mp4'));
      if (destination.existsSync()) {
        destination.deleteSync();
      }
      print('Converting ${metadata.name} animation to mp4.');
      jobs.add(WorkerJob(
        <String>[
          ffmpegCommand,
          '-loglevel', 'fatal', // Only print fatal errors.
          '-framerate', metadata.frameRate.toStringAsFixed(2),
          '-i', '-', // read in the concatenated frame files from stdin.
          // Yes, specify the -framerate flag twice: once for input, once for
          // output.
          '-framerate', metadata.frameRate.toStringAsFixed(2),
          '-tune', 'animation', // Optimize the encoder for cell animation.
          '-preset', 'veryslow', // Use the slowest (best quality) compression preset.
          // Almost lossless quality (can't use lossless '0' because Safari
          // doesn't support it).
          '-crf', '1',
          '-c:v', 'libx264', // encode to mp4 H.264
          '-y', // overwrite output
          // Video format set to YUV420 color space for compatibility.
          '-vf', 'format=yuv420p',
          destination.path, // output movie.
        ],
        workingDirectory: temporaryDirectory,
        stdin: _concatInputs(metadata.frameFiles),
        printOutput: true,
      ));
      outputs.add(destination);
    }
    final ProcessPool pool = ProcessPool();
    await pool.startWorkers(jobs);
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
        metadataFile = File(
          path.normalize(
            path.join(temporaryDirectory.absolute.path, metadataFile.path),
          ),
        );
      }
      final AnimationMetadata metadata = AnimationMetadata.fromFile(metadataFile);
      metadataList.add(metadata);
      animationFiles.add(metadata.metadataFile.absolute.path);
      animationFiles.addAll(metadata.frameFiles.map((File file) => file.absolute.path));
    }
    final List<File> staticFiles = inputFiles.where((File input) {
      if (!input.isAbsolute) {
        input = File(
          path.normalize(
            path.join(temporaryDirectory.absolute.path, input.path),
          ),
        );
      } else {
        input = File(path.normalize(input.path));
      }
      return !animationFiles.contains(input.absolute.path);
    }).toList();
    final List<File> convertedFiles = await _buildMoviesFromMetadata(metadataList);
    return staticFiles..addAll(convertedFiles);
  }

  Future<void> _optimizeImages(List<File> files) async {
    final Directory destDir = Directory(assetDir);
    final List<WorkerJob> jobs = <WorkerJob>[];
    for (final File imagePath in files) {
      if (!imagePath.path.endsWith('.png')) {
        continue;
      }
      final File destination = File(path.join(destDir.path, imagePath.path));
      if (destination.existsSync()) {
        destination.deleteSync();
      }
      jobs.add(WorkerJob(
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
      final ProcessPool pool = ProcessPool();
      await pool.startWorkers(jobs);
    }
  }
}

Future<void> main(List<String> arguments) async {
  final ArgParser parser = ArgParser();
  parser.addFlag('help', help: 'Print help.');
  parser.addFlag('keep-tmp', help: "Don't cleanup after a run (don't remove temporary directory).");
  parser.addOption('tmpdir',
      abbr: 't', help: 'Specify a temporary directory to use (implies --keep-tmp)');
  parser.addOption('device-id',
      abbr: 'd', help: 'Specify a device to use for generating the diagrams', defaultsTo: 'linux');
  parser.addMultiOption('category',
      abbr: 'c',
      help: 'Specify the categories of diagrams that should be '
          'generated. The category is the name of the subdirectory of the assets/ directory in which '
          'the images will be placed, as determined by the DiagramStep.category property.');
  parser.addMultiOption('name',
      abbr: 'n',
      help: 'Specify the name of diagrams that should be generated. The '
          'name is the basename of the output file and may be specified with or without the suffix.');
  final ArgResults flags = parser.parse(arguments);

  if (flags['help'] as bool) {
    print('generate.dart [flags]');
    print(parser.usage);
    exit(0);
  }

  bool keepTemporaryDirectory = flags['keep-tmp'] as bool;
  Directory temporaryDirectory;
  if (flags['tmpdir'] != null && (flags['tmpdir'] as String).isNotEmpty) {
    temporaryDirectory = Directory(flags['tmpdir'] as String);
    temporaryDirectory.createSync(recursive: true);
    keepTemporaryDirectory = true;
  }

  DiagramGenerator(
    device: flags['device-id'] as String,
    temporaryDirectory: temporaryDirectory,
    cleanup: !keepTemporaryDirectory,
  ).generateDiagrams(flags['category'] as List<String>, flags['name'] as List<String>);
}

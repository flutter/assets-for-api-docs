// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:args/args.dart';
import 'package:animation_metadata/animation_metadata.dart';
import 'package:process_runner/process_runner.dart';
import 'package:path/path.dart' as path;

final String repoRoot = path.dirname(path.fromUri(Platform.script));

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
        processRunner = processRunner ?? ProcessRunner(printOutputDefault: true) {
    // Since we can't pass command line args yet on linux, just generate them in
    // a known location.
    temporaryDirectory ??= device == 'linux'
        ? Directory('/tmp/diagrams')
        : Directory.systemTemp.createTempSync('api_generate_');
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
    final List<String> filterArgs = filters.isNotEmpty
        ? <String>['--route', 'args:${Uri.encodeComponent(filters.join(' '))}']
        : <String>[];
    final List<String> deviceArgs = <String>['-d', deviceId];
    final List<String> args = <String>[flutterCommand, 'run'] + filterArgs + deviceArgs;
    await processRunner.runProcess(args, workingDirectory: Directory(generatorDir));
  }

  Future<bool> _findIdForDeviceName() async {
    final ProcessRunnerResult result = await processRunner.runProcess(
      <String>[
        flutterCommand,
        'devices',
        '--machine',
      ],
      workingDirectory: temporaryDirectory,
      printOutput: false,
    );

    final List<dynamic> devices = jsonDecode(result.stdout) as List<dynamic>;
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
      final ProcessRunnerResult tarData = await processRunner.runProcess(
        args,
        workingDirectory: temporaryDirectory,
        printOutput: false,
      );
      for (final ArchiveFile file in TarDecoder().decodeBytes(tarData.stdoutRaw)) {
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
        stdinRaw: _concatInputs(metadata.frameFiles),
        printOutput: true,
      ));
      outputs.add(destination);
    }
    final ProcessPool pool = ProcessPool();
    await pool.runToCompletion(jobs);
    return outputs;
  }

  Future<List<File>> _combineAnimations(List<File> inputFiles) async {
    print('Input files: $inputFiles');
    final List<File> metadataFiles = inputFiles.where((File input) {
      return input.path.endsWith('.json');
    }).toList();
    print('Metadata: $metadataFiles');
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
    final List<WorkerJob> jobs = <WorkerJob>[];
    for (final File imagePath in files) {
      if (!imagePath.path.endsWith('.png')) {
        continue;
      }
      final File destination = File(path.join(Directory(assetDir).path, imagePath.path));
      final Directory destDir = destination.parent;
      if (!destDir.existsSync()) {
        destDir.createSync(recursive: true);
      }
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
        name: 'optipng ${destination.path}',
      ));
    }
    if (jobs.isNotEmpty) {
      final ProcessPool pool = ProcessPool();
      await for (final WorkerJob _ in pool.startWorkers(jobs)) {}
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

  final String deviceId = flags['device-id'] as String;
  bool keepTemporaryDirectory = flags['keep-tmp'] as bool;
  String tmpDirFlag = (flags['tmpdir'] as String) ?? '';
  if (tmpDirFlag.isEmpty && deviceId == 'linux') {
    // On linux, we can't pass command line arguments to a Flutter app, so we
    // just use a well-known location for the output.
    tmpDirFlag = '/tmp/diagrams';
    // And we nuke it to make sure that we're not left with cruft.
    try {
      Directory(tmpDirFlag).deleteSync(recursive: true);
    } on FileSystemException {
      // Do nothing if we can't delete it.
    }
  }

  Directory temporaryDirectory;
  if (tmpDirFlag.isNotEmpty) {
    temporaryDirectory = Directory(tmpDirFlag);
    temporaryDirectory.createSync(recursive: true);
    keepTemporaryDirectory = true;
  }

  DiagramGenerator(
    device: deviceId,
    temporaryDirectory: temporaryDirectory,
    cleanup: !keepTemporaryDirectory,
  ).generateDiagrams(flags['category'] as List<String>, flags['name'] as List<String>);
}

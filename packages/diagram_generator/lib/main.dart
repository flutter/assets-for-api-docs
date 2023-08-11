// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:args/args.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:diagrams/steps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:platform/platform.dart' as platform_pkg;

const platform_pkg.Platform platform = platform_pkg.LocalPlatform();

Future<Directory> prepareOutputDirectory(String? outputDir) async {
  Directory directory;
  if (platform.isAndroid) {
    directory = Directory(
      outputDir ??
          path.join(
            (await getApplicationDocumentsDirectory()).absolute.path,
            'diagrams',
          ),
    );
  } else {
    directory = Directory(outputDir!);
  }
  if (directory.existsSync()) {
    directory.deleteSync(recursive: true);
  }
  directory.createSync(recursive: true);
  return directory;
}

Future<void> main(List<String> args) async {
  DiagramFlutterBinding.ensureInitialized();
  late final List<String> arguments;
  if (platform.isAndroid) {
    arguments = PlatformDispatcher.instance.defaultRouteName.length > 5
        ? Uri.decodeComponent(
                PlatformDispatcher.instance.defaultRouteName.substring(5))
            .split(' ')
        : <String>[];
  } else {
    arguments = args;
  }
  final ArgParser parser = ArgParser();
  parser.addMultiOption('category');
  parser.addMultiOption('platform');
  parser.addMultiOption('name');
  parser.addMultiOption('step');
  parser.addOption('output-dir', defaultsTo: '/tmp/diagrams');
  final ArgResults flags = parser.parse(arguments);

  final StringBuffer errorLog = StringBuffer();
  FlutterError.onError = (FlutterErrorDetails details) {
    final DebugPrintCallback oldDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      errorLog.writeln(message);
      oldDebugPrint(message, wrapWidth: wrapWidth);
    };
    FlutterError.dumpErrorToConsole(details, forceReport: true);
    debugPrint = oldDebugPrint;
  };

  final List<String> categories = flags['category'] as List<String>;
  final List<String> names = flags['name'] as List<String>;
  final List<String> steps = flags['step'] as List<String>;
  final Set<DiagramPlatform> platforms = (flags['platform'] as List<String>)
      .map<DiagramPlatform>((String platformStr) {
    assert(diagramStepPlatformNames.containsKey(platformStr),
        'Invalid platform $platformStr');
    return diagramStepPlatformNames[platformStr]!;
  }).toSet();

  print(
    'Filters:\n  categories: $categories\n  names: $names\n  steps: $steps',
  );

  final DateTime start = DateTime.now();
  final Directory outputDirectory = await prepareOutputDirectory(
      platform.isAndroid ? null : flags['output-dir'] as String?);

  final DiagramController controller = DiagramController(
    outputDirectory: outputDirectory,
    screenDimensions: const Size(1300.0, 1300.0),
    pixelRatio: 1.0,
  );

  final Completer<void> done = Completer<void>();
  Zone.current.fork(specification: ZoneSpecification(
    handleUncaughtError: (
      Zone self,
      ZoneDelegate parent,
      Zone zone,
      Object error,
      StackTrace stackTrace,
    ) {
      print('Exception! $error\n$stackTrace');
      errorLog.writeln(error);
      errorLog.writeln(stackTrace);
    },
  )).runGuarded(() async {
    for (final DiagramStep step in allDiagramSteps) {
      if ((categories.isNotEmpty && !categories.contains(step.category)) ||
          (platforms.isNotEmpty &&
              platforms.intersection(step.platforms).isEmpty) ||
          (steps.isNotEmpty &&
              !steps.any((String name) =>
                  step.runtimeType.toString().toLowerCase() ==
                  name.toLowerCase()))) {
        continue;
      }
      final Directory stepOutputDirectory =
          Directory(path.join(outputDirectory.absolute.path, step.category));
      stepOutputDirectory.createSync(recursive: true);
      controller.outputDirectory = stepOutputDirectory;
      controller.pixelRatio = 1.0;
      print('Working on step ${step.runtimeType}');

      for (final DiagramMetadata diagram in await step.diagrams) {
        if (names.isNotEmpty && !names.contains(diagram.name)) {
          continue;
        }

        // Set up a custom onError to hide errors that the diagram expects, like
        // RenderFlex overflows.
        final FlutterExceptionHandler? oldOnError = FlutterError.onError;
        FlutterError.onError = (FlutterErrorDetails details) {
          final String exception = details.exception.toString();
          for (final Pattern pattern in diagram.expectedErrors) {
            if (pattern.allMatches(exception).isNotEmpty) {
              return;
            }
          }
          if (oldOnError != null) {
            oldOnError(details);
          }
        };

        try {
          final GlobalKey key = GlobalKey();
          controller.builder = (BuildContext context) {
            return KeyedSubtree(
              key: key,
              child: diagram,
            );
          };
          await diagram.setUp(key);
          if (diagram.duration != null) {
            await controller.drawAnimatedDiagramToFiles(
              end: diagram.duration!,
              frameRate: diagram.frameRate,
              category: step.category,
              name: diagram.name,
              start: diagram.startAt,
            );
          } else {
            await controller.drawDiagramToFile(
              File('${diagram.name}.png'),
              timestamp: diagram.startAt,
              framerate: diagram.frameRate,
            );
          }
        } finally {
          FlutterError.onError = oldOnError;
        }
      }
    }
    done.complete();
  });
  await done.future;

  // Save errors, if any. (We always create the file, even if empty, to signal we got to the end.)
  final String errors = errorLog.toString();
  final File errorsFile =
      File(path.join(outputDirectory.absolute.path, 'error.log'));
  errorsFile.writeAsStringSync(errors);
  if (errors.isNotEmpty) {
    print('Wrote errors to: ${errorsFile.path}');
  }

  final DateTime end = DateTime.now();
  final Duration elapsed = end.difference(start);
  const Duration minExecutionTime = Duration(seconds: 10);
  print('Total elapsed time: $elapsed');
  if (elapsed < minExecutionTime) {
    // If the app runs for less time than this, then it will throw an exception
    // when we exit because flutter run start trying to sync files to the device
    // after the process exits, and fails.
    await Future<void>.delayed(minExecutionTime - elapsed);
  }
  // Have to actually exit the app, otherwise flutter run won't ever exit,
  // and the generation script won't continue.
  exit(0);
}

// This is used by the `integration_test/smoke_test.dart`.
class SmokeTestApp extends StatelessWidget {
  const SmokeTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Smoke Test',
      home: Placeholder(),
    );
  }
}

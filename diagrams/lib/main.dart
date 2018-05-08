// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'app_bar.dart';
import 'blend_mode.dart';
import 'box_fit.dart';
import 'card.dart';
import 'colors.dart';
import 'curve.dart';
import 'diagram_step.dart';
import 'ink_response_large.dart';
import 'ink_response_small.dart';
import 'ink_well.dart';
import 'stroke_cap.dart';
import 'stroke_join.dart';
import 'tile_mode.dart';

Future<Directory> prepareOutputDirectory() async {
  final Directory directory = new Directory(
    path.join((await getApplicationDocumentsDirectory()).absolute.path, 'diagrams'),
  );
  if (directory.existsSync()) {
    directory.deleteSync(recursive: true);
  }
  directory.createSync(recursive: true);
  return directory;
}

Future<Null> main(List<String> arguments) async {
  final DateTime start = new DateTime.now();
  final Directory outputDirectory = await prepareOutputDirectory();

  final DiagramController controller = new DiagramController(
    outputDirectory: outputDirectory,
    screenDimensions: const Size(1000.0, 1000.0),
    pixelRatio: 1.0,
  );

  // Add the diagram steps here.
  final List<DiagramStep> steps = <DiagramStep>[
    new AppBarDiagramStep(controller),
    new BlendModeDiagramStep(controller),
    new BoxFitDiagramStep(controller),
    new CardDiagramStep(controller),
    new ColorsDiagramStep(controller),
    new CurveDiagramStep(controller),
    new InkResponseLargeDiagramStep(controller),
    new InkResponseSmallDiagramStep(controller),
    new InkWellDiagramStep(controller),
    new StrokeCapDiagramStep(controller),
    new StrokeJoinDiagramStep(controller),
    new TileModeDiagramStep(controller),
  ];

  for (DiagramStep step in steps) {
    final Directory stepOutputDirectory = new Directory(path.join(outputDirectory.absolute.path, step.category));
    stepOutputDirectory.createSync(recursive: true);
    controller.outputDirectory = stepOutputDirectory;
    controller.pixelRatio = 1.0;
    final List<File> files = await step.generateDiagrams();
    for (File file in files) {
      print('Created file ${file.path}');
    }
  }
  final DateTime end = new DateTime.now();
  final Duration elapsed = end.difference(start);
  const Duration minExecutionTime = const Duration(seconds: 5);
  print('Total elapsed time: $elapsed');
  if (elapsed < minExecutionTime) {
    // If the app runs for less time than this, then it will throw an exception
    // when we exit because flutter run start trying to sync files to the device
    // after the process exits, and fails.
    await new Future<Null>.delayed(minExecutionTime - elapsed);
  }
  // Have to actually exit the app, otherwise flutter run won't ever exit,
  // and the generation script won't continue.
  exit(0);
}

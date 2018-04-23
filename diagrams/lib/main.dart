// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:diagram/diagram.dart';
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
    new TileModeDiagramStep(controller),
  ];

  for (DiagramStep step in steps) {
    final Directory stepOutputDirectory = new Directory(path.join(outputDirectory.absolute.path, step.category));
    stepOutputDirectory.createSync(recursive: true);
    controller.outputDirectory = stepOutputDirectory;
    final List<File> files = await step.generateDiagrams();
    for (File file in files) {
      print('Created file $file');
    }
  }
  print('Total elapsed time: ${new DateTime.now().difference(start)}');
}

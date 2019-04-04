// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:args/args.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:diagrams/diagrams.dart';

Future<Directory> prepareOutputDirectory() async {
  final Directory directory = new Directory(
    path.join(
      (await getApplicationDocumentsDirectory()).absolute.path,
      'diagrams',
    ),
  );
  if (directory.existsSync()) {
    directory.deleteSync(recursive: true);
  }
  directory.createSync(recursive: true);
  return directory;
}

Future<Null> main() async {
  final List<String> arguments = window.defaultRouteName.length > 5
      ? Uri.decodeComponent(window.defaultRouteName.substring(5)).split(' ')
      : <String>[];
  final ArgParser parser = new ArgParser();
  parser.addMultiOption('category');
  parser.addMultiOption('name');
  final ArgResults flags = parser.parse(arguments);

  final List<String> categories = flags['category'];
  final List<String> names = flags['name'];

  final DateTime start = new DateTime.now();
  final Directory outputDirectory = await prepareOutputDirectory();

  final DiagramController controller = new DiagramController(
    outputDirectory: outputDirectory,
    screenDimensions: const Size(1000.0, 1000.0),
    pixelRatio: 1.0,
  );

  // Add the diagram steps here.
  final List<DiagramStep> steps = <DiagramStep>[
    new AlignDiagramStep(controller),
    new AppBarDiagramStep(controller),
    new BlendModeDiagramStep(controller),
    new BottomNavigationBarDiagramStep(controller),
    new BoxFitDiagramStep(controller),
    new CardDiagramStep(controller),
    new ColorsDiagramStep(controller),
    new ContainerDiagramStep(controller),
    new CurveDiagramStep(controller),
    new CustomListItemDiagramStep(controller),
    new HeroesDiagramStep(controller),
    new ImplicitAnimationDiagramStep(controller),
    new InkResponseLargeDiagramStep(controller),
    new InkResponseSmallDiagramStep(controller),
    new InkWellDiagramStep(controller),
    new ListTileDiagramStep(controller),
    new ListViewDiagramStep(controller),
    new RaisedButtonDiagramStep(controller),
    new SliverAppBarDiagramStep(controller),
    new StrokeCapDiagramStep(controller),
    new StrokeJoinDiagramStep(controller),
    new TileModeDiagramStep(controller),
    new TransitionDiagramStep(controller),
  ];

  for (DiagramStep step in steps) {
    if (categories.isNotEmpty && !categories.contains(step.category)) {
      continue;
    }
    final Directory stepOutputDirectory = new Directory(path.join(outputDirectory.absolute.path, step.category));
    stepOutputDirectory.createSync(recursive: true);
    controller.outputDirectory = stepOutputDirectory;
    controller.pixelRatio = 1.0;
    print('Working on step ${step.runtimeType}');
    final List<File> files = await step.generateDiagrams(onlyGenerate: names);
    for (File file in files) {
      print('Created file ${file.path}');
    }
  }
  final DateTime end = new DateTime.now();
  final Duration elapsed = end.difference(start);
  const Duration minExecutionTime = Duration(seconds: 10);
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

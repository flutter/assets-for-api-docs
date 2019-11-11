// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:args/args.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:diagrams/diagrams.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
  DiagramFlutterBinding.ensureInitialized();
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
  final List<DiagramStep<DiagramMetadata>> steps =
      <DiagramStep<DiagramMetadata>>[
    AlertDialogDiagramStep(controller),
    AlignDiagramStep(controller),
    AnimatedBuilderDiagramStep(controller),
    AnimationStatusValueDiagramStep(controller),
    AppBarDiagramStep(controller),
    BlendModeDiagramStep(controller),
    BottomNavigationBarDiagramStep(controller),
    BottomSheetDiagramStep(controller),
    BoxDecorationDiagramStep(controller),
    BoxFitDiagramStep(controller),
    CardDiagramStep(controller),
    CheckboxListTileDiagramStep(controller),
    ColorsDiagramStep(controller),
    ColumnDiagramStep(controller),
    ContainerDiagramStep(controller),
    CurveDiagramStep(controller),
    CustomListItemDiagramStep(controller),
    CustomScrollViewDiagramStep(controller),
    DataTableDiagramStep(controller),
    DropdownButtonDiagramStep(controller),
    DividerDiagramStep(controller),
    DrawerDiagramStep(controller),
    ExpandedDiagramStep(controller),
    FlatButtonDiagramStep(controller),
    FloatingActionButtonDiagramStep(controller),
    FlowDiagramStep(controller),
    FormDiagramStep(controller),
    FutureBuilderDiagramStep(controller),
    GestureDetectorDiagramStep(controller),
    GridViewDiagramStep(controller),
    HeroesDiagramStep(controller),
    IconDiagramStep(controller),
    IconButtonDiagramStep(controller),
    IconButtonDiagramStep(controller),
    ImageDiagramsStep(controller),
    ImplicitAnimationDiagramStep(controller),
    InkResponseLargeDiagramStep(controller),
    InkResponseSmallDiagramStep(controller),
    InkWellDiagramStep(controller),
    InputDecorationDiagramStep(controller),
    ListTileDiagramStep(controller),
    ListViewDiagramStep(controller),
    MaterialAppDiagramStep(controller),
    MediaQueryDiagramStep(controller),
    PaddingDiagramStep(controller),
    RadioListTileDiagramStep(controller),
    RaisedButtonDiagramStep(controller),
    RichTextDiagramStep(controller),
    RowDiagramStep(controller),
    ScaffoldDiagramStep(controller),
    ShowDatePickerDiagramStep(controller),
    SimpleDialogDiagramStep(controller),
    SingleChildScrollViewDiagramStep(controller),
    SliverAppBarDiagramStep(controller),
    SliverFillRemainingDiagramStep(controller),
    StreamBuilderDiagramStep(controller),
    StackDiagramStep(controller),
    StrokeCapDiagramStep(controller),
    StrokeJoinDiagramStep(controller),
    SwitchListTileDiagramStep(controller),
    TabsDiagramStep(controller),
    TextDiagramStep(controller),
    TextHeightDiagramStep(controller),
    TextFieldDiagramStep(controller),
    TextFormFieldDiagramStep(controller),
    TextStyleDiagramStep(controller),
    TileModeDiagramStep(controller),
    ThemeDataDiagramStep(controller),
    ToggleButtonsDiagramStep(controller),
    TransitionDiagramStep(controller),
    TweensDiagramStep(controller),
    TweenSequenceDiagramStep(controller),
  ];

  for (DiagramStep<DiagramMetadata> step in steps) {
    if (categories.isNotEmpty && !categories.contains(step.category)) {
      continue;
    }
    final Directory stepOutputDirectory =
        new Directory(path.join(outputDirectory.absolute.path, step.category));
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

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:args/args.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:diagrams/diagrams.dart';
import 'package:flutter/foundation.dart';
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
    arguments = window.defaultRouteName.length > 5
        ? Uri.decodeComponent(window.defaultRouteName.substring(5)).split(' ')
        : <String>[];
  } else {
    arguments = args;
  }
  final ArgParser parser = ArgParser();
  parser.addMultiOption('category');
  parser.addMultiOption('platform');
  parser.addMultiOption('name');
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
  final Set<DiagramPlatform> platforms = (flags['platform'] as List<String>)
      .map<DiagramPlatform>((String platformStr) {
    assert(diagramStepPlatformNames.containsKey(platformStr),
        'Invalid platform $platformStr');
    return diagramStepPlatformNames[platformStr]!;
  }).toSet();

  print('Filters:\n  categories: $categories\n  names: $names');

  final DateTime start = DateTime.now();
  final Directory outputDirectory = await prepareOutputDirectory(
      platform.isAndroid ? null : flags['output-dir'] as String?);

  final DiagramController controller = DiagramController(
    outputDirectory: outputDirectory,
    screenDimensions: const Size(1000.0, 1000.0),
    pixelRatio: 1.0,
  );

  // Add the diagram steps here.
  final List<DiagramStep<DiagramMetadata>> steps =
      <DiagramStep<DiagramMetadata>>[
    AlertDialogDiagramStep(controller),
    AlignDiagramStep(controller),
    AnimationStatusValueDiagramStep(controller),
    AppBarDiagramStep(controller),
    BlendModeDiagramStep(controller),
    BottomNavigationBarDiagramStep(controller),
    BoxDecorationDiagramStep(controller),
    BoxFitDiagramStep(controller),
    CardDiagramStep(controller),
    CheckboxListTileDiagramStep(controller),
    ColorsDiagramStep(controller),
    ColumnDiagramStep(controller),
    ContainerDiagramStep(controller),
    CupertinoAppDiagramStep(controller),
    CupertinoIconDiagramStep(controller),
    CurveDiagramStep(controller),
    CustomListItemDiagramStep(controller),
    CustomScrollViewDiagramStep(controller),
    DataTableDiagramStep(controller),
    DividerDiagramStep(controller),
    DrawerDiagramStep(controller),
    DropdownButtonDiagramStep(controller),
    ExpandedDiagramStep(controller),
    FilterQualityDiagramStep(controller),
    FlatButtonDiagramStep(controller),
    FloatingActionButtonDiagramStep(controller),
    FloatingActionButtonLocationDiagramStep(controller),
    FormDiagramStep(controller),
    FontFeatureDiagramStep(controller),
    GestureDetectorDiagramStep(controller),
    GridViewDiagramStep(controller),
    HeroesDiagramStep(controller),
    IconButtonDiagramStep(controller),
    IconButtonDiagramStep(controller),
    IconDiagramStep(controller),
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
    SimpleDialogDiagramStep(controller),
    SliverAppBarDiagramStep(controller),
    SliverFillRemainingDiagramStep(controller),
    StackDiagramStep(controller),
    StrokeCapDiagramStep(controller),
    StrokeJoinDiagramStep(controller),
    SwitchListTileDiagramStep(controller),
    TabsDiagramStep(controller),
    TextDiagramStep(controller),
    TextFieldDiagramStep(controller),
    TextFormFieldDiagramStep(controller),
    TextHeightDiagramStep(controller),
    TextStyleDiagramStep(controller),
    ThemeDataDiagramStep(controller),
    TileModeDiagramStep(controller),
    ToggleButtonsDiagramStep(controller),
    TransitionDiagramStep(controller),
    TweensDiagramStep(controller),
    TweenSequenceDiagramStep(controller),
  ];

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
    for (final DiagramStep<DiagramMetadata> step in steps) {
      if (categories.isNotEmpty && !categories.contains(step.category)) {
        continue;
      }
      final Directory stepOutputDirectory =
          Directory(path.join(outputDirectory.absolute.path, step.category));
      stepOutputDirectory.createSync(recursive: true);
      controller.outputDirectory = stepOutputDirectory;
      controller.pixelRatio = 1.0;
      print('Working on step ${step.runtimeType}');

      await step.generateDiagrams(onlyGenerate: names, platforms: platforms);
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

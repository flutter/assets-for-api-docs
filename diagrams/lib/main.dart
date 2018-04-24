import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:diagram/diagram.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'curve.dart';
import 'diagram_step.dart';

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
  Directory outputDirectory = await prepareOutputDirectory();

  DiagramController controller = new DiagramController(
    outputDirectory: outputDirectory,
    screenDimensions: const Size(400.0, 300.0),
    pixelRatio: 1.0,
  );

  // Add the diagram steps here.
  List<DiagramStep> steps = <DiagramStep>[
    new CurveDiagramStep(controller),
  ];

  for (DiagramStep step in steps) {
    List<File> files = await step.generateDiagrams();
    for (File file in files) {
      print('Created file $file');
    }
  }
}

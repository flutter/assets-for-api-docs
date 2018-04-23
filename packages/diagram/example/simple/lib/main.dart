// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram/diagram.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MyDiagram extends StatefulWidget {
  MyDiagram({this.size: 1.0});

  final double size;

  _MyDiagramState createState() => new _MyDiagramState();
}

class _MyDiagramState extends State<MyDiagram> {
  Widget build(BuildContext context) {
    return new AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: widget.size,
      height: widget.size,
      decoration: new ShapeDecoration(
        shape: const BeveledRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        ),
        color: Color(0xfeedbeef),
      ),
    );
  }
}

Future<Null> main() async {
  final Directory directory = new Directory(
    path.join((await getApplicationDocumentsDirectory()).absolute.path, 'diagrams'),
  );
  if (directory.existsSync()) {
    directory.deleteSync(recursive: true);
  }
  directory.createSync(recursive: true);
  DiagramController controller = new DiagramController(
    builder: (BuildContext context) => new MyDiagram(),
    outputDirectory: directory,
    pixelRatio: 3.0,
    screenDimensions: const Size(100.0, 100.0),
  );

  // Start the implicit animation by changing the builder.
  controller.builder = (BuildContext context) => new MyDiagram(size: 50.0);

  // Capture some frames.
  await controller.drawAnimatedDiagramToFiles(
    end: const Duration(seconds: 1),
    frameDuration: const Duration(milliseconds: 100),
  );

  controller.builder = (BuildContext context) => new Text('Done');
  await controller.drawDiagramToFile(new File('done.png'));
}

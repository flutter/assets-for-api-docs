// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _basic = 'basic_material_app';
const String _theme = 'theme_material_app';

class MaterialAppDiagram extends StatelessWidget implements DiagramMetadata {
  const MaterialAppDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _basic:
        returnWidget = MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
            ),
          ),
          debugShowCheckedModeBanner: false,
        );
        break;
      case _theme:
        returnWidget = MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
           primaryColor: Colors.blueGrey
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('MaterialApp Theme'),
            ),
          ),
          debugShowCheckedModeBanner: false,
        );
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 533.33)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: returnWidget,
      ),
    );
  }
}

class MaterialAppDiagramStep extends DiagramStep<MaterialAppDiagram> {
  MaterialAppDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<MaterialAppDiagram>> get diagrams async => <MaterialAppDiagram>[
        const MaterialAppDiagram(_basic),
        const MaterialAppDiagram(_theme),
      ];

  @override
  Future<File> generateDiagram(MaterialAppDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

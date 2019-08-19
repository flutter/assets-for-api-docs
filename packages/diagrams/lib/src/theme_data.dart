// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _themeData = 'theme_data';
const String _materialAppThemeData = 'material_app_theme_data';

class ThemeDataDiagram extends StatelessWidget implements DiagramMetadata {
  const ThemeDataDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _themeData:
        returnWidget = Theme(
          data: ThemeData(primaryColor: Colors.amber),
          child: Builder(
            builder: (BuildContext context) {
              return Container(
                width: 100,
                height: 100,
                color: Theme.of(context).primaryColor,
              );
            },
          ),
        );
        break;
      case _materialAppThemeData:
        returnWidget = MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primaryColor: Colors.blue),
          home: Builder(
            builder: (BuildContext context) {
              return Center(
                child: Container(
                  width: 100,
                  height: 100,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        );
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(150.0, 150.0)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Center(
          child: returnWidget,
        ),
      ),
    );
  }
}

class ThemeDataDiagramStep extends DiagramStep<ThemeDataDiagram> {
  ThemeDataDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<ThemeDataDiagram>> get diagrams async => <ThemeDataDiagram>[
        const ThemeDataDiagram(_themeData),
        const ThemeDataDiagram(_materialAppThemeData),
      ];

  @override
  Future<File> generateDiagram(ThemeDataDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

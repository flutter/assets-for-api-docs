// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _basic = 'basic_material_app';
const String _theme = 'theme_material_app';
const String _textstyle = 'unspecified_textstyle_material_app';

class MaterialAppDiagram extends StatelessWidget with DiagramMetadata {
  const MaterialAppDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    late Widget returnWidget;

    switch (name) {
      case _basic:
        returnWidget = MaterialApp(
          home: Scaffold(appBar: AppBar(title: const Text('Home'))),
          debugShowCheckedModeBanner: false,
        );
        break;
      case _theme:
        returnWidget = MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blueGrey,
          ),
          home: Scaffold(
            appBar: AppBar(title: const Text('MaterialApp Theme')),
          ),
          debugShowCheckedModeBanner: false,
        );
        break;
      case _textstyle:
        returnWidget = const MaterialApp(
          home: Center(child: Text('Hello World')),
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

class MaterialAppDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<MaterialAppDiagram>> get diagrams async => <MaterialAppDiagram>[
    const MaterialAppDiagram(_basic),
    const MaterialAppDiagram(_theme),
    const MaterialAppDiagram(_textstyle),
  ];
}

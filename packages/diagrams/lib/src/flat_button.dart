// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _basic = 'flat_button';
const String _properties = 'flat_button_properties';

class FlatButtonDiagram extends StatelessWidget implements DiagramMetadata {
  const FlatButtonDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _basic:
        returnWidget = FlatButton(
          onPressed: () {},
          child: const Text(
            'Flat Button',
          ),
        );
        break;
      case _properties:
        returnWidget = FlatButton(
          color: Colors.blue,
          textColor: Colors.white,
          disabledColor: Colors.grey,
          disabledTextColor: Colors.black,
          padding: const EdgeInsets.all(8.0),
          splashColor: Colors.blueAccent,
          onPressed: () {},
          child: const Text(
            'Flat Button',
            style: TextStyle(fontSize: 20.0),
          ),
        );
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(300.0, 120.0)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Center(child: returnWidget),
      ),
    );
  }
}

class FlatButtonDiagramStep extends DiagramStep<FlatButtonDiagram> {
  FlatButtonDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<FlatButtonDiagram>> get diagrams async => <FlatButtonDiagram>[
        const FlatButtonDiagram(_basic),
        const FlatButtonDiagram(_properties),
      ];

  @override
  Future<File> generateDiagram(FlatButtonDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

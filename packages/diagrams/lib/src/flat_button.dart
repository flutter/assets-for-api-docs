// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class FlatButtonDiagram extends StatelessWidget implements DiagramMetadata {
  const FlatButtonDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnButton;
    switch (name) {
      case 'flat_button_a':
        returnButton = FlatButton(
          onPressed: () {},
          color: Colors.blue,
          textColor: Colors.white,
          disabledColor: Colors.grey,
          disabledTextColor: Colors.black,
          padding: const EdgeInsets.all(15.0),
          splashColor: Colors.amber,
          child: const Text(
            'Flat Button',
            style: TextStyle(fontSize: 20.0),
          ),
        );
        break;
      case 'flat_button_b':
        returnButton = FlatButton(
          onPressed: () {},
          child: SizedBox(
            height: 75,
            width: 75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Icon(
                  Icons.save,
                  size: 30,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text('SAVE'),
                ), //Text('Flat Button'),
              ],
            ),
          ),
        );
        break;
      default:
        returnButton = const Text('Error');
    }
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(200.0, 200.0)),
      child: new Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(10.0),
        color: Colors.white,
        child: Center(
          child: returnButton,
        ),
      ),
    );
  }
}

class FlatButtonDiagramStep extends DiagramStep {
  FlatButtonDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const FlatButtonDiagram('flat_button_a'),
    const FlatButtonDiagram('flat_button_b'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final FlatButtonDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class FloatingActionButtonDiagram extends StatelessWidget
    implements DiagramMetadata {
  const FloatingActionButtonDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnButton;
    switch (name) {
      case 'floating_action_button_a':
        returnButton = FloatingActionButton(
          onPressed: () {},
          child: const Padding(
            padding: EdgeInsets.all(5.0),
            child: Icon(
              Icons.cake,
              size: 35,
            ),
          ),
          backgroundColor: Colors.pink,
        );
        break;
      case 'floating_action_button_b':
        returnButton = FloatingActionButton.extended(
          onPressed: () {},
          label: Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              'Approve',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          icon: const Icon(Icons.thumb_up),
          backgroundColor: Colors.blue,
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

class FloatingActionButtonDiagramStep extends DiagramStep {
  FloatingActionButtonDiagramStep(DiagramController controller)
      : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
        const FloatingActionButtonDiagram('floating_action_button_a'),
        const FloatingActionButtonDiagram('floating_action_button_b'),
      ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final FloatingActionButtonDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

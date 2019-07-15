// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _stack = 'stack';
const String _stackWithGradient = 'stack_with_gradient';

class StackDiagram extends StatelessWidget implements DiagramMetadata {
  const StackDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;
    switch (name) {
      case _stack:
        returnWidget = Stack(
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
            Container(
              width: 90,
              height: 90,
              color: Colors.green,
            ),
            Container(
              width: 80,
              height: 80,
              color: Colors.blue,
            ),
          ],
        );
        break;
      case _stackWithGradient:
        returnWidget = Stack(
          children: <Widget>[
            Container(
              width: 250,
              height: 250,
              color: Colors.white,
            ),
            Container(
              padding: const EdgeInsets.all(5.0),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withAlpha(0),
                    Colors.black12,
                    Colors.black45
                  ],
                ),
              ),
              child: const Text(
                'Foreground Text',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
          ],
        );
        break;
      default:
        returnWidget = const Text('Error');
        break;
    }
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(400.0, 250.0)),
      child: new Container(
          alignment: FractionalOffset.center,
          padding: const EdgeInsets.all(5.0),
          color: Colors.white,
          child: returnWidget,
      ),
    );
  }
}

class StackDiagramStep extends DiagramStep<StackDiagram> {
  StackDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<StackDiagram>> get diagrams async => <StackDiagram>[
        const StackDiagram(_stack),
        const StackDiagram(_stackWithGradient),
      ];

  @override
  Future<File> generateDiagram(StackDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

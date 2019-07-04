// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _row = 'row';
const String _rowError = 'row_error';
const String _rowFixed = 'row_fixed';

class RowDiagram extends StatelessWidget implements DiagramMetadata {
  const RowDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;
    switch (name) {
      case _row:
        returnWidget = Row(
          children: const <Widget>[
            Expanded(
              child: Text(
                'Deliver features faster',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                'Craft beautiful UIs',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain, // otherwise the logo will be tiny
                child: FlutterLogo(),
              ),
            ),
          ],
        );
        break;
      case _rowError:
        returnWidget = Row(
          children: const <Widget>[
            FlutterLogo(),
            Text(
              'Flutter\'s hot reload helps you quickly and easily experiment, build UIs, add features, and fix bug faster. Experience sub-second reload times, without losing state, on emulators, simulators, and hardware for iOS and Android.',
            ),
            Icon(Icons.sentiment_very_satisfied),
          ],
        );
        break;
      case _rowFixed:
        returnWidget = Row(
          children: const <Widget>[
            FlutterLogo(),
            Expanded(
              child: Text(
                'Flutter\'s hot reload helps you quickly and easily experiment, build UIs, add features, and fix bug faster. Experience sub-second reload times, without losing state, on emulators, simulators, and hardware for iOS and Android.',
              ),
            ),
            Icon(Icons.sentiment_very_satisfied),
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

class RowDiagramStep extends DiagramStep<RowDiagram> {
  RowDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<RowDiagram>> get diagrams async => <RowDiagram>[
        const RowDiagram(_row),
        const RowDiagram(_rowError),
        const RowDiagram(_rowFixed),
      ];

  @override
  Future<File> generateDiagram(RowDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _row = 'row';
const String _rowError = 'row_error';
const String _rowFixed = 'row_fixed';
const String _rowTextDirection = 'row_textDirection';

class RowDiagram extends StatelessWidget implements DiagramMetadata {
  const RowDiagram(this.name, { this.ignoreErrors = false, Key? key}) : super(key: key);

  @override
  final String name;

  final bool ignoreErrors;

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
        assert(ignoreErrors);
        returnWidget = Row(
          children: const <Widget>[
            FlutterLogo(),
            Text(
              "Flutter's hot reload helps you quickly and easily experiment, build UIs, add features, and fix bug faster. Experience sub-second reload times, without losing state, on emulators, simulators, and hardware for iOS and Android.",
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
                "Flutter's hot reload helps you quickly and easily experiment, build UIs, add features, and fix bug faster. Experience sub-second reload times, without losing state, on emulators, simulators, and hardware for iOS and Android.",
              ),
            ),
            Icon(Icons.sentiment_very_satisfied),
          ],
        );
        break;
      case _rowTextDirection:
        returnWidget = Row(
          textDirection: TextDirection.rtl,
          children: const <Widget>[
            FlutterLogo(),
            Expanded(
              child: Text(
                "Flutter's hot reload helps you quickly and easily experiment, build UIs, add features, and fix bug faster. Experience sub-second reload times, without losing state, on emulators, simulators, and hardware for iOS and Android.",
              ),
            ),
            Icon(Icons.sentiment_very_satisfied),
          ],
        );
        break;
      default:
        throw Exception('unknown $runtimeType diagram type: $name');
    }
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400.0, 250.0)),
      child: Container(
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
    const RowDiagram(_rowError, ignoreErrors: true),
    const RowDiagram(_rowFixed),
    const RowDiagram(_rowTextDirection),
  ];

  @override
  Future<File> generateDiagram(RowDiagram diagram) async {
    final FlutterExceptionHandler? oldHandler = FlutterError.onError;
    int errorCount = 0;
    if (diagram.ignoreErrors) {
      FlutterError.onError = (FlutterErrorDetails details) {
        debugPrint('Ignoring one error ("${details.exception}").');
        errorCount += 1;
      };
    }
    try {
      controller.builder = (BuildContext context) => diagram;
      return controller.drawDiagramToFile(File('${diagram.name}.png'));
    } finally {
      FlutterError.onError = oldHandler;
      if (diagram.ignoreErrors && errorCount == 0) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: Exception('Expected an error but did not get any errors for "${diagram.name}".'),
          library: 'diagrams',
        ));
      }
    }
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _row = 'row';
const String _rowError = 'row_error';
const String _rowFixed = 'row_fixed';
const String _rowTextDirection = 'row_textDirection';

class RowDiagram extends StatelessWidget with DiagramMetadata {
  const RowDiagram(this.name, {super.key});

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

  @override
  Set<Pattern> get expectedErrors {
    return <Pattern>{
      if (name == _rowError)
        RegExp(r'A RenderFlex overflowed by \d+ pixels on the right.'),
    };
  }
}

class RowDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<RowDiagram>> get diagrams async => <RowDiagram>[
        const RowDiagram(_row),
        const RowDiagram(_rowError),
        const RowDiagram(_rowFixed),
        const RowDiagram(_rowTextDirection),
      ];
}

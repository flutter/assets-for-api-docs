// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _column = 'column';
const String _columnWithProperties = 'column_properties';

class ColumnDiagram extends StatelessWidget with DiagramMetadata {
  const ColumnDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;
    switch (name) {
      case _column:
        returnWidget = const Column(
          children: <Widget>[
            Text('Deliver features faster'),
            Text('Craft beautiful UIs'),
            Expanded(child: FittedBox(child: FlutterLogo())),
          ],
        );
        break;
      case _columnWithProperties:
        returnWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('We move under cover and we move as one'),
            const Text(
              'Through the night, we have one shot to live another day',
            ),
            const Text('We cannot let a stray gunshot give us away'),
            const Text(
              'We will fight up close, seize the moment and stay in it',
            ),
            const Text(
              'It’s either that or meet the business end of a bayonet',
            ),
            const Text('The code word is ‘Rochambeau,’ dig me?'),
            Text(
              'Rochambeau!',
              style: DefaultTextStyle.of(
                context,
              ).style.apply(fontSizeFactor: 2.0),
            ),
          ],
        );
        break;
      default:
        returnWidget = const Text('Error');
        break;
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

class ColumnDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<ColumnDiagram>> get diagrams async => <ColumnDiagram>[
    const ColumnDiagram(_column),
    const ColumnDiagram(_columnWithProperties),
  ];
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _column = 'expanded_column';
const String _row = 'expanded_row';

class ExpandedDiagram extends StatelessWidget with DiagramMetadata {
  const ExpandedDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    late Widget returnWidget;

    switch (name) {
      case _column:
        returnWidget = Scaffold(
          appBar: AppBar(
            title: const Text('Expanded Column Sample'),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.blue,
                  width: 100,
                  height: 100,
                ),
                Expanded(
                  child: Container(
                    width: 100,
                    color: Colors.amber,
                    child: const Center(child: Text('Expanded')),
                  ),
                ),
                Container(
                  color: Colors.blue,
                  width: 100,
                  height: 100,
                ),
              ],
            ),
          ),
        );
        break;
      case _row:
        returnWidget = Scaffold(
          appBar: AppBar(
            title: const Text('Expanded Row Sample'),
          ),
          body: Center(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.amber,
                    height: 100,
                    child: const Center(child: Text('flex: 2')),
                  ),
                ),
                Container(
                  color: Colors.blue,
                  height: 100,
                  width: 50,
                ),
                Expanded(
                  child: Container(
                    color: Colors.amber,
                    height: 100,
                    child: const Center(child: Text('flex: 1')),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 533.33)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Center(child: returnWidget),
      ),
    );
  }
}

class ExpandedDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<ExpandedDiagram>> get diagrams async => <ExpandedDiagram>[
        const ExpandedDiagram(_column),
        const ExpandedDiagram(_row),
      ];
}

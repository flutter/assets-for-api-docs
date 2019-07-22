// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _column = 'expanded_column';
const String _row = 'expanded_row';

class ExpandedDiagram extends StatelessWidget implements DiagramMetadata {
  const ExpandedDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

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
                  color: Colors.red,
                  height: 100,
                  width: 100,
                ),
                Expanded(
                  child: Container(
                    color: Colors.blue,
                    width: 100,
                  ),
                ),
                Container(
                  color: Colors.red,
                  height: 100,
                  width: 100,
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
                    color: Colors.red,
                    height: 100,
                  ),
                ),
                Container(
                  color: Colors.blue,
                  height: 100,
                  width: 50,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.red,
                    height: 100,
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

class ExpandedDiagramStep extends DiagramStep<ExpandedDiagram> {
  ExpandedDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<ExpandedDiagram>> get diagrams async => <ExpandedDiagram>[
        const ExpandedDiagram(_column),
        const ExpandedDiagram(_row),
      ];

  @override
  Future<File> generateDiagram(ExpandedDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class ListViewDiagram extends StatelessWidget implements DiagramMetadata {
  const ListViewDiagram(this.name);

  @override
  final String name;
  static const List<String> entries = <String>['A', 'B', 'C'];
  static const List<int> colorCodes = <int>[600, 500, 100];

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;
    switch (name) {
      case 'list_view':
        returnWidget = ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            Container(
              height: 50,
              color: Colors.amber[600],
              child: const Center(child: Text('Entry A')),
            ),
            Container(
              height: 50,
              color: Colors.amber[500],
              child: const Center(child: Text('Entry B')),
            ),
            Container(
              height: 50,
              color: Colors.amber[100],
              child: const Center(child: Text('Entry C')),
            ),
          ],
        );
        break;
      case 'list_view_builder':
        returnWidget = ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: entries.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                height: 50,
                color: Colors.amber[colorCodes[index]],
                child: Center(child: Text('Entry ${entries[index]}')),
              );
            });
        break;
      case 'list_view_separated':
        returnWidget = ListView.separated(
          padding: const EdgeInsets.all(8.0),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 50,
              color: Colors.amber[colorCodes[index]],
              child: Center(child: Text('Entry ${entries[index]}')),
            );
          },
          separatorBuilder: (BuildContext context, int index) =>
              const Divider(),
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
        child: returnWidget
      ),
    );
  }
}

class ListViewDiagramStep extends DiagramStep<ListViewDiagram> {
  ListViewDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<ListViewDiagram>> get diagrams async => <ListViewDiagram>[
        const ListViewDiagram('list_view'),
        const ListViewDiagram('list_view_builder'),
        const ListViewDiagram('list_view_separated'),
      ];

  @override
  Future<File> generateDiagram(ListViewDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

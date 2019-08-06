// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _gridView = 'grid_view';
const String _customScrollGridView = 'grid_view_custom_scroll';

class GridViewDiagram extends StatelessWidget implements DiagramMetadata {
  const GridViewDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _gridView:
        returnWidget = GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20.0),
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          crossAxisCount: 2,
          children: <Widget>[
            Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('He\'d have you all unravel at the')), color: Colors.teal[100]),
            Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Heed not the rabble')), color: Colors.teal[200]),
            Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Sound of screams but the')), color: Colors.teal[300]),
            Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Who scream')), color: Colors.teal[400]),
            Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Revolution is coming...')), color: Colors.teal[500]),
            Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Revolution, they...')), color: Colors.teal[600]),
          ],
        );
        break;
      case _customScrollGridView:
        returnWidget = CustomScrollView(
          primary: false,
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverGrid.count(
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                crossAxisCount: 2,
                children: <Widget>[
                  Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('He\'d have you all unravel at the')), color: Colors.lightGreen[100]),
                  Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Heed not the rabble')), color: Colors.lightGreen[200]),
                  Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Sound of screams but the')), color: Colors.lightGreen[300]),
                  Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Who scream')), color: Colors.lightGreen[400]),
                  Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Revolution is coming...')), color: Colors.lightGreen[500]),
                  Container(child: const Padding(padding: EdgeInsets.all(8.0), child: Text('Revolution, they...')), color: Colors.lightGreen[600]),
                ],
              ),
            ),
          ],
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

class GridViewDiagramStep extends DiagramStep<GridViewDiagram> {
  GridViewDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<GridViewDiagram>> get diagrams async => <GridViewDiagram>[
        const GridViewDiagram(_gridView),
        const GridViewDiagram(_customScrollGridView),
      ];

  @override
  Future<File> generateDiagram(GridViewDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

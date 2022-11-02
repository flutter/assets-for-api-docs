// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _gridView = 'grid_view';
const String _customScrollGridView = 'grid_view_custom_scroll';

class GridViewDiagram extends StatelessWidget with DiagramMetadata {
  const GridViewDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    late Widget returnWidget;

    switch (name) {
      case _gridView:
        returnWidget = GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20.0),
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          crossAxisCount: 2,
          children: <Widget>[
            Container(
                color: Colors.teal[100],
                child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("He'd have you all unravel at the"))),
            Container(
                color: Colors.teal[200],
                child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Heed not the rabble'))),
            Container(
                color: Colors.teal[300],
                child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Sound of screams but the'))),
            Container(
                color: Colors.teal[400],
                child: const Padding(
                    padding: EdgeInsets.all(8.0), child: Text('Who scream'))),
            Container(
                color: Colors.teal[500],
                child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Revolution is coming...'))),
            Container(
                color: Colors.teal[600],
                child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Revolution, they...'))),
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
                  Container(
                      color: Colors.lightGreen[100],
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("He'd have you all unravel at the"))),
                  Container(
                      color: Colors.lightGreen[200],
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Heed not the rabble'))),
                  Container(
                      color: Colors.lightGreen[300],
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Sound of screams but the'))),
                  Container(
                      color: Colors.lightGreen[400],
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Who scream'))),
                  Container(
                      color: Colors.lightGreen[500],
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Revolution is coming...'))),
                  Container(
                      color: Colors.lightGreen[600],
                      child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Revolution, they...'))),
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

class GridViewDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<GridViewDiagram>> get diagrams async => <GridViewDiagram>[
        const GridViewDiagram(_gridView),
        const GridViewDiagram(_customScrollGridView),
      ];
}

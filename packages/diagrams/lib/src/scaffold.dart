// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _scaffold = 'scaffold';
const String _scaffoldBackgroundColor = 'scaffold_background_color';
const String _scaffoldBottomAppBar = 'scaffold_bottom_app_bar';

class ScaffoldDiagram extends StatefulWidget with DiagramMetadata {
  const ScaffoldDiagram({super.key, required this.name});

  @override
  final String name;

  @override
  State<StatefulWidget> createState() => ScaffoldDiagramState();
}

class ScaffoldDiagramState extends State<ScaffoldDiagram> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    late Widget returnWidget;
    switch (widget.name) {
      case _scaffold:
        returnWidget = Scaffold(
          appBar: AppBar(title: const Text('Sample Code')),
          body: Center(
            child: Text('You have pressed the button $_count times.'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() => _count++),
            tooltip: 'Increment Counter',
            child: const Icon(Icons.add),
          ),
        );
        break;
      case _scaffoldBackgroundColor:
        returnWidget = Scaffold(
          appBar: AppBar(title: const Text('Sample Code')),
          body: Center(
            child: Text('You have pressed the button $_count times.'),
          ),
          backgroundColor: Colors.blueGrey.shade200,
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() => _count++),
            tooltip: 'Increment Counter',
            child: const Icon(Icons.add),
          ),
        );
        break;
      case _scaffoldBottomAppBar:
        returnWidget = Scaffold(
          appBar: AppBar(title: const Text('Sample Code')),
          body: Center(
            child: Text('You have pressed the button $_count times.'),
          ),
          extendBody: true,
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            child: Container(height: 50.0),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() => _count++),
            tooltip: 'Increment Counter',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
        break;
    }
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 533.33)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: returnWidget,
      ),
    );
  }
}

class ScaffoldDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<ScaffoldDiagram>> get diagrams async => <ScaffoldDiagram>[
    const ScaffoldDiagram(name: _scaffold),
    const ScaffoldDiagram(name: _scaffoldBottomAppBar),
    const ScaffoldDiagram(name: _scaffoldBackgroundColor),
  ];
}

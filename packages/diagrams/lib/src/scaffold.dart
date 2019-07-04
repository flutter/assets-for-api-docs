// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

class ScaffoldDiagram extends StatefulWidget implements DiagramMetadata {
  @override
  final String name = 'scaffold';

  @override
  State<StatefulWidget> createState() => ScaffoldDiagramState();
}

class ScaffoldDiagramState extends State<ScaffoldDiagram> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 533.33)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Sample Code'),
          ),
          body: Center(
            child: Text('You have pressed the button $_count times.'),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              height: 50.0,
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() {
              _count++;
            }),
            tooltip: 'Increment Counter',
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        ),
      ),
    );
  }
}

class ScaffoldDiagramStep extends DiagramStep<ScaffoldDiagram> {
  ScaffoldDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<ScaffoldDiagram>> get diagrams async => <ScaffoldDiagram>[
        ScaffoldDiagram(),
      ];

  @override
  Future<File> generateDiagram(ScaffoldDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

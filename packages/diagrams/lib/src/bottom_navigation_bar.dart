// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class BottomNavigationBarDiagram extends StatelessWidget implements DiagramMetadata {
  const BottomNavigationBarDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(350, 600)),
      child: new Container(
        alignment: FractionalOffset.center,
        //padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('BottomNavigationBar Sample'),
          ),
          body: const Center(
            child: Text(
              'Index 0: Home',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Home'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                title: Text('Business'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                title: Text('School'),
              ),
            ],
            currentIndex: 0,
            selectedItemColor: Colors.amber[800],
            onTap: null,
          ),
        ),
      ),
    );
  }
}

class BottomNavigationBarDiagramStep extends DiagramStep {
  BottomNavigationBarDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const BottomNavigationBarDiagram('bottom_navigation_bar'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final BottomNavigationBarDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

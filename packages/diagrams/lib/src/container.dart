// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

class ContainerDiagram extends StatelessWidget implements DiagramMetadata {
  const ContainerDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    switch(name) {
      case 'container_a' :
        return Container(
          height: 250,
          width: 250,
          color: Colors.white,
          child: Center(
            child: Container(
              margin: EdgeInsets.all(10.0),
              color: Colors.amber[600],
              width: 48.0,
              height: 48.0,
            ),
          ),
        );
        break;
      case 'container_b':
        return Center(
            child: Container(
              constraints: BoxConstraints.expand(
                height:
                Theme.of(context).textTheme.display1.fontSize * 1.1 + 200.0,
              ),
              padding: const EdgeInsets.all(8.0),
              color: Colors.blue[600],
              alignment: Alignment.center,
              child: Text('Hello World',
                  style: Theme.of(context)
                      .textTheme
                      .display1
                      .copyWith(color: Colors.white)),
              transform: Matrix4.rotationZ(0.1),
            ),
          );
        break;
    }
  }
}

class ContainerDiagramStep extends DiagramStep {
  ContainerDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async =>
      <DiagramMetadata>[
        const ContainerDiagram('container_a'),
        const ContainerDiagram('container_b'),
      ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final ContainerDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

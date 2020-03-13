// Copyright 2019 The Chromium Authors. All rights reserved.
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
    switch (name) {
      case 'container_a':
        return Container(
          height: 250,
          width: 250,
          color: Colors.white,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(10.0),
              color: Colors.amber[600],
              width: 48.0,
              height: 48.0,
            ),
          ),
        );
        break;
      case 'container_b':
        return Container(
          height: 250,
          width: 450,
          color: Colors.white,
          child: Center(
            child: Container(
              height: 250,
              width: 450,
              padding: const EdgeInsets.all(8.0),
              color: Colors.blue[600],
              alignment: Alignment.center,
              child: Text('Hello World',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      .copyWith(color: Colors.white)),
              transform: Matrix4.rotationZ(0.1),
            ),
          ),
        );
        break;
      default:
        return const Text('Error');
        break;
    }
  }
}

class ContainerDiagramStep extends DiagramStep<ContainerDiagram> {
  ContainerDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<ContainerDiagram>> get diagrams async => <ContainerDiagram>[
        const ContainerDiagram('container_a'),
        const ContainerDiagram('container_b'),
      ];

  @override
  Future<File> generateDiagram(ContainerDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

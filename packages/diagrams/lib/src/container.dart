// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

class ContainerDiagram extends StatelessWidget with DiagramMetadata {
  const ContainerDiagram(this.name, {super.key});

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
              transform: Matrix4.rotationZ(0.1),
              child: Text(
                'Hello World',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium!.copyWith(color: Colors.white),
              ),
            ),
          ),
        );
      default:
        return const Text('Error');
    }
  }
}

class ContainerDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<ContainerDiagram>> get diagrams async => <ContainerDiagram>[
    const ContainerDiagram('container_a'),
    const ContainerDiagram('container_b'),
  ];
}

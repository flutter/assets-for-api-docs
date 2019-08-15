// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

class PaddingDiagram extends StatelessWidget implements DiagramMetadata {
  const PaddingDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(200, 120)),
      child: Container(
        alignment: FractionalOffset.center,
        color: Colors.grey.shade300,
        child: const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Hello World!'),
          ),
        ),
      ),
    );
  }
}

class PaddingDiagramStep extends DiagramStep<PaddingDiagram> {
  PaddingDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<PaddingDiagram>> get diagrams async => <PaddingDiagram>[
        const PaddingDiagram('padding'),
      ];

  @override
  Future<File> generateDiagram(PaddingDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

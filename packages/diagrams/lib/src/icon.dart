// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

class IconDiagram extends StatelessWidget implements DiagramMetadata {
  const IconDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(140.0, 140.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.pink,
          size: 30.0,
        ),
      ),
    );
  }
}

class IconDiagramStep extends DiagramStep<IconDiagram> {
  IconDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<IconDiagram>> get diagrams async => <IconDiagram>[
        const IconDiagram('icon'),
      ];

  @override
  Future<File> generateDiagram(IconDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

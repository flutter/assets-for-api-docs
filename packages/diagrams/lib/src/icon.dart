// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _icon = 'icon';
const String _icons = 'icons';

class IconDiagram extends StatelessWidget implements DiagramMetadata {
  const IconDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _icons:
        returnWidget = const Icon(
          Icons.favorite,
          color: Colors.purple,
          size: 32.0,
        );
        break;
      case _icon:
      default:
      returnWidget = const Icon(
        Icons.add,
        color: Colors.pink,
        size: 30.0,
      );
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(140.0, 140.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: returnWidget,
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
        const IconDiagram(_icon),
        const IconDiagram(_icons),
      ];

  @override
  Future<File> generateDiagram(IconDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

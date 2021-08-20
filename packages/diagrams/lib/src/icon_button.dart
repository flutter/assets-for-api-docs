// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _iconButton = 'icon_button';
const String _iconButtonBackground = 'icon_button_background';

class IconButtonDiagram extends StatelessWidget implements DiagramMetadata {
  const IconButtonDiagram(this.name, {Key? key}) : super(key: key);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    switch (name) {
      case _iconButton:
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(120, 120)),
          child: Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'Increase volume by 10',
                    onPressed: () {},
                  ),
                  const Text('Volume : 40')
                ],
              ),
            ),
          ),
        );
      case _iconButtonBackground:
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(120.0, 120)),
          child: Material(
            color: Colors.white,
            child: Center(
              child: Ink(
                decoration: const ShapeDecoration(
                  color: Colors.lightBlue,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  icon: const Icon(Icons.android),
                  color: Colors.white,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        );
    }
    assert(name == _iconButton || name == _iconButtonBackground);
    return const SizedBox();
  }
}

class IconButtonDiagramStep extends DiagramStep<IconButtonDiagram> {
  IconButtonDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<IconButtonDiagram>> get diagrams async => <IconButtonDiagram>[
        const IconButtonDiagram(_iconButton),
        const IconButtonDiagram(_iconButtonBackground),
      ];

  @override
  Future<File> generateDiagram(IconButtonDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

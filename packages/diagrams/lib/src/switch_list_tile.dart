// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class SwitchListTileDiagram extends StatefulWidget implements DiagramMetadata {
  const SwitchListTileDiagram(this.name);

  @override
  final String name;

  @override
  _SwitchListTileDiagramState createState() => _SwitchListTileDiagramState();
}

class _SwitchListTileDiagramState extends State<SwitchListTileDiagram> {
  bool _lights = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400.0, 100.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: SwitchListTile(
          title: const Text('Lights'),
          value: _lights,
          onChanged: (bool value) { setState(() { _lights = value; }); },
          secondary: const Icon(Icons.lightbulb_outline),
        ),
      ),
    );
  }
}

class SwitchListTileDiagramStep extends DiagramStep {
  SwitchListTileDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const SwitchListTileDiagram('switch_list_tile'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final SwitchListTileDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'diagram_step.dart';

class CheckboxListTileDiagram extends StatefulWidget implements DiagramMetadata {
  const CheckboxListTileDiagram(this.name);

  @override
  final String name;

  @override
  _CheckboxListTileDiagramState createState() => _CheckboxListTileDiagramState();
}

class _CheckboxListTileDiagramState extends State<CheckboxListTileDiagram> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400.0, 100.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: CheckboxListTile(
          title: const Text('Animate Slowly'),
          value: timeDilation != 1.0,
          onChanged: (bool value) {
            setState(() { timeDilation = value ? 20.0 : 1.0; });
          },
          secondary: const Icon(Icons.hourglass_empty),
        ),
      ),
    );
  }
}

class CheckboxListTileDiagramStep extends DiagramStep {
  CheckboxListTileDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const CheckboxListTileDiagram('checkbox_list_tile'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final CheckboxListTileDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

enum SingingCharacter { lafayette, jefferson }

class RadioListTileDiagram extends StatefulWidget implements DiagramMetadata {
  const RadioListTileDiagram(this.name);

  @override
  final String name;

  @override
  _RadioListTileDiagramState createState() => _RadioListTileDiagramState();
}

class _RadioListTileDiagramState extends State<RadioListTileDiagram> {
  SingingCharacter _character = SingingCharacter.lafayette;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400.0, 140.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            RadioListTile<SingingCharacter>(
              title: const Text('Lafayette'),
              value: SingingCharacter.lafayette,
              groupValue: _character,
              onChanged: (SingingCharacter value) { setState(() { _character = value; }); },
            ),
            RadioListTile<SingingCharacter>(
              title: const Text('Thomas Jefferson'),
              value: SingingCharacter.jefferson,
              groupValue: _character,
              onChanged: (SingingCharacter value) { setState(() { _character = value; }); },
            ),
          ],
        ),
      ),
    );
  }
}

class RadioListTileDiagramStep extends DiagramStep {
  RadioListTileDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const RadioListTileDiagram('radio_list_tile'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final RadioListTileDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

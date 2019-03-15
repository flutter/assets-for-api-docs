// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class AlignDiagram extends StatelessWidget implements DiagramMetadata {
  const AlignDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    List<Widget> diagramChildren;
    const Widget logo = FlutterLogo(size: 60);
    const Icon origin = Icon(
      Icons.fiber_manual_record,
      size: 20
    );
    switch (name) {
      case 'align_constant':
        diagramChildren = <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text('Alignment.topRight'),
          ),
          Container(
            height: 120.0,
            width: 120.0,
            color: Colors.blue[50],
            child: const Align(
              alignment: Alignment.topRight,
              child: logo,
            ),
          ),
        ];
        break;
      case 'align_alignment':
        diagramChildren = <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text('Alignment Origin'),
          ),
          Container(
            height: 120.0,
            width: 120.0,
            color: Colors.blue[50],
            child: Stack(
              children: const <Widget>[
                Align(
                  alignment: Alignment(0.2, 0.6),
                  child: logo,
                ),
                Align(
                  alignment: Alignment.center,
                  child: origin,
                ),
              ],
            ),
          ),
        ];
        break;
      case 'align_fractional_offset':
        diagramChildren = <Widget>[
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0),
            child: Text('Fractional Offset Origin'),
          ),
          Container(
            height: 120.0,
            width: 120.0,
            color: Colors.blue[50],
            child: Stack(
              children: const <Widget>[
                Align(
                  alignment: FractionalOffset(0.2, 0.6),
                  child: logo,
                ),
                origin,
              ],
            ),
          ),
        ];
        break;
      default:
        diagramChildren = <Widget>[const Text('Error')];
        break;
    }
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(250.0, 250.0)),
      child: new Container(
        alignment: FractionalOffset.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: diagramChildren,
        ),
      ),
    );
  }
}

class AlignDiagramStep extends DiagramStep {
  AlignDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
        const AlignDiagram('align_constant'),
        const AlignDiagram('align_alignment'),
        const AlignDiagram('align_fractional_offset'),
      ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final AlignDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

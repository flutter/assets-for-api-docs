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
    const Widget logo = FlutterLogo(size: 60);
    const Icon origin = Icon(
      Icons.gps_fixed,
      size: 20,
    );
    Widget heading;
    Widget containerChild;
    switch (name) {
      case 'align_constant':
        heading = Text(Alignment.topRight.toString());
        containerChild = const Align(
          alignment: Alignment.topRight,
          child: logo,
        );
        break;
      case 'align_alignment':
        heading = const Text('Alignment Origin');
        containerChild = Stack(
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
        );

        break;
      case 'align_fractional_offset':
        heading = const Text('Fractional Offset Origin');
        containerChild = Stack(
          children: const <Widget>[
            Align(
              alignment: FractionalOffset(0.2, 0.6),
              child: logo,
            ),
            Align(
              alignment: FractionalOffset(-0.1, -0.1),
              child: origin,
            ),
          ],
        );
        break;
      default:
        heading = const Text('Error');
        containerChild = const Text('Error');
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
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: heading,
            ),
            Container(
                height: 120.0,
                width: 120.0,
                color: Colors.blue[50],
                child: containerChild),
          ],
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

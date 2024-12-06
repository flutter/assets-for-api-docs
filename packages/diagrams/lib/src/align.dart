// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

class AlignDiagram extends StatelessWidget with DiagramMetadata {
  const AlignDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    const Widget logo = FlutterLogo(size: 60);
    const Icon origin = Icon(Icons.gps_fixed, size: 20);
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
        containerChild = const Stack(
          children: <Widget>[
            Align(alignment: Alignment(0.2, 0.6), child: logo),
            Align(child: origin),
          ],
        );

        break;
      case 'align_fractional_offset':
        heading = const Text('Fractional Offset Origin');
        containerChild = const Stack(
          children: <Widget>[
            Align(alignment: FractionalOffset(0.2, 0.6), child: logo),
            Align(alignment: FractionalOffset(-0.1, -0.1), child: origin),
          ],
        );
        break;
      default:
        heading = const Text('Error');
        containerChild = const Text('Error');
        break;
    }
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(250.0, 250.0)),
      child: Container(
        alignment: FractionalOffset.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: heading,
            ),
            Container(
              height: 120.0,
              width: 120.0,
              color: Colors.blue[50],
              child: containerChild,
            ),
          ],
        ),
      ),
    );
  }
}

class AlignDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<AlignDiagram>> get diagrams async => <AlignDiagram>[
    const AlignDiagram('align_constant'),
    const AlignDiagram('align_alignment'),
    const AlignDiagram('align_fractional_offset'),
  ];
}

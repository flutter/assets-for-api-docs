// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';

abstract class ShapeDiagram extends StatelessWidget implements DiagramMetadata {
  @override
  String get name;
}

class SubShapeDiagram extends ShapeDiagram {
  SubShapeDiagram(
    this.name,
    this.shapeBorder,
    this.width,
    this.height
  );

  @override
  final String name;
  final ShapeBorder shapeBorder;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Material(
        color: Colors.blueAccent[400],
        shape: shapeBorder,
        child: SizedBox(
          width: width,
          height: height,
        ),
      ),
    );
  }
}

class ColorsDiagramStep extends DiagramStep {
  ColorsDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.addAll(<ShapeDiagram>[
      new SubShapeDiagram('Shape.circle', CircleBorder(), 400, 400),
      new SubShapeDiagram('Shape.rectangle', RoundedRectangleBorder(), 400, 400),
      new SubShapeDiagram(
        'Shape.rounded_rectangle',
        RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
              Radius.circular(100.0)
          )
        ),
        400,
        400,
      ),
      new SubShapeDiagram('Shape.stadium', StadiumBorder(), 400, 200),
      new SubShapeDiagram('Shape.continuous_rectangle',
        ContinuousRectangleBorder(
          borderRadius: 100
        ),
        400,
        400,
      ),
      new SubShapeDiagram('Shape.continuous_stadium', ContinuousStadiumBorder(), 100, 100),
      new SubShapeDiagram('Shape.beveled_rectangle',
        BeveledRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(100.0)
          )
        ),
        100,
        100,
      ),
    ]);
  }

  @override
  final String category = 'material';

  final List<ShapeDiagram> _diagrams = <ShapeDiagram>[];

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final ShapeDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

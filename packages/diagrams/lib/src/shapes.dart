// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';

class ShapeDiagram extends StatelessWidget implements DiagramMetadata {
  const ShapeDiagram({
    Key key,
    this.name,
    this.shapeBorder,
    this.width,
    this.height
  }) : super(key: key);

  @override
  final String name;
  final ShapeBorder shapeBorder;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    const double padding = 50.0;
    return Container(
      height: height + padding,
      width: width + padding,
      alignment: Alignment.center,
      child: Material(
        color: Colors.blue,
        shape: shapeBorder,
        child: SizedBox(
          width: width,
          height: height,
        ),
      ),
    );
  }
}

class ShapeDiagramStep extends DiagramStep {
  ShapeDiagramStep(DiagramController controller) : super(controller) {
    const String circleName = 'Shape.circle';
    const String rectangleName = 'Shape.rectangle';
    const String roundedRectangleName = 'Shape.rounded_rectangle';
    const String stadiumName = 'Shape.stadium';
    const String continuousRectangleName = 'Shape.continuous_rectangle';
    const String continuousStadiumName = 'Shape.continuous_stadium';
    const String beveledRectangleName = 'Shape.beveled_rectangle';

    const double width = 200.0;
    const double height = 200.0;
    const double radius = 75.0;

    _diagrams.addAll(<ShapeDiagram>[
      ShapeDiagram(
        name: circleName,
        shapeBorder: CircleBorder(),
        width: width,
        height: height,
        key: const ValueKey<String>(circleName),
      ),
      ShapeDiagram(
        name: rectangleName,
        shapeBorder: RoundedRectangleBorder(),
        width: width,
        height: height,
        key: const ValueKey<String>(rectangleName),
      ),
      ShapeDiagram(
        name: roundedRectangleName,
        shapeBorder: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(radius)
          )
        ),
        width: width,
        height: height,
        key: const ValueKey<String>(roundedRectangleName),
      ),
      ShapeDiagram(
        name: stadiumName,
        shapeBorder: StadiumBorder(),
        width: width,
        height: height / 2,
        key: const ValueKey<String>(stadiumName),
      ),
      ShapeDiagram(
        name: continuousRectangleName,
        shapeBorder: ContinuousRectangleBorder(
          borderRadius: radius,
        ),
        width: width,
        height: height,
        key: const ValueKey<String>(continuousRectangleName),
      ),
       ShapeDiagram(
         name: continuousStadiumName,
         shapeBorder: ContinuousStadiumBorder(),
         width: width,
         height: height / 2,
         key: const ValueKey<String>(continuousStadiumName),
       ),
       ShapeDiagram(
         name: beveledRectangleName,
         shapeBorder: BeveledRectangleBorder(
           borderRadius: const BorderRadius.all(
             Radius.circular(radius)
           )
         ),
         width: width,
         height: height,
         key: const ValueKey<String>(beveledRectangleName),
      ),
    ]);
  }

  @override
  final String category = 'painting';

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

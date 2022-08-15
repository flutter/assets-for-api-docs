// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

class AdjustDragOffsetDiagram extends StatelessWidget
    implements DiagramMetadata {
  const AdjustDragOffsetDiagram({super.key});

  @override
  String get name => 'adjust_drag_offset';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      height: 600,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: const Color(0xffb5e8f7),
              border: Border.all(width: 5),
            ),
            width: 300,
            height: 150,
            child: const Center(
              child: Text(
                'Target Rectangle',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          const Positioned(
            top: 206.5,
            left: 546,
            child:
                Text('- - - - - - - - - - - -', style: TextStyle(fontSize: 30)),
          ),
          const Positioned(
            top: 353,
            right: 545,
            child:
                Text('- - - - - - - - - - - -', style: TextStyle(fontSize: 30)),
          ),
          const Positioned(
            top: 100,
            left: 100,
            child: Text('Area 1', style: TextStyle(fontSize: 30)),
          ),
          const Positioned(
            top: 480,
            left: 650,
            child: Text('Area 2', style: TextStyle(fontSize: 30)),
          ),
        ],
      ),
    );
  }
}

class AdjustDragOffsetDiagramStep extends DiagramStep<AdjustDragOffsetDiagram> {
  AdjustDragOffsetDiagramStep(super.controller);

  @override
  final String category = 'rendering';

  @override
  Future<List<AdjustDragOffsetDiagram>> get diagrams async =>
      const <AdjustDragOffsetDiagram>[AdjustDragOffsetDiagram()];

  @override
  Future<File> generateDiagram(AdjustDragOffsetDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

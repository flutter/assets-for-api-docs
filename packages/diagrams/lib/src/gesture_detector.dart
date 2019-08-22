// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

const String _gestureDetector = 'gesture_detector';
const Duration _pauseDuration = Duration(seconds: 1);
final Duration _totalDuration = _pauseDuration + _pauseDuration;
final GlobalKey _gestureDetectorKey = GlobalKey();

class GestureDetectorDiagram extends StatefulWidget implements DiagramMetadata {
  const GestureDetectorDiagram(this.name);

  @override
  final String name;

  @override
  _GestureDetectorDiagramState createState() => _GestureDetectorDiagramState();
}

class _GestureDetectorDiagramState extends State<GestureDetectorDiagram> {
  bool _lights = false;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(200, 150)),
      child: Container(
        alignment: FractionalOffset.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.lightbulb_outline,
                color: _lights ? Colors.yellow.shade600 : Colors.black,
                size: 60,
              ),
            ),
            GestureDetector(
              key: _gestureDetectorKey,
              onTap: () {
                setState(() {
                  _lights = true;
                });
              },
              child: Container(
                color: Colors.yellow.shade600,
                padding: const EdgeInsets.all(8),
                child: const Text('TURN LIGHTS ON'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GestureDetectorDiagramStep extends DiagramStep<GestureDetectorDiagram> {
  GestureDetectorDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<GestureDetectorDiagram>> get diagrams async =>
      <GestureDetectorDiagram>[
        const GestureDetectorDiagram(_gestureDetector),
      ];

  @override
  Future<File> generateDiagram(GestureDetectorDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    controller.advanceTime(Duration.zero);

    final Future<File> result = controller.drawAnimatedDiagramToFiles(
      end: _totalDuration,
      frameRate: 60,
      name: diagram.name,
      category: category,
    );

    await Future<void>.delayed(_pauseDuration);

    final RenderBox target = _gestureDetectorKey.currentContext.findRenderObject();
    final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await gesture.up();

    await Future<void>.delayed(_pauseDuration);

    return result;
  }
}

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

final Duration _kTotalDuration = _kBreakDuration +
    _kAnimationDuration +
    _kBreakDuration +
    _kAnimationDuration;
const Duration _kAnimationDuration = Duration(seconds: 3);
const Duration _kBreakDuration = Duration(seconds: 1, milliseconds: 500);

const double _kCurveAnimationFrameRate = 60.0;

class AnimationStatusValueDiagram extends StatefulWidget
    implements DiagramMetadata {
  const AnimationStatusValueDiagram();

  @override
  State<AnimationStatusValueDiagram> createState() =>
      AnimationStatusValueDiagramState();

  @override
  String get name => 'animation_status_value';
}

class AnimationStatusValueDiagramState
    extends State<AnimationStatusValueDiagram>
    with TickerProviderStateMixin<AnimationStatusValueDiagram> {
  AnimationController _controller;
  String _status = 'dismissed';

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: _kAnimationDuration);
    Timer(_kBreakDuration, () {
      _controller.forward();
    });
    _controller
      ..addStatusListener((AnimationStatus status) {
        switch (status) {
          case AnimationStatus.dismissed:
            _status = 'dismissed';
            break;
          case AnimationStatus.forward:
            _status = 'forward';
            break;
          case AnimationStatus.reverse:
            _status = 'reverse';
            break;
          case AnimationStatus.completed:
            _status = 'completed';
            Timer(_kBreakDuration, () {
              _controller.reverse();
            });
            break;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 420,
      color: Colors.white,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget _) {
            return Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(180),
                1: FixedColumnWidth(120),
                2: FixedColumnWidth(100),
              },
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    Center(
                      child: Text(
                        _status,
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                    Center(
                      child: Text(
                        _controller.value.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 26),
                      ),
                    ),
                    Center(
                      child: Opacity(
                        opacity: _controller.value,
                        child: Container(
                          height: 35,
                          width: 35,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const TableRow(
                  children: <Widget>[
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text('Animation.status'),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text('Animation.value'),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Text('as Opacity'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AnimationStatusValueDiagramStep
    extends DiagramStep<AnimationStatusValueDiagram> {
  AnimationStatusValueDiagramStep(DiagramController controller)
      : super(controller);

  @override
  final String category = 'animation';

  @override
  Future<List<AnimationStatusValueDiagram>> get diagrams async => const <AnimationStatusValueDiagram>[
        AnimationStatusValueDiagram(),
      ];

  @override
  Future<File> generateDiagram(AnimationStatusValueDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kCurveAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
  }
}

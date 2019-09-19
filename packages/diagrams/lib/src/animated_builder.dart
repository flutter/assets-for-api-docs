// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const Duration _kTotalDuration = Duration(seconds: 10);
const double _kCurveAnimationFrameRate = 60.0;

class AnimatedBuilderDiagram extends StatefulWidget implements DiagramMetadata {
  const AnimatedBuilderDiagram();

  @override
  State<AnimatedBuilderDiagram> createState() => AnimatedBuilderDiagramState();

  @override
  String get name => 'animated_builder';
}

class AnimatedBuilderDiagramState extends State<AnimatedBuilderDiagram> with TickerProviderStateMixin<AnimatedBuilderDiagram> {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _kTotalDuration)
      ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: 300,
      color: Colors.white,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          child: Container(
            width: 200.0,
            height: 200.0,
            color: Colors.green,
            child: const Center(
              child: Text('Wee'),
            ),
          ),
          builder: (BuildContext context, Widget child) {
            return Transform.rotate(
              angle: _controller.value * 2.0 * math.pi,
              child: child,
            );
          },
        ),
      ),
    );
  }
}

class AnimatedBuilderDiagramStep extends DiagramStep<AnimatedBuilderDiagram> {
  AnimatedBuilderDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<AnimatedBuilderDiagram>> get diagrams async => const <AnimatedBuilderDiagram>[
        AnimatedBuilderDiagram(),
      ];

  @override
  Future<File> generateDiagram(AnimatedBuilderDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kCurveAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
  }
}

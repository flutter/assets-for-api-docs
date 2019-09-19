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
const Duration _kAnimationDuration = Duration(seconds: 6);
const Duration _kBreakDuration = Duration(seconds: 1, milliseconds: 500);

const double _kCurveAnimationFrameRate = 60.0;

class TweenSequenceDiagram extends StatefulWidget implements DiagramMetadata {
  const TweenSequenceDiagram();

  @override
  State<TweenSequenceDiagram> createState() => TweenSequenceDiagramState();

  @override
  String get name => 'tween_sequence';
}

class TweenSequenceDiagramState extends State<TweenSequenceDiagram>
    with TickerProviderStateMixin<TweenSequenceDiagram> {
  AnimationController _controller;
  int _activeItem = 0;

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
          case AnimationStatus.forward:
          case AnimationStatus.reverse:
            break;
          case AnimationStatus.completed:
            Timer(_kBreakDuration, () {
              _controller.reverse();
            });
            break;
        }
      })
      ..addListener(() {
        if (_controller.value == 1.0 || _controller.value == 0.0) {
          _activeItem = 0;
        } else if (_controller.value < 0.4) {
          _activeItem = 1;
        } else if (_controller.value < 0.6) {
          _activeItem = 2;
        } else if (_controller.value < 1.0) {
          _activeItem = 3;
        } else {
          assert(false);
        }
      });
  }

  final Animatable<Color> _tweenSequence =
      TweenSequence<Color>(<TweenSequenceItem<Color>>[
    TweenSequenceItem<Color>(
      tween: ColorTween(begin: Colors.yellow, end: Colors.green),
      weight: 2,
    ),
    TweenSequenceItem<Color>(
      tween: ConstantTween<Color>(Colors.green),
      weight: 1,
    ),
    TweenSequenceItem<Color>(
      tween: ColorTween(begin: Colors.green, end: Colors.red),
      weight: 2,
    ),
  ]);

  final TextStyle _activeStyle = TextStyle(color: Colors.blue[800]);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: 646,
      color: Colors.white,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget _) {
            return Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(16),
                    width: 200,
                    height: 200,
                    color: _tweenSequence.evaluate(_controller),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('TweenSequence(['),
                      Text(
                        '    TweenSequenceItem(\n        tween: ColorTween(begin: Colors.yellow, end: Colors.green),\n        weight: 2,\n    ),',
                        style: _activeItem == 1 ? _activeStyle : null,
                      ),
                      Text(
                        '    TweenSequenceItem(\n        tween: ConstantTween(Colors.green),\n        weight: 1,\n    ),',
                        style: _activeItem == 2 ? _activeStyle : null,
                      ),
                      Text(
                        '    TweenSequenceItem(\n        tween: ColorTween(begin: Colors.green, end: Colors.red),\n        weight: 2,\n    ),',
                        style: _activeItem == 3 ? _activeStyle : null,
                      ),
                      const Text(']);'),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class TweenSequenceDiagramStep extends DiagramStep<TweenSequenceDiagram> {
  TweenSequenceDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'animation';

  @override
  Future<List<TweenSequenceDiagram>> get diagrams async =>
      <TweenSequenceDiagram>[
        const TweenSequenceDiagram(),
      ];

  @override
  Future<File> generateDiagram(TweenSequenceDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kCurveAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
  }
}

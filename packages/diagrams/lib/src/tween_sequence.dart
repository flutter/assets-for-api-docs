// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import '../diagrams.dart';

final Duration _kTotalDuration =
    _kBreakDuration +
    _kAnimationDuration +
    _kBreakDuration +
    _kAnimationDuration;
const Duration _kAnimationDuration = Duration(seconds: 6);
const Duration _kBreakDuration = Duration(seconds: 1, milliseconds: 500);

class TweenSequenceDiagram extends StatefulWidget with DiagramMetadata {
  const TweenSequenceDiagram({super.key});

  @override
  State<TweenSequenceDiagram> createState() => TweenSequenceDiagramState();

  @override
  String get name => 'tween_sequence';

  @override
  Duration? get duration => _kTotalDuration;
}

class TweenSequenceDiagramState extends State<TweenSequenceDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  late AnimationController _controller;
  int _activeItem = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _kAnimationDuration,
    );

    waitLockstep(_kBreakDuration).then((_) => _controller.forward());
    waitLockstep(
      _kBreakDuration + _kAnimationDuration + _kBreakDuration,
    ).then((_) => _controller.reverse());

    _controller.addListener(() {
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

  final Animatable<Color?> _tweenSequence =
      TweenSequence<Color?>(<TweenSequenceItem<Color?>>[
        TweenSequenceItem<Color?>(
          tween: ColorTween(begin: Colors.yellow, end: Colors.green),
          weight: 2,
        ),
        TweenSequenceItem<Color?>(
          tween: ConstantTween<Color>(Colors.green),
          weight: 1,
        ),
        TweenSequenceItem<Color?>(
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
          builder: (BuildContext context, Widget? child) {
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(16),
                    width: 200,
                    height: 200,
                    color: _tweenSequence.evaluate(_controller),
                  ),
                  DefaultTextStyle(
                    style: DefaultTextStyle.of(
                      context,
                    ).style.copyWith(height: 1.2, fontSize: 13.0),
                    child: Column(
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

class TweenSequenceDiagramStep extends DiagramStep {
  @override
  final String category = 'animation';

  @override
  Future<List<TweenSequenceDiagram>> get diagrams async =>
      <TweenSequenceDiagram>[const TweenSequenceDiagram()];
}

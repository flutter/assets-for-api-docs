// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import '../diagrams.dart';

final Duration _kTotalDuration = _kBreakDuration +
    _kAnimationDuration +
    _kBreakDuration +
    _kAnimationDuration;
const Duration _kAnimationDuration = Duration(seconds: 3);
const Duration _kBreakDuration = Duration(seconds: 1, milliseconds: 500);

class AnimationStatusValueDiagram extends StatefulWidget with DiagramMetadata {
  const AnimationStatusValueDiagram({super.key});

  @override
  State<AnimationStatusValueDiagram> createState() =>
      AnimationStatusValueDiagramState();

  @override
  String get name => 'animation_status_value';

  @override
  Duration? get duration => _kTotalDuration;
}

class AnimationStatusValueDiagramState
    extends State<AnimationStatusValueDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  late AnimationController _controller;
  String _status = 'dismissed';

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: _kAnimationDuration);
    waitLockstep(_kBreakDuration).then((_) => _controller.forward());
    waitLockstep(
      _kBreakDuration + _kAnimationDuration + _kBreakDuration,
    ).then((_) => _controller.reverse());
    _controller.addStatusListener((AnimationStatus status) {
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
          break;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          builder: (BuildContext context, Widget? _) {
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

class AnimationStatusValueDiagramStep extends DiagramStep {
  @override
  final String category = 'animation';

  @override
  Future<List<AnimationStatusValueDiagram>> get diagrams async =>
      const <AnimationStatusValueDiagram>[
        AnimationStatusValueDiagram(),
      ];
}

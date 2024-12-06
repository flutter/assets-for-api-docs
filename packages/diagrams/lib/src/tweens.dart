// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import '../diagrams.dart';

const Duration _kBreakDuration = Duration(seconds: 1, milliseconds: 500);
const Duration _kAnimationDuration = Duration(seconds: 3);

final Duration _kTotalDuration =
    _kBreakDuration +
    _kAnimationDuration +
    _kBreakDuration +
    _kAnimationDuration;

class TweensDiagram extends StatefulWidget with DiagramMetadata {
  const TweensDiagram({super.key});

  @override
  State<TweensDiagram> createState() => TweensDiagramState();

  @override
  String get name => 'tweens';

  @override
  Duration? get duration => _kTotalDuration;
}

class TweensDiagramState extends State<TweensDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  late AnimationController _controller;

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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 530,
      color: Colors.white,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) {
            return Center(
              child: Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(120),
                  1: FixedColumnWidth(120),
                  2: FixedColumnWidth(140),
                  3: FixedColumnWidth(140),
                },
                children: <TableRow>[
                  TableRow(
                    children: <Widget>[
                      Center(
                        child: Text(
                          _controller.value.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                      Center(
                        child: Text(
                          IntTween(
                            begin: 45,
                            end: 65,
                          ).evaluate(_controller).toString(),
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                      Center(
                        child: Text(
                          Tween<double>(
                            begin: 100.0,
                            end: 200.0,
                          ).evaluate(_controller).toStringAsFixed(1),
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                      Center(
                        child: Container(
                          height: 35,
                          width: 35,
                          color: ColorTween(
                            begin: Colors.red,
                            end: Colors.green,
                          ).evaluate(_controller),
                        ),
                      ),
                    ],
                  ),
                  const TableRow(
                    children: <Widget>[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text('Animation.value'),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'IntTween(\n  begin: 45,\n  end: 65,\n);',
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'Tween<double>(\n  begin: 100.0,\n  end: 200.0,\n);',
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'ColorTween(\n  begin: Colors.red,\n  end: Colors.green,\n);',
                          ),
                        ),
                      ),
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

class TweensDiagramStep extends DiagramStep {
  @override
  final String category = 'animation';

  @override
  Future<List<DiagramMetadata>> get diagrams async {
    return const <TweensDiagram>[TweensDiagram()];
  }
}

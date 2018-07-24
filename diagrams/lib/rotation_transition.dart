// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

final GlobalKey transitionKey = new GlobalKey();

const Duration _kAnimationDuration = const Duration(milliseconds: 2500);
const double _kAnimationFrameRate = 60.0;

class RotationTransitionExample extends StatefulWidget {
  const RotationTransitionExample({Key key, this.selected, this.onTap}) : super(key: key);

  final ValueChanged<bool> onTap;
  final bool selected;

  @override
  RotationTransitionExampleState createState() {
    return new RotationTransitionExampleState();
  }
}

class RotationTransitionExampleState extends State<RotationTransitionExample>
    with TickerProviderStateMixin<RotationTransitionExample> {
  AnimationController _controller;
  Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    _rotationAnimation = new CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void didUpdateWidget(RotationTransitionExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) {
      return;
    }
    widget.selected ? _controller.forward() : _controller.reverse();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onTap(!widget.selected);
        });
      },
      child: Container(
        width: 250.0,
        height: 250.0,
        color: const Color(0xffffffff),
        padding: const EdgeInsets.all(50.0),
        child: new RotationTransition(
          key: transitionKey,
          turns: _rotationAnimation,
          child: const Padding(
            padding: const EdgeInsets.all(8.0),
            child: const FlutterLogo(size: 150.0),
          ),
        ),
      ),
    );
  }
}

class RotationTransitionDiagram extends StatefulWidget implements DiagramMetadata {
  @override
  String get name => 'rotation_transition';

  @override
  RotationTransitionDiagramState createState() {
    return new RotationTransitionDiagramState();
  }
}

class RotationTransitionDiagramState extends State<RotationTransitionDiagram> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return new RotationTransitionExample(
      selected: selected,
      onTap: (bool value) {
        setState(() {
          selected = value;
        });
      },
    );
  }
}

class RotationTransitionDiagramStep extends DiagramStep {
  RotationTransitionDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(new RotationTransitionDiagram());
  }

  final List<RotationTransitionDiagram> _diagrams = <RotationTransitionDiagram>[];

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final RotationTransitionDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;

    final RenderBox target = transitionKey.currentContext.findRenderObject();
    final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await gesture.up();
    final File result = await controller.drawAnimatedDiagramToFiles(
      end: _kAnimationDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
    return result;
  }
}

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

const Duration _kAnimationDuration = const Duration(seconds: 2);
const double _kAnimationFrameRate = 60.0;

class SizeTransitionExample extends StatefulWidget {
  const SizeTransitionExample({Key key, this.selected, this.onTap}) : super(key: key);

  final ValueChanged<bool> onTap;
  final bool selected;

  @override
  SizeTransitionExampleState createState() {
    return new SizeTransitionExampleState();
  }
}

class SizeTransitionExampleState extends State<SizeTransitionExample>
    with TickerProviderStateMixin<SizeTransitionExample> {
  AnimationController _controller;
  Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
      value: 1.0,
    )..addListener(() {
        setState(() {});
      });
    _sizeAnimation = new CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(SizeTransitionExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) {
      return;
    }
    widget.selected ? _controller.reverse() : _controller.forward();
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
        child: Center(
          child: new SizeTransition(
            key: transitionKey,
            axis: Axis.vertical,
            axisAlignment: 0.0,
            sizeFactor: _sizeAnimation,
            child: const Padding(
              padding: const EdgeInsets.all(8.0),
              child: const FlutterLogo(size: 150.0),
            ),
          ),
        ),
      ),
    );
  }
}

class SizeTransitionDiagram extends StatefulWidget implements DiagramMetadata {
  @override
  String get name => 'size_transition';

  @override
  SizeTransitionDiagramState createState() {
    return new SizeTransitionDiagramState();
  }
}

class SizeTransitionDiagramState extends State<SizeTransitionDiagram> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return new SizeTransitionExample(
      selected: selected,
      onTap: (bool value) {
        setState(() {
          selected = value;
        });
      },
    );
  }
}

class SizeTransitionDiagramStep extends DiagramStep {
  SizeTransitionDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(new SizeTransitionDiagram());
  }

  final List<SizeTransitionDiagram> _diagrams = <SizeTransitionDiagram>[];

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final SizeTransitionDiagram typedDiagram = diagram;
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

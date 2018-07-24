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

class FadeTransitionExample extends StatefulWidget {
  const FadeTransitionExample({Key key, this.selected, this.onTap}) : super(key: key);

  final ValueChanged<bool> onTap;
  final bool selected;

  @override
  FadeTransitionExampleState createState() {
    return new FadeTransitionExampleState();
  }
}

class FadeTransitionExampleState extends State<FadeTransitionExample>
    with TickerProviderStateMixin<FadeTransitionExample> {
  AnimationController _controller;
  Animation<double> _fadeAnimation;

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
    _fadeAnimation = new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void didUpdateWidget(FadeTransitionExample oldWidget) {
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
        child: new FadeTransition(
          key: transitionKey,
          opacity: _fadeAnimation,
          child: const Padding(
            padding: const EdgeInsets.all(8.0),
            child: const FlutterLogo(size: 150.0),
          ),
        ),
      ),
    );
  }
}

class FadeTransitionDiagram extends StatefulWidget implements DiagramMetadata {
  @override
  String get name => 'fade_transition';

  @override
  FadeTransitionDiagramState createState() {
    return new FadeTransitionDiagramState();
  }
}

class FadeTransitionDiagramState extends State<FadeTransitionDiagram> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return new FadeTransitionExample(
      selected: selected,
      onTap: (bool value) {
        setState(() {
          selected = value;
        });
      },
    );
  }
}

class FadeTransitionDiagramStep extends DiagramStep {
  FadeTransitionDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(new FadeTransitionDiagram());
  }

  final List<FadeTransitionDiagram> _diagrams = <FadeTransitionDiagram>[];

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final FadeTransitionDiagram typedDiagram = diagram;
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

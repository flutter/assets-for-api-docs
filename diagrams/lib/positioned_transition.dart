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

class PositionedTransitionExample extends StatefulWidget {
  const PositionedTransitionExample({Key key, this.selected, this.onTap}) : super(key: key);

  final ValueChanged<bool> onTap;
  final bool selected;

  @override
  PositionedTransitionExampleState createState() {
    return new PositionedTransitionExampleState();
  }
}

class PositionedTransitionExampleState extends State<PositionedTransitionExample>
    with TickerProviderStateMixin<PositionedTransitionExample> {
  static final RelativeRectTween _relativeRectTween = new RelativeRectTween(
    begin: const RelativeRect.fromLTRB(10.0, 10.0, 150.0, 150.0),
    end: const RelativeRect.fromLTRB(100.0, 100.0, 10.0, 10.0),
  );

  AnimationController _controller;
  Animation<RelativeRect> _rectAnimation;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
      value: 0.0,
    )..addListener(() {
        setState(() {});
      });
    _rectAnimation = _relativeRectTween.animate(
      new CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(PositionedTransitionExample oldWidget) {
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
    print('Animation: ${_rectAnimation.value}');
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onTap(!widget.selected);
        });
      },
      child: Container(
        key: transitionKey,
        width: 250.0,
        height: 250.0,
        color: const Color(0xffffffff),
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: Stack(
            children: <Widget>[
              new Container(color: const Color(0xffffffff), width: 250.0, height: 250.0),
              new PositionedTransition(
                rect: _rectAnimation,
                child: const FlutterLogo(size: 50.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PositionedTransitionDiagram extends StatefulWidget implements DiagramMetadata {
  @override
  String get name => 'positioned_transition';

  @override
  PositionedTransitionDiagramState createState() {
    return new PositionedTransitionDiagramState();
  }
}

class PositionedTransitionDiagramState extends State<PositionedTransitionDiagram> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return new PositionedTransitionExample(
      selected: selected,
      onTap: (bool value) {
        setState(() {
          selected = value;
        });
      },
    );
  }
}

class PositionedTransitionDiagramStep extends DiagramStep {
  PositionedTransitionDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(new PositionedTransitionDiagram());
  }

  final List<PositionedTransitionDiagram> _diagrams = <PositionedTransitionDiagram>[];

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final PositionedTransitionDiagram typedDiagram = diagram;
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

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

final GlobalKey _transitionKey = new GlobalKey();

const Duration _kAnimationDuration = const Duration(milliseconds: 2500);
const double _kAnimationFrameRate = 60.0;

class RotationTransitionExample extends TransitionDiagram<double, RotationTransitionExample> {
  RotationTransitionExample({Key key})
      : super(
          key: key,
          animationBuilder: (AnimationController controller) {
            return new CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            );
          },
        );

  @override
  String get name => 'rotation_transition';

  @override
  RotationTransitionExampleState createState() {
    return new RotationTransitionExampleState();
  }
}

class RotationTransitionExampleState extends TransitionDiagramState<double, RotationTransitionExample> {
  @override
  Widget build(BuildContext context) {
    return wrap(
      context,
      new RotationTransition(
        key: _transitionKey,
        turns: animation,
        child: const Padding(
          padding: const EdgeInsets.all(8.0),
          child: const FlutterLogo(size: 150.0),
        ),
      ),
    );
  }
}

class SizeTransitionExample extends TransitionDiagram<double, SizeTransitionExample> {
  SizeTransitionExample({Key key})
      : super(
          key: key,
          animationBuilder: (AnimationController controller) {
            return new CurvedAnimation(
              parent: controller,
              curve: Curves.fastOutSlowIn,
            );
          },
        );

  @override
  String get name => 'size_transition';

  @override
  SizeTransitionExampleState createState() {
    return new SizeTransitionExampleState();
  }
}

class SizeTransitionExampleState extends TransitionDiagramState<double, SizeTransitionExample> {
  @override
  Widget build(BuildContext context) {
    return wrap(
      context,
      Center(
        child: new SizeTransition(
          key: _transitionKey,
          axis: Axis.vertical,
          axisAlignment: 0.0,
          sizeFactor: animation,
          child: const Padding(
            padding: const EdgeInsets.all(8.0),
            child: const FlutterLogo(size: 150.0),
          ),
        ),
      ),
    );
  }
}

typedef AnimationBuilder<T> = Animation<T> Function(AnimationController controller);

abstract class TransitionDiagram<E, T extends Widget> extends StatefulWidget implements DiagramMetadata {
  const TransitionDiagram({
    Key key,
    @required this.animationBuilder,
  }) : super(key: key);

  final AnimationBuilder<E> animationBuilder;
}

abstract class TransitionDiagramState<E, T extends Widget> extends State<TransitionDiagram<E, T>> //
    with
        TickerProviderStateMixin<TransitionDiagram<E, T>> {
  bool selected = false;
  Animation<E> animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    animation = widget.animationBuilder(_controller);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget wrap(BuildContext context, Widget child) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selected = !selected;
          selected ? _controller.forward() : _controller.reverse();
        });
      },
      child: Container(
        width: 250.0,
        height: 250.0,
        color: const Color(0xffffffff),
        padding: const EdgeInsets.all(25.0),
        child: child,
      ),
    );
  }
}

class TransitionDiagramStep extends DiagramStep {
  TransitionDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(new RotationTransitionExample());
    _diagrams.add(new SizeTransitionExample());
  }

  final List<TransitionDiagram<dynamic, Widget>> _diagrams = <TransitionDiagram<dynamic, Widget>>[];

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final TransitionDiagram<dynamic, Widget> typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;

    final RenderBox target = _transitionKey.currentContext.findRenderObject();
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

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

const Duration _kAnimationDuration = const Duration(seconds: 1);
const double _kAnimationFrameRate = 60.0;

class DecoratedBoxTransitionExample extends StatefulWidget {
  const DecoratedBoxTransitionExample({Key key, this.selected, this.onTap}) : super(key: key);

  final ValueChanged<bool> onTap;
  final bool selected;

  @override
  DecoratedBoxTransitionExampleState createState() {
    return new DecoratedBoxTransitionExampleState();
  }
}

class DecoratedBoxTransitionExampleState extends State<DecoratedBoxTransitionExample>
    with TickerProviderStateMixin<DecoratedBoxTransitionExample> {
  static const BorderRadius _beginRadius = const BorderRadius.all(const Radius.circular(50.0));
  static const BorderRadius _endRadius = const BorderRadius.all(const Radius.circular(0.0));

  AnimationController _controller;
  Animation<Decoration> _decorationAnimation;

  final DecorationTween _decorationTween = new DecorationTween(
    begin: new BoxDecoration(
      borderRadius: _beginRadius,
      color: const Color(0xffffffff),
      boxShadow: kElevationToShadow[8],
    ),
    end: const BoxDecoration(
      borderRadius: _endRadius,
      color: const Color(0xffffffff),
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });
    _decorationAnimation = _decorationTween.animate(
      new CurvedAnimation(
        parent: _controller,
        curve: Curves.decelerate,
      ),
    );
  }

  @override
  void didUpdateWidget(DecoratedBoxTransitionExample oldWidget) {
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
        child: new DecoratedBoxTransition(
          key: transitionKey,
          decoration: _decorationAnimation,
          child: const Padding(
            padding: const EdgeInsets.all(8.0),
            child: const FlutterLogo(size: 150.0),
          ),
        ),
      ),
    );
  }
}

class DecoratedBoxTransitionDiagram extends StatefulWidget implements DiagramMetadata {
  @override
  String get name => 'decorated_box_transition';

  @override
  DecoratedBoxTransitionDiagramState createState() {
    return new DecoratedBoxTransitionDiagramState();
  }
}

class DecoratedBoxTransitionDiagramState extends State<DecoratedBoxTransitionDiagram> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    return new DecoratedBoxTransitionExample(
      selected: selected,
      onTap: (bool value) {
        setState(() {
          selected = value;
        });
      },
    );
  }
}

class DecoratedBoxTransitionDiagramStep extends DiagramStep {
  DecoratedBoxTransitionDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(new DecoratedBoxTransitionDiagram());
  }

  final List<DecoratedBoxTransitionDiagram> _diagrams = <DecoratedBoxTransitionDiagram>[];

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final DecoratedBoxTransitionDiagram typedDiagram = diagram;
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

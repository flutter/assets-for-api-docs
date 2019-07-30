// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'diagram_step.dart';
import 'fake_drag_scroll_activity.dart';

final Duration _kTotalDuration =
      _kScrollUpDuration
    + _kScrollPauseDuration
    + _kScrollDownDurationPartOne
    + _kScrollPauseDuration
    + _kScrollDownDurationPartTwo
    + _kScrollPauseDuration;
const Duration _kScrollUpDuration = Duration(seconds: 1, milliseconds: 500);
const Duration _kScrollDownDurationPartOne = Duration(milliseconds: 800);
const Duration _kScrollDownDurationPartTwo = Duration(seconds: 1);
const Duration _kScrollPauseDuration = Duration(milliseconds: 900);

const double _kCurveAnimationFrameRate = 60.0;

class SliverAppBarDiagram extends StatefulWidget implements DiagramMetadata {

  const SliverAppBarDiagram({this.pinned: false, this.floating: false, this.snap: false, this.repeatAnimation: false});

  final bool pinned;
  final bool floating;
  final bool snap;
  final bool repeatAnimation;

  @override
  State<SliverAppBarDiagram> createState() => SliverAppBarDiagramState();

  @override
  String get name {
    String name = 'app_bar';
    if (pinned) {
      name += '_pinned';
    }
    if (floating) {
      name += '_floating';
    }
    if (snap) {
      name += '_snap';
    }
    return name;
  }
}

class SliverAppBarDiagramState extends State<SliverAppBarDiagram> with TickerProviderStateMixin<SliverAppBarDiagram> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.scheduleFrameCallback((Duration _) {
      _play();
    });
  }

  @override
  void didUpdateWidget(SliverAppBarDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollController.jumpTo(0.0);
    SchedulerBinding.instance.scheduleFrameCallback((Duration _) {
      _play();
    });
  }

  Future<void> _play() async {
    await Future<void>.delayed(_kScrollPauseDuration);
    await _animate(
      to: 600.0,
      duration: _kScrollUpDuration,
    );
    await Future<void>.delayed(_kScrollPauseDuration);
    await _animate(
      to: 490.0,
      duration: _kScrollDownDurationPartOne,
    );
    await Future<void>.delayed(_kScrollPauseDuration);
    await _animate(
      to: 0.0,
      duration: _kScrollDownDurationPartTwo,
    );
    if (widget.repeatAnimation) {
      _play();
    }
  }

  Future<void> _animate({double to, Duration duration}) {
    final ScrollPositionWithSingleContext position = _scrollController.position;
    final FakeDragScrollActivity activity = FakeDragScrollActivity(
      position,
      from: _scrollController.offset,
      to: to,
      duration: duration,
      curve: Curves.easeInOut,
      vsync: this,
    );
    _scrollController.position.beginActivity(activity);
    return activity.done;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 400.0,
      width: 376.0,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar(
            primary: false,
            pinned: widget.pinned,
            snap: widget.snap,
            floating: widget.floating,
            title: const Text('App Bar'),
            expandedHeight: 180.0,
            leading: const Icon(Icons.menu),
          ),
          SliverList(
            delegate: SliverChildListDelegate(List<Widget>.generate(20, (int i) {
              return Container(
                color: i % 2 == 0 ? Colors.white : Colors.black12,
                height: 100.0,
                child: Center(
                  child: Text('$i', textScaleFactor: 5),
                ),
              );
            })),
          )
        ],
      ),
    );
  }
}

class SliverAppBarDiagramStep extends DiagramStep<SliverAppBarDiagram> {
  SliverAppBarDiagramStep(DiagramController controller) : super(controller) {
    for (bool pinned in <bool>[false, true]) {
      for (bool floating in <bool>[false, true]) {
        // snap is only a legal option if floating is true.
        for (bool snap in floating ? <bool>[false, true] : <bool>[false]) {
          _diagrams.add(new SliverAppBarDiagram(
            pinned: pinned,
            floating: floating,
            snap: snap,
          ));
        }
      }
    }
  }

  @override
  final String category = 'material';

  final List<SliverAppBarDiagram> _diagrams = <SliverAppBarDiagram>[];

  @override
  Future<List<SliverAppBarDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(SliverAppBarDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kCurveAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
  }
}



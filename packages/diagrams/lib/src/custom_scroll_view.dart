// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

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
const String _customScrollView = 'custom_scroll_view';

class CustomScrollViewDiagram extends StatefulWidget implements DiagramMetadata {
  const CustomScrollViewDiagram(this.name);

  @override
  final String name;

  @override
  State<StatefulWidget> createState() => _CustomScrollViewDiagramState();

}

class _CustomScrollViewDiagramState extends State<CustomScrollViewDiagram> with TickerProviderStateMixin<CustomScrollViewDiagram> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.scheduleFrameCallback((Duration _) {
      _play();
    });
  }

  @override
  void didUpdateWidget(CustomScrollViewDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollController.jumpTo(0.0);
    SchedulerBinding.instance.scheduleFrameCallback((Duration _) {
      _play();
    });
  }

  Future<void> _play() async {
    await Future<void>.delayed(_kScrollPauseDuration);
    await _animate(
      to: 650.0,
      duration: _kScrollUpDuration,
    );
    await Future<void>.delayed(_kScrollPauseDuration);
    await _animate(
      to: 500.0,
      duration: _kScrollDownDurationPartOne,
    );
    await Future<void>.delayed(_kScrollPauseDuration);
    await _animate(
      to: 0.0,
      duration: _kScrollDownDurationPartTwo,
    );
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
          const SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Demo'),
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200.0,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 4.0,
            ),
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.teal[100 * (index % 9)],
                  child: Text('Grid Item $index'),
                );
              },
              childCount: 20,
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
              return Container(
                alignment: Alignment.center,
                color: Colors.lightBlue[100 * (index % 9)],
                child: Text('List Item $index'),
              );
            },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomScrollViewDiagramStep extends DiagramStep<CustomScrollViewDiagram> {
  CustomScrollViewDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<CustomScrollViewDiagram>> get diagrams async => <CustomScrollViewDiagram>[
        const CustomScrollViewDiagram(_customScrollView),
      ];

  @override
  Future<File> generateDiagram(CustomScrollViewDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kCurveAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
  }
}

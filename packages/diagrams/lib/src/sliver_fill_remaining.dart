// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'fake_drag_scroll_activity.dart';
import 'utils.dart';

const Duration _kScrollUpDuration = Duration(seconds: 1);
const Duration _kScrollPauseDuration = Duration(seconds: 1);
final Duration _kTotalDuration =
    _kScrollPauseDuration + _kScrollUpDuration + _kScrollPauseDuration;

class SliverFillRemainingDiagram extends StatefulWidget with DiagramMetadata {
  const SliverFillRemainingDiagram({super.key});

  @override
  String get name => 'sliver_fill_remaining_fill_overscroll';

  @override
  State<StatefulWidget> createState() => _SliverFillRemainingDiagramState();

  @override
  Duration? get duration => _kTotalDuration;
}

class _SliverFillRemainingDiagramState extends State<SliverFillRemainingDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  _SliverFillRemainingDiagramState();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.scheduleFrameCallback((Duration _) {
      _play();
    });
  }

  @override
  void didUpdateWidget(SliverFillRemainingDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollController.jumpTo(0.0);
    SchedulerBinding.instance.scheduleFrameCallback((Duration _) {
      _play();
    });
  }

  Future<void> _play() async {
    await waitLockstep(_kScrollPauseDuration);
    await _animate(
      to: 400.0,
      duration: _kScrollUpDuration,
    );
    await waitLockstep(_kScrollPauseDuration);
  }

  Future<void> _animate({required double to, required Duration duration}) {
    final ScrollPositionWithSingleContext position =
        _scrollController.position as ScrollPositionWithSingleContext;
    final FakeDragScrollActivity activity = FakeDragScrollActivity(
      position,
      from: _scrollController.offset,
      to: to,
      duration: duration,
      curve: Curves.easeIn,
      vsync: this,
    );
    _scrollController.position.beginActivity(activity);
    return activity.done;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers;

    slivers = <Widget>[
      SliverToBoxAdapter(
        child: Container(
          color: Colors.tealAccent[700],
          height: 150.0,
        ),
      ),
      SliverFillRemaining(
        hasScrollBody: false,
        fillOverscroll: true,
        child: Container(
          color: Colors.teal[100],
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Bottom Pinned Button!'),
              ),
            ),
          ),
        ),
      ),
    ];

    return Container(
      color: Colors.white,
      height: 500.0,
      width: 250.0,
      child: Scaffold(
        appBar: AppBar(title: const Text('SliverFillRemaining')),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          controller: _scrollController,
          slivers: slivers,
        ),
      ),
    );
  }
}

class SliverFillRemainingDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<SliverFillRemainingDiagram>> get diagrams async =>
      <SliverFillRemainingDiagram>[
        const SliverFillRemainingDiagram(),
      ];
}

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

final Duration _kTotalDuration = _kScrollUpDuration + _kScrollPauseDuration;
//    + _kScrollDownDurationPartOne
//    + _kScrollPauseDuration
//    + _kScrollDownDurationPartTwo
//    + _kScrollPauseDuration;
const Duration _kScrollUpDuration = Duration(seconds: 1, milliseconds: 500);
//const Duration _kScrollDownDurationPartOne = Duration(milliseconds: 800);
//const Duration _kScrollDownDurationPartTwo = Duration(seconds: 1);
const Duration _kScrollPauseDuration = Duration(milliseconds: 900);

const double _kCurveAnimationFrameRate = 60.0;
//const String _customScrollView = 'custom_scroll_view';

class SliverFillRemainingDiagram extends StatefulWidget implements DiagramMetadata {
  const SliverFillRemainingDiagram(this.sampleNumber);

  final int sampleNumber;

  @override
  String get name => 'sliver_fill_remaining_' + sampleNumber.toString();

  @override
  State<StatefulWidget> createState() => _SliverFillRemainingDiagramState(sampleNumber);

}

class _SliverFillRemainingDiagramState extends State<SliverFillRemainingDiagram> with TickerProviderStateMixin<SliverFillRemainingDiagram> {
  _SliverFillRemainingDiagramState(this.sampleNumber);

  final ScrollController _scrollController = ScrollController();
  final int sampleNumber;

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
    await Future<void>.delayed(_kScrollPauseDuration);
    await _animate(
      to: 650.0,
      duration: _kScrollUpDuration,
    );
    await Future<void>.delayed(_kScrollPauseDuration);
//    await _animate(
//      to: 500.0,
//      duration: _kScrollDownDurationPartOne,
//    );
//    await Future<void>.delayed(_kScrollPauseDuration);
//    await _animate(
//      to: 0.0,
//      duration: _kScrollDownDurationPartTwo,
//    );
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

    List<Widget> slivers;

    switch(sampleNumber) {
      case 1:
        slivers = <Widget>[
          SliverToBoxAdapter(
            child: Container(
              color: Colors.amber[300],
              height: 150.0,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: Colors.blue[100],
              child: Icon(
                Icons.sentiment_very_satisfied,
                size: 75,
                color: Colors.blue[900],
              ),
            ),
          ),
        ];
        break;
      case 2:
        slivers = <Widget>[
          SliverFixedExtentList(
            itemExtent: 130.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  color: index % 2 == 0 ? Colors.amber[200] : Colors.blue[200],
                );
              },
              childCount: 5,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: Colors.orange[300],
              child: const Padding(
                padding: EdgeInsets.all(50.0),
                child: FlutterLogo(size: 100),
              ),
            ),
          ),
        ];
        break;
      case 3:
        slivers = <Widget>[
          SliverFixedExtentList(
            itemExtent: 150.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  color: index % 2 == 0 ? Colors.indigo[200] : Colors.orange[200],
                );
              },
              childCount: 7,
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Icon(
                  Icons.pan_tool,
                  size: 60,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ),
        ];
        break;
      case 4:
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
                  child: RaisedButton(
                    onPressed: () {},
                    child: const Text('Bottom Pinned Button!'),
                  ),
                ),
              ),
            ),
          ),
        ];
        break;
      default:
        slivers = <Widget>[
          const SliverToBoxAdapter(child: Text('Error')),
        ];
    }

    return Container(
      color: Colors.white,
      height: 500.0,
      width: 250.0,
      child: Scaffold(
        appBar: AppBar(title: const Text('SliverFillRemaining')),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: slivers,
        ),
      ),
    );
  }
}

class SliverFillRemainingDiagramStep extends DiagramStep<SliverFillRemainingDiagram> {
  SliverFillRemainingDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<SliverFillRemainingDiagram>> get diagrams async => <SliverFillRemainingDiagram>[
    const SliverFillRemainingDiagram(1),
    const SliverFillRemainingDiagram(2),
    const SliverFillRemainingDiagram(3),
    const SliverFillRemainingDiagram(4),
  ];

  @override
  Future<File> generateDiagram(SliverFillRemainingDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kCurveAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
  }
}
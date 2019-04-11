// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

final GlobalKey _pressKey = new GlobalKey();

final Duration _kTotalDuration = (_kBookEndsDuration * 2) + (_kPauseDuration * 3);
const Duration _kPauseDuration = Duration(milliseconds: 900);
const Duration _kBookEndsDuration = Duration(milliseconds: 450);
const double _kAnimationFrameRate = 60.0;

class DropdownButtonDiagram extends StatefulWidget
  implements DiagramMetadata {
  const DropdownButtonDiagram(this.name);

  @override
  final String name;

  @override
  State<DropdownButtonDiagram> createState() => DropdownButtonDiagramState();
}

class DropdownButtonDiagramState extends State<DropdownButtonDiagram> {
  int _index;
  List<Widget> dropdownItems = <Widget>[
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const <Widget>[
        Text('Debug'),
        SizedBox(width:10),
        Icon(Icons.bug_report)],
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const <Widget>[
        Text('Release'),
        SizedBox(width:10),
        Icon(Icons.flare)],
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const <Widget>[
        Text('Profile'),
        SizedBox(width: 10),
        Icon(Icons.tune)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.scheduleFrameCallback((Duration _) {
      _play();
    });
  }

  @override
  void didUpdateWidget(DropdownButtonDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    SchedulerBinding.instance.scheduleFrameCallback((Duration _) {
      _play();
    });
  }

  Future<void> _play() async {
    const Offset position = Offset.zero;
    //final RenderBox target = _pressKey.currentContext.findRenderObject();
    await Future<void>.delayed(_kBookEndsDuration);
    //position  = target.localToGlobal(target.size.bottomRight(Offset.zero));
    await _tap(position);
    await Future<void>.delayed(_kPauseDuration);
    // TODO(): update position for next tap
    await _tap(position);
    await Future<void>.delayed(_kPauseDuration);
    // TODO(): update position for next tap
    await _tap(position);
    await Future<void>.delayed(_kPauseDuration);
    // TODO(): update position for next tap
    await _tap(position);
    await Future<void>.delayed(_kBookEndsDuration);
  }

  Future<void> _tap(Offset position) async {
//    TODO(): Implement tap
//    final RenderBox target = _pressKey.currentContext.findRenderObject();
//    final Offset targetOffset = target.localToGlobal(target.size.bottomRight(Offset.zero));
//    WidgetTester tester;
//    tester.pumpWidget(_pressKey.currentWidget);
//    tester.pump();
//    tester.tapAt(targetOffset);
//    tester.pump;

  }

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(500.0, 500.0)),
      child: new Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(10.0),
        color: Colors.white,
        child: Center(
          child: DropdownButton<int>(
            key: _pressKey,
            hint: const Text('Select build  mode...'),
            value: _index,
            onChanged: (int index) {
              setState(() {
                _index = index;
              });
            },
            items: new List<DropdownMenuItem<int>>.generate(3, (int index) =>
              DropdownMenuItem<int>(value: index, child: dropdownItems[index])
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownButtonDiagramStep extends DiagramStep {
  DropdownButtonDiagramStep(DiagramController controller)
    : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const DropdownButtonDiagram('dropdown_button'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final DropdownButtonDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;

//    controller.advanceTime(Duration.zero);
//    final RenderBox target = _pressKey.currentContext.findRenderObject();
//    final Offset targetOffset = target.localToGlobal(target.size.bottomRight(Offset.zero));
//    final TestGesture gesture = await controller.startGesture(targetOffset);
//    final File result =
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
//    gesture.up();
//    return result;
  }
}

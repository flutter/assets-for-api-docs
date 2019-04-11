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

// TODO(): See playground for snippet

final GlobalKey _muteKey = new GlobalKey();
final GlobalKey _upKey = new GlobalKey();
final GlobalKey _downKey = new GlobalKey();

final Duration _kTotalDuration = (_kBookEndsDuration * 2) + (_kPauseDuration * 3);
const Duration _kPauseDuration = Duration(milliseconds: 900);
const Duration _kBookEndsDuration = Duration(milliseconds: 450);
const double _kAnimationFrameRate = 60.0;

class IconButtonDiagram extends StatefulWidget
  implements DiagramMetadata {
  const IconButtonDiagram(this.name);

  @override
  final String name;

  @override
  State<IconButtonDiagram> createState() => IconButtonDiagramState();
}

class IconButtonDiagramState extends State<IconButtonDiagram> {
  double _volume = 0.0;
  bool _isDisabled = true;

  void _decreaseVolume() {
    setState(() {
      _volume -= 10;
      if(_volume == 0) {
        _isDisabled = true;
      }
    });
  }

  @override
  void didUpdateWidget(IconButtonDiagram oldWidget) {
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
      constraints: new BoxConstraints.tight(const Size(500.0, 250.0)),
      child: new Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(10.0),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    key: _muteKey,
                    icon: const Icon(Icons.volume_off),
                    tooltip: 'Mute Volume',
                    iconSize: 35,
                    splashColor: Colors.red,
                    onPressed: () {
                      setState(() {
                        _volume = 0;
                        _isDisabled = true;
                      });
                    },
                  ),
                  IconButton(
                    key: _downKey,
                    icon: const Icon(Icons.volume_down),
                    tooltip: 'Decrease volume by 10',
                    iconSize: 35,
                    splashColor: Colors.purple[100],
                    onPressed: _isDisabled ? null : _decreaseVolume,
                  ),
                  IconButton(
                    key: _upKey,
                    icon: const Icon(Icons.volume_up),
                    tooltip: 'Increase volume by 10',
                    iconSize: 35,

                    splashColor: Colors.purple[700],
                    onPressed: () {
                      setState(() {
                        _volume += 10;
                        _isDisabled = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text('Volume : $_volume', style: Theme.of(context).textTheme.subhead),
            ],
          ),
        ),
      ),
    );
  }
}

class IconButtonDiagramStep extends DiagramStep {
  IconButtonDiagramStep(DiagramController controller)
    : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const IconButtonDiagram('icon_button'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final IconButtonDiagram typedDiagram = diagram;
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

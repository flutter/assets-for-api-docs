// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

//import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

final GlobalKey _dropdownKey = new GlobalKey();

final Duration _kTotalDuration = _kPauseDuration * 5;
const Duration _kPauseDuration = Duration(seconds: 1);
const double _kAnimationFrameRate = 60.0;

class DropdownButtonDiagram extends StatefulWidget implements DiagramMetadata {
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
        SizedBox(width: 10),
        Icon(Icons.bug_report),
      ],
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const <Widget>[
        Text('Release'),
        SizedBox(width: 10),
        Icon(Icons.flare),
      ],
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const <Widget>[
        Text('Profile'),
        SizedBox(width: 10),
        Icon(Icons.tune),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(350.0, 400.0)),
      child: new Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(10.0),
        color: Colors.white,
        child: Center(
          child: DropdownButton<int>(
            key: _dropdownKey,
            hint: const Text('Select build  mode...'),
            value: _index,
            onChanged: (int index) {
              setState(() => _index = index);
            },
            items: new List<DropdownMenuItem<int>>.generate(
                3,
                (int index) => DropdownMenuItem<int>(
                    value: index, child: dropdownItems[index])),
          ),
        ),
      ),
    );
  }
}

class DropdownButtonDiagramStep extends DiagramStep {
  DropdownButtonDiagramStep(DiagramController controller) : super(controller);

  void tapDropdown(DiagramController controller, Duration now) async {

    final RenderBox target = _dropdownKey.currentContext.findRenderObject();
    Offset targetOffset;
    switch (now.inMilliseconds) {
      case 1000:
        targetOffset = target.localToGlobal(target.size.center(Offset.zero));
        break;
      case 2000:
        targetOffset = target.localToGlobal(target.size.topRight(Offset.zero));
        break;
      case 3100:
        targetOffset = target.localToGlobal(target.size.center(Offset.zero));
        break;
      case 4100:
        targetOffset = target.localToGlobal(target.size.bottomLeft(Offset.zero));
        break;
      default:
        return;
    }
    final TestGesture gesture = await controller.startGesture(targetOffset);
    gesture.up();
  }

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
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
      gestureCallback: tapDropdown,
    );
  }
}

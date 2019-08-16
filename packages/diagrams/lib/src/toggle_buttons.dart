// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

const String _toggleButtonsSimple = 'toggle_buttons_simple';
const String _toggleButtonsRequired = 'toggle_buttons_required';
const String _toggleButtonsMutuallyExclusive = 'toggle_buttons_mutually_exclusive';
const String _toggleButtonsRequiredMutuallyExclusive = 'toggle_buttons_required_mutually_exclusive';
const double _kAnimationFrameRate = 60.0;
const Map<String, List<int>> tapSteps = <String, List<int>>{
  _toggleButtonsSimple: <int>[0, 2, 0, 2],
  _toggleButtonsRequired: <int>[0, 2, 0],
  _toggleButtonsMutuallyExclusive: <int>[0, 2, 2],
  _toggleButtonsRequiredMutuallyExclusive: <int>[0, 2, 2],
};

final List<GlobalKey> _iconKeys = <GlobalKey>[
  GlobalKey(),
  GlobalKey(),
  GlobalKey(),
];

class ToggleButtonsDiagram extends StatefulWidget implements DiagramMetadata {
  const ToggleButtonsDiagram(this.name, { Key key }) : super(key: key);

  @override
  final String name;

  @override
  _ToggleButtonsDiagramState createState() => _ToggleButtonsDiagramState();
}

class _ToggleButtonsDiagramState extends State<ToggleButtonsDiagram> {
  final List<bool> isSelected = <bool>[false, false, true];

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;
    switch (widget.name) {
      case _toggleButtonsSimple:
        returnWidget = ToggleButtons(
          children: <Widget>[
            Icon(Icons.ac_unit, key: _iconKeys[0]),
            Icon(Icons.call, key: _iconKeys[1]),
            Icon(Icons.cake, key: _iconKeys[2]),
          ],
          onPressed: (int index) {
            setState(() {
              isSelected[index] = !isSelected[index];
            });
          },
          isSelected: isSelected,
        );
      break;
      case _toggleButtonsRequired:
        returnWidget = ToggleButtons(
          children: <Widget>[
            Icon(Icons.ac_unit, key: _iconKeys[0]),
            Icon(Icons.call, key: _iconKeys[1]),
            Icon(Icons.cake, key: _iconKeys[2]),
          ],
          onPressed: (int index) {
            int count = 0;
            for (int index = 0; index < isSelected.length; index++) {
              if (isSelected[index])
                count += 1;
            }

            if (isSelected[index] && count < 2)
              return;
            setState(() {
              isSelected[index] = !isSelected[index];
            });
          },
          isSelected: isSelected,
        );
        break;
      case _toggleButtonsMutuallyExclusive:
        returnWidget = ToggleButtons(
          children: <Widget>[
            Icon(Icons.ac_unit, key: _iconKeys[0]),
            Icon(Icons.call, key: _iconKeys[1]),
            Icon(Icons.cake, key: _iconKeys[2]),
          ],
          onPressed: (int index) {
            setState(() {
              for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                if (buttonIndex == index) {
                  isSelected[buttonIndex] = !isSelected[buttonIndex];
                } else {
                  isSelected[buttonIndex] = false;
                }
              }
            });
          },
          isSelected: isSelected,
        );
      break;
      case _toggleButtonsRequiredMutuallyExclusive:
        returnWidget = ToggleButtons(
          children: <Widget>[
            Icon(Icons.ac_unit, key: _iconKeys[0]),
            Icon(Icons.call, key: _iconKeys[1]),
            Icon(Icons.cake, key: _iconKeys[2]),
          ],
          onPressed: (int index) {
            setState(() {
              for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                if (buttonIndex == index) {
                  isSelected[buttonIndex] = true;
                } else {
                  isSelected[buttonIndex] = false;
                }
              }
            });
          },
          isSelected: isSelected,
        );
        break;
      default:
        returnWidget = const Text('Error');
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400, 100)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: returnWidget,
      ),
    );
  }
}

class ToggleButtonsDiagramStep extends DiagramStep<ToggleButtonsDiagram> {
  ToggleButtonsDiagramStep(DiagramController controller) : super(controller);

  String _testName;

  int _stepCount = 0;

  @override
  final String category = 'material';

  @override
  Future<List<ToggleButtonsDiagram>> get diagrams async => <ToggleButtonsDiagram>[
    ToggleButtonsDiagram(_toggleButtonsSimple, key: UniqueKey()),
    ToggleButtonsDiagram(_toggleButtonsRequired, key: UniqueKey()),
    ToggleButtonsDiagram(_toggleButtonsMutuallyExclusive, key: UniqueKey()),
    ToggleButtonsDiagram(_toggleButtonsRequiredMutuallyExclusive, key: UniqueKey()),
  ];

  void tapIcons(DiagramController controller, Duration now) async {
    RenderBox target;
    if (now.inMilliseconds % 2000 == 0) {
      final int targetIcon = tapSteps[_testName][_stepCount];
      _stepCount += 1;
      target = _iconKeys[targetIcon].currentContext.findRenderObject();
      final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
      final TestGesture gesture = await controller.startGesture(targetOffset);
      Future<void>.delayed(const Duration(milliseconds: 500), gesture.up);
    }
  }

  @override
  Future<File> generateDiagram(ToggleButtonsDiagram diagram) async {
    _stepCount = 0;
    controller.builder = (BuildContext context) => diagram;
    _testName = diagram.name;
    return await controller.drawAnimatedDiagramToFiles(
      end: Duration(seconds: tapSteps[_testName].length * 2),
      frameRate: _kAnimationFrameRate,
      name: _testName,
      category: category,
      gestureCallback: tapIcons,
    );
  }
}

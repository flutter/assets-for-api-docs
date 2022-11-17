// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

const Duration _kPressInterval = Duration(seconds: 2);

enum ToggleButtonsBehavior {
  simple,
  required,
  mutuallyExclusive,
  requiredMutuallyExclusive,
}

class ToggleButtonsDiagram extends StatefulWidget with DiagramMetadata {
  const ToggleButtonsDiagram(this.name, this.behavior, this.steps, {super.key});

  @override
  final String name;
  final ToggleButtonsBehavior behavior;
  final List<int> steps;

  @override
  State<ToggleButtonsDiagram> createState() => _ToggleButtonsDiagramState();

  @override
  Duration? get duration => _kPressInterval * steps.length;
}

class _ToggleButtonsDiagramState extends State<ToggleButtonsDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  final List<bool> _isSelected = <bool>[false, false, true];

  final List<GlobalKey> _iconKeys = <GlobalKey>[
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  Future<void> _tap(GlobalKey key) async {
    final RenderBox target =
        key.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset =
        target.localToGlobal(target.size.center(Offset.zero));
    final WidgetController controller = DiagramWidgetController.of(context);
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await waitLockstep(const Duration(milliseconds: 500));
    await gesture.up();
  }

  int _step = 0;

  void _next() {
    if (_step >= widget.steps.length) {
      return;
    }
    _tap(_iconKeys[widget.steps[_step]]);
    _step++;
  }

  void startAnimation() {
    _next();
    waitLockstep(_kPressInterval).then((_) => startAnimation());
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, startAnimation);
  }

  void onTogglePressed(int index) {
    setState(() {
      switch (widget.behavior) {
        case ToggleButtonsBehavior.simple:
          _isSelected[index] = !_isSelected[index];
          break;
        case ToggleButtonsBehavior.required:
          int count = 0;
          for (int index = 0; index < _isSelected.length; index++) {
            if (_isSelected[index]) {
              count += 1;
            }
          }
          if (!_isSelected[index] || count > 1) {
            _isSelected[index] = !_isSelected[index];
          }
          break;
        case ToggleButtonsBehavior.mutuallyExclusive:
          for (int buttonIndex = 0;
              buttonIndex < _isSelected.length;
              buttonIndex++) {
            if (buttonIndex == index) {
              _isSelected[buttonIndex] = !_isSelected[buttonIndex];
            } else {
              _isSelected[buttonIndex] = false;
            }
          }
          break;
        case ToggleButtonsBehavior.requiredMutuallyExclusive:
          for (int buttonIndex = 0;
              buttonIndex < _isSelected.length;
              buttonIndex++) {
            if (buttonIndex == index) {
              _isSelected[buttonIndex] = true;
            } else {
              _isSelected[buttonIndex] = false;
            }
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400, 100)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: ToggleButtons(
          onPressed: onTogglePressed,
          isSelected: _isSelected,
          children: <Widget>[
            Icon(Icons.ac_unit, key: _iconKeys[0]),
            Icon(Icons.call, key: _iconKeys[1]),
            Icon(Icons.cake, key: _iconKeys[2]),
          ],
        ),
      ),
    );
  }
}

class ToggleButtonsDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<ToggleButtonsDiagram>> get diagrams async =>
      const <ToggleButtonsDiagram>[
        ToggleButtonsDiagram(
          'toggle_buttons_simple',
          ToggleButtonsBehavior.simple,
          <int>[0, 2, 0, 2],
        ),
        ToggleButtonsDiagram(
          'toggle_buttons_required',
          ToggleButtonsBehavior.required,
          <int>[0, 2, 0],
        ),
        ToggleButtonsDiagram(
          'toggle_buttons_mutually_exclusive',
          ToggleButtonsBehavior.mutuallyExclusive,
          <int>[0, 2, 2],
        ),
        ToggleButtonsDiagram(
          'toggle_buttons_required_mutually_exclusive',
          ToggleButtonsBehavior.requiredMutuallyExclusive,
          <int>[0, 2, 2],
        ),
      ];
}

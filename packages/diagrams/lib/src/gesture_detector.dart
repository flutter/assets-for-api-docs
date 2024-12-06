// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

const String _gestureDetector = 'gesture_detector';
const Duration _pauseDuration = Duration(seconds: 1);
final Duration _totalDuration = _pauseDuration + _pauseDuration;

class GestureDetectorDiagram extends StatefulWidget with DiagramMetadata {
  const GestureDetectorDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  State<GestureDetectorDiagram> createState() => _GestureDetectorDiagramState();

  @override
  Duration? get duration => _totalDuration;
}

class _GestureDetectorDiagramState extends State<GestureDetectorDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  final GlobalKey _gestureDetectorKey = GlobalKey();
  bool _lights = false;

  Future<void> startAnimation() async {
    await waitLockstep(_pauseDuration);

    final RenderBox target =
        _gestureDetectorKey.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset = target.localToGlobal(
      target.size.center(Offset.zero),
    );
    final WidgetController controller = DiagramWidgetController.of(context);
    await controller.tapAt(targetOffset);
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(200, 150)),
      child: Container(
        alignment: FractionalOffset.center,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.lightbulb_outline,
                color: _lights ? Colors.yellow.shade600 : Colors.black,
                size: 60,
              ),
            ),
            GestureDetector(
              key: _gestureDetectorKey,
              onTap: () {
                setState(() {
                  _lights = true;
                });
              },
              child: Container(
                color: Colors.yellow.shade600,
                padding: const EdgeInsets.all(8),
                child: const Text('TURN LIGHTS ON'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GestureDetectorDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<GestureDetectorDiagram>> get diagrams async =>
      <GestureDetectorDiagram>[const GestureDetectorDiagram(_gestureDetector)];
}

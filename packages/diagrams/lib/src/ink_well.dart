// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

final GlobalKey _splashKey = GlobalKey();

class InkWellDiagram extends StatefulWidget with DiagramMetadata {
  const InkWellDiagram({super.key});

  @override
  String get name => 'ink_well';

  @override
  Duration get startAt => const Duration(milliseconds: 550);

  @override
  State<InkWellDiagram> createState() => _InkWellDiagramState();
}

class _InkWellDiagramState extends State<InkWellDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  final GlobalKey canvasKey = GlobalKey();
  final GlobalKey childKey = GlobalKey();
  final GlobalKey heroKey = GlobalKey();

  Future<void> startAnimation() async {
    // Wait for the tree to finish building before attempting to find our
    // RenderObject.
    await Future<void>.delayed(Duration.zero);

    final WidgetController controller = DiagramWidgetController.of(context);
    final RenderBox target =
        _splashKey.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset =
        target.localToGlobal(target.size.bottomRight(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await waitLockstep(const Duration(seconds: 1));
    gesture.up();
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
      constraints: BoxConstraints.tight(const Size(280.0, 180.0)),
      child: Theme(
        data: ThemeData(
          primarySwatch: Colors.blue,
        ),
        child: Material(
          color: const Color(0xFFFFFFFF),
          child: Stack(
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: 150.0,
                  height: 100.0,
                  child: InkWell(
                    key: heroKey,
                    onTap: () {},
                    child: Hole(
                      color: Colors.blue,
                      key: childKey,
                    ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 120.0,
                  height: 80.0,
                  alignment: FractionalOffset.bottomRight,
                  child: SizedBox(
                    key: _splashKey,
                    width: 20.0,
                    height: 25.0,
                  ),
                ),
              ),
              Positioned.fill(
                child: LabelPainterWidget(
                  key: canvasKey,
                  labels: <Label>[
                    Label(childKey, 'child', const FractionalOffset(0.2, 0.8)),
                    Label(_splashKey, 'splash', FractionalOffset.topLeft),
                    Label(
                        heroKey, 'highlight', const FractionalOffset(0.3, 0.2)),
                  ],
                  heroKey: heroKey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InkWellDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async {
    return const <DiagramMetadata>[
      InkWellDiagram(),
    ];
  }
}

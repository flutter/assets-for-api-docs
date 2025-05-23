// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

class InkResponseSmallDiagram extends StatefulWidget with DiagramMetadata {
  InkResponseSmallDiagram({super.key});

  @override
  String get name => 'ink_response_small';

  @override
  Duration get startAt => const Duration(milliseconds: 550);

  @override
  State<InkResponseSmallDiagram> createState() =>
      _InkResponseSmallDiagramState();
}

class _InkResponseSmallDiagramState extends State<InkResponseSmallDiagram> {
  final GlobalKey canvasKey = GlobalKey();
  final GlobalKey childKey = GlobalKey();
  final GlobalKey heroKey = GlobalKey();
  final GlobalKey splashKey = GlobalKey();

  Future<void> startAnimation() async {
    // Wait for the tree to finish building before attempting to find our
    // RenderObject.
    await Future<void>.delayed(Duration.zero);
    final RenderBox target =
        splashKey.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset = target.localToGlobal(
      target.size.bottomRight(Offset.zero),
    );
    final WidgetController controller = DiagramWidgetController.of(context);
    await controller.startGesture(targetOffset);
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(const Size(280.0, 180.0)),
      child: Theme(
        data: ThemeData(primarySwatch: Colors.blue),
        child: Material(
          color: const Color(0xFFFFFFFF),
          child: Stack(
            children: <Widget>[
              Center(
                child: Container(
                  key: heroKey,
                  width: 150.0,
                  height: 100.0,
                  alignment: FractionalOffset.center,
                  child: SizedBox(
                    height: 45.0,
                    width: 100.0,
                    child: InkResponse(
                      onTap: () {},
                      child: Hole(color: Colors.blue, key: childKey),
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(key: splashKey, width: 90.0, height: 20.0),
              ),
              Positioned.fill(
                child: LabelPainterWidget(
                  key: canvasKey,
                  labels: <Label>[
                    Label(childKey, 'child', const FractionalOffset(0.1, 0.85)),
                    Label(
                      splashKey,
                      'splash',
                      const FractionalOffset(0.8, 0.6),
                    ),
                    Label(
                      heroKey,
                      'highlight',
                      const FractionalOffset(0.45, 0.25),
                    ),
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

class InkResponseSmallDiagramStep extends DiagramStep {
  final List<InkResponseSmallDiagram> _diagrams = <InkResponseSmallDiagram>[
    InkResponseSmallDiagram(),
  ];

  @override
  final String category = 'material';

  @override
  Future<List<InkResponseSmallDiagram>> get diagrams async => _diagrams;
}

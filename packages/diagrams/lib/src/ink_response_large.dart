// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

final GlobalKey splashKey = GlobalKey();

class InkResponseLargeDiagram extends StatelessWidget
    implements DiagramMetadata {
  InkResponseLargeDiagram({Key? key}) : super(key: key);

  final GlobalKey canvasKey = GlobalKey();
  final GlobalKey childKey = GlobalKey();
  final GlobalKey heroKey = GlobalKey();

  @override
  String get name => 'ink_response_large';

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
                  child: InkResponse(
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
                    key: splashKey,
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
                    Label(splashKey, 'splash', FractionalOffset.topLeft),
                    Label(heroKey, 'highlight',
                        const FractionalOffset(0.45, 0.3)),
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

class InkResponseLargeDiagramStep extends DiagramStep<InkResponseLargeDiagram> {
  InkResponseLargeDiagramStep(DiagramController controller)
      : super(controller) {
    _diagrams.add(InkResponseLargeDiagram());
  }

  final List<InkResponseLargeDiagram> _diagrams = <InkResponseLargeDiagram>[];

  @override
  final String category = 'material';

  @override
  Future<List<InkResponseLargeDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(InkResponseLargeDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    controller.advanceTime(Duration.zero);
    final RenderBox target =
        splashKey.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset =
        target.localToGlobal(target.size.bottomRight(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    final File result = await controller.drawDiagramToFile(
      File('${diagram.name}.png'),
      timestamp: const Duration(milliseconds: 550),
    );
    await gesture.up();
    return result;
  }
}

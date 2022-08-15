// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

final GlobalKey _splashKey = GlobalKey();

class InkResponseSmallDiagram extends StatelessWidget
    implements DiagramMetadata {
  InkResponseSmallDiagram({super.key});

  final GlobalKey canvasKey = GlobalKey();
  final GlobalKey childKey = GlobalKey();
  final GlobalKey heroKey = GlobalKey();

  @override
  String get name => 'ink_response_small';

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
                      child: Hole(
                        color: Colors.blue,
                        key: childKey,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  key: _splashKey,
                  width: 90.0,
                  height: 20.0,
                ),
              ),
              Positioned.fill(
                child: LabelPainterWidget(
                  key: canvasKey,
                  labels: <Label>[
                    Label(childKey, 'child', const FractionalOffset(0.1, 0.85)),
                    Label(
                        _splashKey, 'splash', const FractionalOffset(0.8, 0.6)),
                    Label(heroKey, 'highlight',
                        const FractionalOffset(0.45, 0.25)),
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

class InkResponseSmallDiagramStep extends DiagramStep<InkResponseSmallDiagram> {
  InkResponseSmallDiagramStep(super.controller) {
    _diagrams.add(InkResponseSmallDiagram());
  }

  final List<InkResponseSmallDiagram> _diagrams = <InkResponseSmallDiagram>[];

  @override
  final String category = 'material';

  @override
  Future<List<InkResponseSmallDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(InkResponseSmallDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    controller.advanceTime();
    final RenderBox target =
        _splashKey.currentContext!.findRenderObject()! as RenderBox;
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

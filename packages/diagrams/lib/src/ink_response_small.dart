// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

final GlobalKey _splashKey = new GlobalKey();

class InkResponseSmallDiagram extends StatelessWidget implements DiagramMetadata {
  InkResponseSmallDiagram({Key key}) : super(key: key);

  final GlobalKey canvasKey = new GlobalKey();
  final GlobalKey childKey = new GlobalKey();
  final GlobalKey heroKey = new GlobalKey();

  @override
  String get name => 'ink_response_small';

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(280.0, 180.0)),
      child: new Theme(
        data: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        child: new Material(
          color: const Color(0xFFFFFFFF),
          child: new Stack(
            children: <Widget>[
              new Center(
                child: new Container(
                  key: heroKey,
                  width: 150.0,
                  height: 100.0,
                  alignment: FractionalOffset.center,
                  child: new Container(
                    height: 45.0,
                    width: 100.0,
                    child: new InkResponse(
                      onTap: () {},
                      child: new Hole(
                        color: Colors.blue,
                        key: childKey,
                      ),
                    ),
                  ),
                ),
              ),
              new Center(
                child: new Container(
                  key: _splashKey,
                  width: 90.0,
                  height: 20.0,
                ),
              ),
              new Positioned.fill(
                child: new LabelPainterWidget(
                  key: canvasKey,
                  labels: <Label>[
                    new Label(childKey, 'child', const FractionalOffset(0.1, 0.85)),
                    new Label(_splashKey, 'splash', const FractionalOffset(0.8, 0.6)),
                    new Label(heroKey, 'highlight', const FractionalOffset(0.45, 0.25)),
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
  InkResponseSmallDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(new InkResponseSmallDiagram());
  }

  final List<InkResponseSmallDiagram> _diagrams = <InkResponseSmallDiagram>[];

  @override
  final String category = 'material';

  @override
  Future<List<InkResponseSmallDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(InkResponseSmallDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    controller.advanceTime(Duration.zero);
    final RenderBox target = _splashKey.currentContext.findRenderObject();
    final Offset targetOffset = target.localToGlobal(target.size.bottomRight(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    final File result = await controller.drawDiagramToFile(
      new File('${diagram.name}.png'),
      timestamp: const Duration(milliseconds: 550),
    );
    await gesture.up();
    return result;
  }
}

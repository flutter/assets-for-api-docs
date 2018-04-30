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

final GlobalKey splashKey = new GlobalKey();

class InkWellDiagram extends StatelessWidget {
  InkWellDiagram({Key key}) : super(key: key);

  final GlobalKey canvasKey = new GlobalKey();
  final GlobalKey childKey = new GlobalKey();
  final GlobalKey heroKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
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
                  width: 150.0,
                  height: 100.0,
                  child: new InkWell(
                    key: heroKey,
                    onTap: () {},
                    child: new Hole(
                      color: Colors.blue,
                      key: childKey,
                    ),
                  ),
                ),
              ),
              new Center(
                child: new Container(
                  width: 120.0,
                  height: 80.0,
                  alignment: FractionalOffset.bottomRight,
                  child: new Container(
                    key: splashKey,
                    width: 20.0,
                    height: 25.0,
                  ),
                ),
              ),
              new Positioned.fill(
                child: new LabelPainterWidget(
                  key: canvasKey,
                  labels: <Label>[
                    new Label(childKey, 'child', const FractionalOffset(0.2, 0.8)),
                    new Label(splashKey, 'splash', const FractionalOffset(0.0, 0.0)),
                    new Label(heroKey, 'highlight', const FractionalOffset(0.3, 0.2)),
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
  InkWellDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<File>> generateDiagrams() async {
    controller.pixelRatio = 1.6;
    controller.builder = (BuildContext context) => new InkWellDiagram();
    controller.advanceTime(Duration.zero);
    final RenderBox target = splashKey.currentContext.findRenderObject();
    final Offset targetOffset = target.localToGlobal(target.size.bottomRight(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    final List<File> result = <File>[
      await controller.drawDiagramToFile(
        new File('ink_well.png'),
        duration: const Duration(milliseconds: 550),
      ),
    ];
    gesture.up();
    controller.pixelRatio = 1.0;
    return result;
  }
}

// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

class MediaQueryDiagram extends StatefulWidget implements DiagramMetadata {
  const MediaQueryDiagram({Key key, @required this.name}) : super(key: key);

  @override
  final String name;

  @override
  _DiagramState createState() => new _DiagramState();
}

class _DiagramState extends State<MediaQueryDiagram> {

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(
        500.0,
        300.0,
      )),
      child: new Theme(
        data: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        child: new Material(
          color: const Color(0xFFFFFFFF),
          child: new MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.all(0.0),
            ),
            child: Center(
              child: new Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  new Container(
                    width: 350.0,
                    height: 250.0,
                    color: Colors.black,
                  ),
                  new Container(
                    width: 342.0,
                    height: 246.0,
                    color: Colors.red,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 130.0),
                    child: new Container(
                      width: 342.0,
                      height: 246.0,
                      color: Colors.amber,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 200.0),
                    child: new Container(
                      width: 342.0,
                      height: 246.0,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 170, 240.0, 0.0),
                    child: new Container(
                      width: 6.0,
                      height: 80.0,
                      color: Colors.black45,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 260, 240.0, 0.0),
                    child: Text(
                      'viewInsets',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 100, 0.0, 0.0),
                    child: Container(
                      width: 6.0,
                      height: 70.0,
                      color: Colors.black45,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 70, 0.0, 0.0),
                    child: Text(
                      'padding',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(240.0, 100.0, 0.0, .0),
                    child: new Container(
                      width: 6.0,
                      height: 150.0,
                      color: Colors.black45,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(240.0, 260.0, 0.0, 0.0),
                    child: Text(
                      'viewPadding',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MediaQueryDiagramStep extends DiagramStep<MediaQueryDiagram> {
  MediaQueryDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<MediaQueryDiagram>> get diagrams async => <MediaQueryDiagram>[const MediaQueryDiagram(name: 'media_query')];

  @override
  Future<File> generateDiagram(MediaQueryDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

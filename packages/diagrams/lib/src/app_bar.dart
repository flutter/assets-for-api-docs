// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';
import 'utils.dart';

class AppBarDiagram extends StatefulWidget implements DiagramMetadata {
  const AppBarDiagram({Key key, @required this.name}) : super(key: key);

  @override
  final String name;

  @override
  _DiagramState createState() => new _DiagramState();
}

class _DiagramState extends State<AppBarDiagram> {
  final GlobalKey leading = new GlobalKey();
  final GlobalKey actions = new GlobalKey();
  final GlobalKey title = new GlobalKey();
  final GlobalKey flexibleSpace = new GlobalKey();
  final GlobalKey bottom = new GlobalKey();
  final GlobalKey heroKey = new GlobalKey();
  final GlobalKey canvasKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(
        540.0,
        260.0,
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
            child: new Stack(
              children: <Widget>[
                new Center(
                  child: new Container(
                    width: 300.0,
                    height: kToolbarHeight * 2.0 + 50.0,
                    child: new AppBar(
                      key: heroKey,
                      leading: new Hole(key: leading),
                      title: new Text('Abc', key: title),
                      actions: <Widget>[
                        const Hole(),
                        const Hole(),
                        new Hole(key: actions),
                      ],
                      flexibleSpace: new DecoratedBox(
                        key: flexibleSpace,
                        decoration: new BoxDecoration(
                          gradient: new LinearGradient(
                            begin: const FractionalOffset(0.50, 0.0),
                            end: const FractionalOffset(0.48, 1.0),
                            colors: <Color>[Colors.blue.shade500, Colors.blue.shade800],
                          ),
                        ),
                      ),
                      bottom: new PreferredSize(
                        key: bottom,
                        preferredSize: const Size(0.0, kToolbarHeight),
                        child: new Container(
                          height: 50.0,
                          padding: const EdgeInsets.all(4.0),
                          child: const Placeholder(
                            strokeWidth: 2.0,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                new Positioned.fill(
                  child: new LabelPainterWidget(
                    key: canvasKey,
                    labels: <Label>[
                      new Label(leading, 'leading', const FractionalOffset(0.5, 0.25)),
                      new Label(actions, 'actions', const FractionalOffset(0.25, 0.5)),
                      new Label(title, 'title', const FractionalOffset(0.5, 0.5)),
                      new Label(flexibleSpace, 'flexibleSpace', const FractionalOffset(0.2, 0.5)),
                      new Label(bottom, 'bottom', const FractionalOffset(0.5, 0.75)),
                    ],
                    heroKey: heroKey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppBarDiagramStep extends DiagramStep<AppBarDiagram> {
  AppBarDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<AppBarDiagram>> get diagrams async => <AppBarDiagram>[const AppBarDiagram(name: 'app_bar')];

  @override
  Future<File> generateDiagram(AppBarDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';
import 'utils.dart';

class AppBarDiagram extends StatefulWidget implements DiagramMetadata {
  const AppBarDiagram({Key? key, required this.name}) : super(key: key);

  @override
  final String name;

  @override
  State<AppBarDiagram> createState() => _DiagramState();
}

class _DiagramState extends State<AppBarDiagram> {
  final GlobalKey leading = GlobalKey();
  final GlobalKey actions = GlobalKey();
  final GlobalKey title = GlobalKey();
  final GlobalKey flexibleSpace = GlobalKey();
  final GlobalKey bottom = GlobalKey();
  final GlobalKey heroKey = GlobalKey();
  final GlobalKey canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(
        540.0,
        260.0,
      )),
      child: Theme(
        data: ThemeData(
          primarySwatch: Colors.blue,
        ),
        child: Material(
          color: const Color(0xFFFFFFFF),
          child: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.zero,
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: SizedBox(
                    width: 300.0,
                    height: kToolbarHeight * 2.0 + 50.0,
                    child: AppBar(
                      key: heroKey,
                      leading: Hole(key: leading),
                      title: Text('Abc', key: title),
                      actions: <Widget>[
                        const Hole(),
                        const Hole(),
                        Hole(key: actions),
                      ],
                      flexibleSpace: DecoratedBox(
                        key: flexibleSpace,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: const FractionalOffset(0.48, 1.0),
                            colors: <Color>[Colors.blue.shade500, Colors.blue.shade800],
                          ),
                        ),
                      ),
                      bottom: PreferredSize(
                        key: bottom,
                        preferredSize: const Size(0.0, kToolbarHeight),
                        child: Container(
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
                Positioned.fill(
                  child: LabelPainterWidget(
                    key: canvasKey,
                    labels: <Label>[
                      Label(leading, 'leading', const FractionalOffset(0.5, 0.25)),
                      Label(actions, 'actions', const FractionalOffset(0.25, 0.5)),
                      Label(title, 'title', FractionalOffset.center),
                      Label(flexibleSpace, 'flexibleSpace', const FractionalOffset(0.2, 0.5)),
                      Label(bottom, 'bottom', const FractionalOffset(0.5, 0.75)),
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
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

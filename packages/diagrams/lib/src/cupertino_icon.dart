// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _icon = 'cupertino_icon';

class CupertinoIconDiagram extends StatelessWidget implements DiagramMetadata {
  const CupertinoIconDiagram(this.name, {Key? key}) : super(key: key);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(200.0, 100.0)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const <Widget>[
              Icon(
                CupertinoIcons.heart_fill,
                color: Colors.pink,
                size: 24.0,
              ),
              Icon(
                CupertinoIcons.bell_fill,
                color: Colors.green,
                size: 30.0,
              ),
              Icon(
                CupertinoIcons.umbrella_fill,
                color: Colors.blue,
                size: 36.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CupertinoIconDiagramStep extends DiagramStep<CupertinoIconDiagram> {
  CupertinoIconDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'cupertino';

  @override
  Future<List<CupertinoIconDiagram>> get diagrams async =>
      <CupertinoIconDiagram>[
        const CupertinoIconDiagram(_icon),
      ];

  @override
  Future<File> generateDiagram(CupertinoIconDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

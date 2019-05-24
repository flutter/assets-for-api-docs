// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

class BoxFitDiagram extends StatelessWidget implements DiagramMetadata {
  const BoxFitDiagram(this.fit);

  final BoxFit fit;

  @override
  String get name => 'box_fit_${describeEnum(fit)}';

  @override
  Widget build(BuildContext context) {
    final Widget inner = new Container(
      decoration: new BoxDecoration(
        border: new Border.all(width: 2.0, color: Colors.blue[300]),
        color: Colors.blue[100],
      ),
      child: new FittedBox(
        fit: fit,
        child: new Container(
          width: 5.0 * 12.0,
          height: 5.0 * 12.0,
          decoration: new BoxDecoration(
            border: new Border.all(width: 2.0, color: Colors.teal[700]),
            color: Colors.teal[600],
          ),
          child: new GridPaper(
            color: Colors.teal[400],
            divisions: 1,
            interval: 18.5,
            subdivisions: 1,
            child: new Center(
              child: new Text('${fit.toString().split(".").join("\n")}'),
            ),
          ),
        ),
      ),
    );
    return new Container(
      key: new UniqueKey(),
      width: 300.0,
      height: 90.0,
      child: new Row(
        key: new GlobalObjectKey(fit),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Expanded(
            flex: 180,
            child: new Center(
              child: new AspectRatio(
                aspectRatio: 2.5,
                child: inner,
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          new Expanded(
            flex: 80,
            child: inner,
          ),
          const SizedBox(width: 10.0),
          new Expanded(
            flex: 200,
            child: inner,
          ),
        ],
      ),
    );
  }
}

class BoxFitDiagramStep extends DiagramStep<BoxFitDiagram> {
  BoxFitDiagramStep(DiagramController controller) : super(controller) {
    for (BoxFit fit in BoxFit.values) {
      _diagrams.add(new BoxFitDiagram(fit));
    }
  }

  @override
  final String category = 'painting';

  final List<BoxFitDiagram> _diagrams = <BoxFitDiagram>[];

  @override
  Future<List<BoxFitDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(BoxFitDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

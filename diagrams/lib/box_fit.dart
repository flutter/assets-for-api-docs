// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

class BoxFitDiagram extends StatelessWidget {
  const BoxFitDiagram(this.fit);

  final BoxFit fit;

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

class BoxFitDiagramStep extends DiagramStep {
  BoxFitDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'painting';

  @override
  Future<List<File>> generateDiagrams() async {
    final List<BoxFitDiagram> boxFitDiagrams = <BoxFitDiagram>[];
    for (BoxFit fit in BoxFit.values) {
      boxFitDiagrams.add(new BoxFitDiagram(fit));
    }

    final List<File> outputFiles = <File>[];
    for (BoxFitDiagram boxFitDiagram in boxFitDiagrams) {
      controller.builder = (BuildContext context) => boxFitDiagram;
      outputFiles.add(
        await controller.drawDiagramToFile(
          new File('box_fit_${describeEnum(boxFitDiagram.fit)}.png'),
        ),
      );
    }
    return outputFiles;
  }
}

// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram/diagram.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const double topPadding = 30.0;
const double width = 190.0;
const double height = 200.0;
const double spacing = 8.0;
const double borderSize = 1.0;

enum GradientMode { linear, radial, }

class TileModeDiagram extends StatelessWidget {
  const TileModeDiagram(this.gradientMode, this.tileMode);

  String get name => 'tile_mode_${describeEnum(tileMode)}_${describeEnum(gradientMode)}.png';

  final GradientMode gradientMode;
  final TileMode tileMode;

  String get gradientModeName {
    final String s = describeEnum(gradientMode);
    return s[0].toUpperCase() + s.substring(1);
  }

  Gradient _buildGradient() {
    Gradient gradient;
    switch (gradientMode) {
      case GradientMode.linear:
        gradient = new LinearGradient(
          begin: const FractionalOffset(0.4, 0.5),
          end: const FractionalOffset(0.6, 0.5),
          colors: const <Color>[
            const Color(0xFF0000FF),
            const Color(0xFF00FF00)
          ],
          stops: const <double>[0.0, 1.0],
          tileMode: tileMode,
        );
        break;
      case GradientMode.radial:
        gradient = new RadialGradient(
          center: FractionalOffset.center,
          radius: 0.2,
          colors: const <Color>[
            const Color(0xFF0000FF),
            const Color(0xFF00FF00)
          ],
          stops: const <double>[0.0, 1.0],
          tileMode: tileMode,
        );
        break;
    }
    return gradient;
  }

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: const BoxConstraints.tightFor(width: width, height: height),
      child: DefaultTextStyle.merge(
      style: const TextStyle(
        fontSize: 10.0,
        color: const Color(0xFF000000),
      ),
      child: new Directionality(
        textDirection: TextDirection.ltr,
        child: new Center(
          child: new Container(
            margin: const EdgeInsets.all(spacing),
            width: width,
            decoration: new BoxDecoration(
              border: new Border.all(width: borderSize),
              color: const Color(0xFFFFFFFF),
            ),
            child: new Column(
              children: <Widget>[
                new Expanded(
                  child: new Container(
                    decoration: new BoxDecoration(
                      gradient: _buildGradient(),
                      border: const Border(
                        bottom: const BorderSide(width: 1.0),
                      ),
                    ),
                  ),
                ),
                new Container(height: 3.0),
                new Text(
                  '$gradientModeName Gradient',
                  textAlign: TextAlign.center,
                ),
                new Text('$tileMode', textAlign: TextAlign.center),
                new Container(height: 3.0),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class TileModeDiagramStep extends DiagramStep {
  TileModeDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'dart-ui';

  @override
  Future<List<File>> generateDiagrams() async {
    final List<TileModeDiagram> tileModeDiagrams = <TileModeDiagram>[];
    for (TileMode mode in TileMode.values) {
      for (GradientMode gradient in GradientMode.values) {
        tileModeDiagrams.add(new TileModeDiagram(gradient, mode));
      }
    }

    final List<File> outputFiles = <File>[];
    for (TileModeDiagram tileModeDiagram in tileModeDiagrams) {
      controller.builder = (BuildContext context) => tileModeDiagram;
      outputFiles.add(await controller.drawDiagramToFile(new File(tileModeDiagram.name)));
    }
    return outputFiles;
  }
}

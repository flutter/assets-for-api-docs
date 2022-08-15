// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const double topPadding = 30.0;
const double width = 190.0;
const double height = 200.0;
const double spacing = 8.0;
const double borderSize = 1.0;

enum GradientMode {
  linear,
  radial,
  radialWithFocal,
  sweep,
}

class TileModeDiagram extends StatelessWidget implements DiagramMetadata {
  const TileModeDiagram(this.gradientMode, this.tileMode, {super.key});

  @override
  String get name =>
      'tile_mode_${describeEnum(tileMode)}_${describeEnum(gradientMode)}';

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
        gradient = LinearGradient(
          begin: const FractionalOffset(0.4, 0.5),
          end: const FractionalOffset(0.6, 0.5),
          colors: const <Color>[Color(0xFF0000FF), Color(0xFF00FF00)],
          stops: const <double>[0.0, 1.0],
          tileMode: tileMode,
        );
        break;
      case GradientMode.radial:
        gradient = RadialGradient(
          center: FractionalOffset.center,
          radius: 0.2,
          colors: const <Color>[Color(0xFF0000FF), Color(0xFF00FF00)],
          stops: const <double>[0.0, 1.0],
          tileMode: tileMode,
        );
        break;
      case GradientMode.sweep:
        gradient = SweepGradient(
          center: FractionalOffset.center,
          endAngle: math.pi / 2,
          colors: const <Color>[Color(0xFF0000FF), Color(0xFF00FF00)],
          stops: const <double>[0.0, 1.0],
          tileMode: tileMode,
        );
        break;
      case GradientMode.radialWithFocal:
        gradient = RadialGradient(
          center: FractionalOffset.center,
          focal: const FractionalOffset(0.5, 0.42),
          radius: 0.2,
          colors: const <Color>[Color(0xFF0000FF), Color(0xFF00FF00)],
          stops: const <double>[0.0, 1.0],
          tileMode: tileMode,
        );
        break;
    }
    return gradient;
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: const BoxConstraints.tightFor(width: width, height: height),
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: 10.0,
          color: Color(0xFF000000),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(spacing),
              width: width,
              decoration: BoxDecoration(
                border: Border.all(),
                color: const Color(0xFFFFFFFF),
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: _buildGradient(),
                        border: const Border(
                          bottom: BorderSide(),
                        ),
                      ),
                    ),
                  ),
                  Container(height: 3.0),
                  Text(
                    '$gradientModeName Gradient',
                    textAlign: TextAlign.center,
                  ),
                  Text('$tileMode', textAlign: TextAlign.center),
                  Container(height: 3.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TileModeDiagramStep extends DiagramStep<TileModeDiagram> {
  TileModeDiagramStep(super.controller) {
    for (final TileMode mode in TileMode.values) {
      for (final GradientMode gradient in GradientMode.values) {
        _diagrams.add(TileModeDiagram(gradient, mode));
      }
    }
  }

  @override
  final String category = 'dart-ui';

  final List<TileModeDiagram> _diagrams = <TileModeDiagram>[];

  @override
  Future<List<TileModeDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(TileModeDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

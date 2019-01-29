// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';

abstract class StrutDiagram extends StatelessWidget implements DiagramMetadata {
  @override
  String get name;
}

class StrutDropCapDiagram extends  StrutDiagram {
  const StrutDropCapDiagram();

  @override
  String get name => 'strut_force_text_drop_cap';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400.0, 154.0)),
      child: Text.rich(
        TextSpan(
          text: '       he candle flickered\n',
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Serif'
          ),
          children: <TextSpan>[
            const TextSpan(
              text: 'T',
              style: const TextStyle(
                fontSize: 37,
                fontFamily: 'Serif'
              ),
            ),
            const TextSpan(
              text: 'in the moonlight as\n',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Serif'
              ),
            ),
            const TextSpan(
              text: 'Dash the bird fluttered\n',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Serif'
              ),
            ),
            const TextSpan(
              text: 'off into the distance.',
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Serif'
              ),
            ),
          ],
        ),
        strutStyle: const StrutStyle(
          fontFamily: 'Serif',
          fontSize: 14,
          forceStrutHeight: true,
        ),
      ),
    );
  }
}

class StrutAsciiArtDiagram extends  StrutDiagram {
  const StrutAsciiArtDiagram();

  @override
  String get name => 'strut_force_text_ascii_art';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400.0, 154.0)),
      child: Text.rich(
        TextSpan(
          text: '---------         ---------\n',
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Roboto',
          ),
          children: <TextSpan>[
            const TextSpan(
              text: '^^^M^^^\n',
              style: const TextStyle(
                fontSize: 30,
                fontFamily: 'Roboto',
              ),
            ),
            const TextSpan(
              text: 'M------M\n',
              style: const TextStyle(
                fontSize: 30,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        strutStyle: const StrutStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          height: 1,
          forceStrutHeight: true,
        ),
      ),
    );
  }
}

class StrutDiagramStep extends DiagramStep {
  StrutDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.addAll(<ColorDiagram>[
      StrutDropCapDiagram(),
      StrutAsciiArtDiagram(),
    ]);
  }

  @override
  final String category = 'widgets';

  final List<StrutDiagram> _diagrams = <StrutDiagram>[];

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final StrutDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

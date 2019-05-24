// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const double _kFontSize = 14.0;

class StrokeCapDescription extends CustomPainter {
  StrokeCapDescription({
    this.filename,
    this.cap,
  }) : _capPainter = _createLabelPainter(cap.toString());

  static const EdgeInsets padding = EdgeInsets.all(3.0);

  final String filename;
  final StrokeCap cap;
  final TextPainter _capPainter;

  Widget get widget {
    return new ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 130.0),
      child: new AspectRatio(
        aspectRatio: 1.0,
        child: new Padding(
          padding: const EdgeInsets.all(3.0),
          child: new CustomPaint(
            painter: this,
          ),
        ),
      ),
    );
  }

  static TextPainter _createLabelPainter(String label, {FontStyle style: FontStyle.normal}) {
    final TextPainter result = new TextPainter(
      textDirection: TextDirection.ltr,
      text: new TextSpan(
        text: label,
        style: new TextStyle(
          color: Colors.black,
          fontStyle: style,
          fontSize: _kFontSize,
        ),
      ),
    );
    result.layout();
    return result;
  }

  @override
  void paint(Canvas canvas, Size size) {
    assert(size != Size.zero);
    final Offset center = new Offset(size.width / 2.0, (size.height - _capPainter.height - padding.vertical) / 2.0);
    final Offset start = new Offset(0.0, center.dy);
    final Offset middle = new Offset(size.width / 2.0, center.dy);

    final Paint startPaint = new Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 20.0;
    final Paint linePaint = new Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = cap
      ..strokeWidth = 20.0;
    final Paint endPaint = new Paint()
      ..color = Colors.deepPurpleAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = cap
      ..strokeWidth = 20.0;

    Path line = new Path() // Line
      ..moveTo(start.dx, start.dy)
      ..lineTo(middle.dx, middle.dy);
    canvas.drawPath(line, linePaint);
    line = new Path() // Start point, so that it doesn't show the starting end cap.
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx, start.dy);
    canvas.drawPath(line, startPaint);
    line = new Path() // End point, a different color to highlight the cap.
      ..moveTo(middle.dx, middle.dy)
      ..lineTo(middle.dx, middle.dy);
    canvas.drawPath(line, endPaint);
    _capPainter.paint(
      canvas,
      new Offset(
        padding.left,
        size.height - (padding.bottom + 3.0 + _capPainter.height),
      ),
    );
  }

  @override
  bool shouldRepaint(StrokeCapDescription oldDelegate) {
    return cap != oldDelegate.cap;
  }
}

class StrokeCapDiagram extends StatelessWidget implements DiagramMetadata {
  const StrokeCapDiagram({this.name, this.cap: StrokeCap.round});

  @override
  final String name;
  final StrokeCap cap;

  @override
  Widget build(BuildContext context) {
    final StrokeCapDescription description = new StrokeCapDescription(
      cap: cap,
    );

    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(150.0, 100.0)),
      child: new Container(
        padding: const EdgeInsets.all(18.0),
        color: Colors.white,
        child: new CustomPaint(painter: description),
      ),
    );
  }
}

class StrokeCapDiagramStep extends DiagramStep<StrokeCapDiagram> {
  StrokeCapDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.addAll(<StrokeCapDiagram>[
      const StrokeCapDiagram(
        name: 'butt_cap',
        cap: StrokeCap.butt,
      ),
      const StrokeCapDiagram(
        name: 'round_cap',
        cap: StrokeCap.round,
      ),
      const StrokeCapDiagram(
        name: 'square_cap',
        cap: StrokeCap.square,
      ),
    ]);
  }

  @override
  final String category = 'dart-ui';

  final List<StrokeCapDiagram> _diagrams = <StrokeCapDiagram>[];

  @override
  Future<List<StrokeCapDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(StrokeCapDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

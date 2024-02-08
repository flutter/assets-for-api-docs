// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const double _kFontSize = 14.0;

class StrokeCapDescription extends CustomPainter {
  StrokeCapDescription({
    this.filename,
    required this.cap,
  }) : _capPainter = _createLabelPainter(cap.toString());

  static const EdgeInsets padding = EdgeInsets.all(3.0);

  final String? filename;
  final StrokeCap cap;
  final TextPainter _capPainter;

  Widget get widget {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 130.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: CustomPaint(
            painter: this,
          ),
        ),
      ),
    );
  }

  static TextPainter _createLabelPainter(String label,
      {FontStyle style = FontStyle.normal}) {
    final TextPainter result = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: label,
        style: TextStyle(
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
    final Offset center = Offset(size.width / 2.0,
        (size.height - _capPainter.height - padding.vertical) / 2.0);
    final Offset start = Offset(0.0, center.dy);
    final Offset middle = Offset(size.width / 2.0, center.dy);

    final Paint startPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 20.0;
    final Paint linePaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = cap
      ..strokeWidth = 20.0;
    final Paint endPaint = Paint()
      ..color = Colors.deepPurpleAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = cap
      ..strokeWidth = 20.0;

    Path line = Path() // Line
      ..moveTo(start.dx, start.dy)
      ..lineTo(middle.dx, middle.dy);
    canvas.drawPath(line, linePaint);
    line = Path() // Start point, so that it doesn't show the starting end cap.
      ..moveTo(start.dx, start.dy)
      ..lineTo(start.dx, start.dy);
    canvas.drawPath(line, startPaint);
    line = Path() // End point, a different color to highlight the cap.
      ..moveTo(middle.dx, middle.dy)
      ..lineTo(middle.dx, middle.dy);
    canvas.drawPath(line, endPaint);
    _capPainter.paint(
      canvas,
      Offset(
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

class StrokeCapDiagram extends StatelessWidget with DiagramMetadata {
  const StrokeCapDiagram(
      {required this.name, this.cap = StrokeCap.round, super.key});

  @override
  final String name;
  final StrokeCap cap;

  @override
  Widget build(BuildContext context) {
    final StrokeCapDescription description = StrokeCapDescription(
      cap: cap,
    );

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(150.0, 100.0)),
      child: Container(
        padding: const EdgeInsets.all(18.0),
        color: Colors.white,
        child: CustomPaint(painter: description),
      ),
    );
  }
}

class StrokeCapDiagramStep extends DiagramStep {
  @override
  final String category = 'dart-ui';

  final List<StrokeCapDiagram> _diagrams = const <StrokeCapDiagram>[
    StrokeCapDiagram(
      name: 'butt_cap',
      cap: StrokeCap.butt,
    ),
    StrokeCapDiagram(
      name: 'round_cap',
    ),
    StrokeCapDiagram(
      name: 'square_cap',
      cap: StrokeCap.square,
    ),
  ];

  @override
  Future<List<StrokeCapDiagram>> get diagrams async => _diagrams;
}

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const double _kFontSize = 14.0;

class CurveDescription extends CustomPainter {
  CurveDescription(this.caption, this.curve) : _caption = _createLabelPainter(caption);

  final String caption;
  final Curve curve;

  Widget get widget {
    return new ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 130.0),
      child: new AspectRatio(
        aspectRatio: 1.7,
        child: new Padding(
          padding: new EdgeInsets.all(ui.window.devicePixelRatio),
          child: new CustomPaint(
            painter: this,
          ),
        ),
      ),
    );
  }

  static final TextPainter _t = _createLabelPainter('t', style: FontStyle.italic);
  static final TextPainter _x = _createLabelPainter('x', style: FontStyle.italic);
  static final TextPainter _zero = _createLabelPainter('0.0');
  static final TextPainter _one = _createLabelPainter('1.0');
  final TextPainter _caption;

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

  static final Paint _axisPaint = new Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5;

  static final Paint _dashPaint = new Paint()
    ..color = Colors.black45
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.0;

  static final Paint _graphPaint = new Paint()
    ..color = Colors.blue.shade900
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    assert(size != Size.zero);
    final double unit = _zero.width / 4.0;
    final double leftMargin = unit * 6.0;
    final double rightMargin = unit + _t.width;
    final double verticalHeadroom = size.height * 0.2;
    final Rect area = new Rect.fromLTRB(
      leftMargin,
      verticalHeadroom,
      size.width - rightMargin,
      size.height - verticalHeadroom,
    );
    final Path axes = new Path()
      ..moveTo(area.left, area.top - verticalHeadroom) // vertical axis
      ..lineTo(area.left, area.bottom + verticalHeadroom)
      ..moveTo(area.left - unit, area.top) // 1.0 tick
      ..lineTo(area.left, area.top)
      ..moveTo(area.left - unit, area.bottom) // horizontal axis
      ..lineTo(area.right, area.bottom)
      ..moveTo(area.right - unit, area.bottom - unit) // arrow
      ..lineTo(area.right, area.bottom)
      ..lineTo(area.right - unit, area.bottom + unit);
    canvas.drawPath(axes, _axisPaint);
    final Path dashLine = new Path();
    final double delta = 8.0 / area.width;
    assert(delta > 0.0);
    for (double t = 0.0; t < 1.0; t += delta) {
      final Offset point1 = new FractionalOffset(t, 0.0).withinRect(area);
      final Offset point2 = new FractionalOffset(t + delta / 2.0, 0.0).withinRect(area);
      dashLine
        ..moveTo(point1.dx, point1.dy)
        ..lineTo(point2.dx, point2.dy);
    }
    canvas.drawPath(dashLine, _dashPaint);
    _one.paint(canvas, new Offset(area.left - leftMargin, area.top - _one.height / 2.0));
    _x.paint(canvas, new Offset(unit, (area.bottom) / 2.0));
    _zero.paint(canvas, new Offset(area.left - leftMargin, area.bottom - _zero.height / 2.0));
    _t.paint(canvas, new Offset(size.width - rightMargin + unit, area.bottom - _t.height / 2.0));
    _caption.paint(
      canvas,
      new Offset(
        leftMargin + (area.width - _caption.width) / 2.0,
        size.height - (verticalHeadroom + _caption.height) / 2.0,
      ),
    );
    final Path graph = new Path()..moveTo(area.left, area.bottom);
    for (double t = 0.0; t <= 1.0; t += 1.0 / (area.width * ui.window.devicePixelRatio)) {
      final Offset point = new FractionalOffset(t, 1.0 - curve.transform(t)).withinRect(area);
      graph.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(graph, _graphPaint);
  }

  @override
  bool shouldRepaint(CurveDescription oldDelegate) {
    return caption != oldDelegate.caption || curve != oldDelegate.curve;
  }
}

class CurveDiagram extends StatelessWidget implements DiagramMetadata {
  CurveDiagram(
    String name,
    this.caption,
    Curve curve,
  )   : description = new CurveDescription(caption, curve),
        name = 'curve_$name';

  @override
  final String name;
  final String caption;
  final CurveDescription description;

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(300.0, 177.0)),
      child: new Container(
        padding: const EdgeInsets.all(7.0),
        color: Colors.white,
        child: new CustomPaint(painter: description),
      ),
    );
  }
}

class CurveDiagramStep extends DiagramStep {
  CurveDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.addAll(<CurveDiagram>[
      new CurveDiagram('bounce_in', 'Curves.bounceIn', Curves.bounceIn),
      new CurveDiagram('bounce_in_out', 'Curves.bounceInOut', Curves.bounceInOut),
      new CurveDiagram('bounce_out', 'Curves.bounceOut', Curves.bounceOut),
      new CurveDiagram('decelerate', 'Curves.decelerate', Curves.decelerate),
      new CurveDiagram('ease', 'Curves.ease', Curves.ease),
      new CurveDiagram('ease_in', 'Curves.easeIn', Curves.easeIn),
      new CurveDiagram('ease_in_out', 'Curves.easeInOut', Curves.easeInOut),
      new CurveDiagram('ease_out', 'Curves.easeOut', Curves.easeOut),
      new CurveDiagram('elastic_in', 'Curves.elasticIn', Curves.elasticIn),
      new CurveDiagram('elastic_in_out', 'Curves.elasticInOut', Curves.elasticInOut),
      new CurveDiagram('elastic_out', 'Curves.elasticOut', Curves.elasticOut),
      new CurveDiagram('fast_out_slow_in', 'Curves.fastOutSlowIn', Curves.fastOutSlowIn),
      new CurveDiagram('linear', 'Curves.linear', Curves.linear),
      new CurveDiagram('interval', 'const Interval(0.25, 0.75)', const Interval(0.25, 0.75)),
      new CurveDiagram('sawtooth', 'const SawTooth(3)', const SawTooth(3)),
      new CurveDiagram('threshold', 'const Threshold(0.75)', const Threshold(0.75)),
      new CurveDiagram('flipped', 'Curves.bounceIn.flipped', Curves.bounceIn.flipped),
      new CurveDiagram('flipped_curve', 'const FlippedCurve(Curves.bounceIn)', const FlippedCurve(Curves.bounceIn)),
    ]);
  }

  @override
  final String category = 'animation';

  final List<CurveDiagram> _diagrams = <CurveDiagram>[];

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final CurveDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

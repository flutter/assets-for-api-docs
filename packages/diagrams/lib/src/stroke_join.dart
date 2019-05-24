// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const double _kFontSize = 14.0;
const Duration _kAnimationDuration = Duration(seconds: 5);
const double _kAnimationFrameRate = 60.0;

class StrokeJoinDescription extends CustomPainter {
  StrokeJoinDescription({
    this.filename,
    this.angle,
    this.join,
    this.strokeMiterLimit,
  })  : _anglePainter = _createLabelPainter('θ = ${angle.round()}°'),
        _joinPainter = _createLabelPainter(join.toString()),
        _miterLimitPainter = _createLabelPainter(join == StrokeJoin.miter //
            ? 'Miter Limit: ${strokeMiterLimit.toStringAsFixed(1)}' + (strokeMiterLimit == 4.0 ? ' (default)' : '')
            : '');

  static const EdgeInsets padding = EdgeInsets.all(8.0);

  final String filename;
  final double angle;
  final StrokeJoin join;
  final double strokeMiterLimit;
  final TextPainter _anglePainter;
  final TextPainter _joinPainter;
  final TextPainter _miterLimitPainter;

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
    final Offset center = new Offset(size.width / 2.0, size.height / 2.0);
    final Offset start = new Offset(0.0, center.dy);
    final Offset middle = new Offset(size.width / 2.0, center.dy);
    final double radians = angle * math.pi / 180.0;
    final Offset end = new Offset(
          0.5 * size.height * math.cos(radians),
          0.5 * size.height * math.sin(radians),
        ) +
        center;
    final Offset shortEnd = new Offset(
          20.0 * math.cos(radians),
          20.0 * math.sin(radians),
        ) +
        center;

    final Paint linePaint = new Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = join
      ..strokeMiterLimit = strokeMiterLimit
      ..strokeWidth = 20.0;
    final Paint centerPaint = new Paint()
      ..color = Colors.deepPurpleAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = join
      ..strokeMiterLimit = strokeMiterLimit
      ..strokeWidth = 20.0;

    Path line = new Path() // Line
      ..moveTo(start.dx, start.dy)
      ..lineTo(middle.dx, middle.dy)
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(line, linePaint);
    line = new Path() // Center area, to highlight the part with the join.
      ..moveTo(start.dx + center.dy - 20.0, start.dy)
      ..lineTo(middle.dx, middle.dy)
      ..lineTo(shortEnd.dx, shortEnd.dy);
    canvas.drawPath(line, centerPaint);
    _anglePainter.paint(canvas, const Offset(3.0, 3.0));
    _miterLimitPainter.paint(canvas, new Offset(3.0, 6.0 + _anglePainter.height));
    _joinPainter.paint(
      canvas,
      new Offset(
        padding.left,
        size.height - (padding.bottom + _joinPainter.height),
      ),
    );
  }

  @override
  bool shouldRepaint(StrokeJoinDescription oldDelegate) {
    return angle != oldDelegate.angle || join != oldDelegate.join;
  }
}

class StrokeJoinDiagram extends StatefulWidget implements DiagramMetadata {
  const StrokeJoinDiagram({
    this.name,
    this.duration: _kAnimationDuration,
    this.startAngle: 0.0,
    this.endAngle: 360.0,
    this.join: StrokeJoin.miter,
    this.strokeMiterLimit: 4.0,
  });

  @override
  final String name;
  final Duration duration;
  final double startAngle;
  final double endAngle;
  final StrokeJoin join;
  final double strokeMiterLimit;

  @override
  StrokeJoinPainterState createState() => new StrokeJoinPainterState();
}

class StrokeJoinPainterState extends State<StrokeJoinDiagram> //
    with
        TickerProviderStateMixin<StrokeJoinDiagram> {
  AnimationController controller;

  @override
  void didUpdateWidget(StrokeJoinDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.value = 0.0;
    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
      duration: widget.duration,
      vsync: this,
      lowerBound: widget.startAngle,
      upperBound: widget.endAngle,
    )..addListener(() {
        setState(() {});
      });
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final StrokeJoinDescription description = new StrokeJoinDescription(
      angle: controller.value,
      join: widget.join,
      strokeMiterLimit: widget.strokeMiterLimit,
    );

    return new ConstrainedBox(
      constraints: new BoxConstraints.tight(const Size(300.0, 300.0)),
      child: new Container(
        padding: const EdgeInsets.all(18.0),
        color: Colors.white,
        child: new CustomPaint(painter: description),
      ),
    );
  }
}

class StrokeJoinDiagramStep extends DiagramStep<StrokeJoinDiagram> {
  StrokeJoinDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.addAll(<StrokeJoinDiagram>[
      const StrokeJoinDiagram(
        name: 'miter_0_join',
        join: StrokeJoin.miter,
        strokeMiterLimit: 0.0,
      ),
      const StrokeJoinDiagram(
        name: 'miter_4_join',
        join: StrokeJoin.miter,
        strokeMiterLimit: 4.0,
      ),
      const StrokeJoinDiagram(
        name: 'miter_6_join',
        join: StrokeJoin.miter,
        strokeMiterLimit: 6.0,
      ),
      const StrokeJoinDiagram(
        name: 'round_join',
        join: StrokeJoin.round,
      ),
      const StrokeJoinDiagram(
        name: 'bevel_join',
        join: StrokeJoin.bevel,
      ),
    ]);
  }

  @override
  final String category = 'dart-ui';

  final List<StrokeJoinDiagram> _diagrams = <StrokeJoinDiagram>[];

  @override
  Future<List<StrokeJoinDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(StrokeJoinDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kAnimationDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
  }
}

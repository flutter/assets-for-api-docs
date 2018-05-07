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

  static const EdgeInsets padding = const EdgeInsets.all(8.0);

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
          0.5 * 20.0 * math.cos(radians),
          0.5 * 20.0 * math.sin(radians),
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

    Path line = new Path()
      ..moveTo(start.dx, start.dy) // vertical axis
      ..lineTo(middle.dx, middle.dy)
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(line, linePaint);
    line = new Path()
      ..moveTo(start.dx + center.dy - 20.0, start.dy) // vertical axis
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

class StrokeJoinPainterWidget extends StatefulWidget {
  const StrokeJoinPainterWidget({
    this.filename,
    this.duration: const Duration(seconds: 6),
    this.startAngle: 0.0,
    this.endAngle: 360.0,
    this.join: StrokeJoin.miter,
    this.strokeMiterLimit: 4.0,
  });

  final String filename;
  final Duration duration;
  final double startAngle;
  final double endAngle;
  final StrokeJoin join;
  final double strokeMiterLimit;

  @override
  StrokeJoinPainterState createState() => new StrokeJoinPainterState();
}

class StrokeJoinPainterState extends State<StrokeJoinPainterWidget> //
    with
        TickerProviderStateMixin<StrokeJoinPainterWidget> {
  AnimationController controller;

  @override
  void didUpdateWidget(StrokeJoinPainterWidget oldWidget) {
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

class StrokeJoinDiagramStep extends DiagramStep {
  StrokeJoinDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'dart-ui';

  @override
  Future<List<File>> generateDiagrams() async {
    final List<StrokeJoinPainterWidget> strokes = <StrokeJoinPainterWidget>[
      const StrokeJoinPainterWidget(
        filename: 'miter_0_join',
        join: StrokeJoin.miter,
        strokeMiterLimit: 0.0,
      ),
      const StrokeJoinPainterWidget(
        filename: 'miter_4_join',
        join: StrokeJoin.miter,
        strokeMiterLimit: 4.0,
      ),
      const StrokeJoinPainterWidget(
        filename: 'miter_6_join',
        join: StrokeJoin.miter,
        strokeMiterLimit: 6.0,
      ),
      const StrokeJoinPainterWidget(
        filename: 'round_join',
        join: StrokeJoin.round,
      ),
      const StrokeJoinPainterWidget(
        filename: 'bevel_join',
        join: StrokeJoin.bevel,
      ),
    ];

    final List<File> outputFiles = <File>[];
    for (StrokeJoinPainterWidget stroke in strokes) {
      print('Drawing stroke diagram for ${stroke.join} (${stroke.filename})');
      controller.builder = (BuildContext context) => stroke;
      controller.filenameGenerator = () => new File(stroke.filename);
      outputFiles.add(
        await controller.drawAnimatedDiagramToFiles(end: const Duration(seconds: 6), frameDuration: const Duration(milliseconds: 200), metadata: <String, dynamic>{
          'name': stroke.filename,
          'category': category,
        }),
      );
    }
    return outputFiles;
  }
}

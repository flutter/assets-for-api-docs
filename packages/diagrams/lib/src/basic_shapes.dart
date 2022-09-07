// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart' hide Image;

import 'diagram_step.dart';
import 'utils.dart';

class BasicShapesDiagram extends StatelessWidget implements DiagramMetadata {
  const BasicShapesDiagram({
    required this.name,
    required this.painter,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  final String name;
  final CustomPainter painter;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: painter,
      child: SizedBox(
        width: width,
        height: height,
      ),
    );
  }
}

const TextStyle labelStyle = TextStyle(
  color: Color(0xff303030),
  fontWeight: FontWeight.bold,
  fontSize: 16.0,
);

const double divisionInterval = 40.0;

void paintCoordinateGrid(
  Canvas canvas, {
  int xDivisions = 10,
  int yDivisions = 6,
  Color color = const Color(0xff404040),
}) {
  final double rightEdge = divisionInterval * xDivisions;
  final double bottomEdge = divisionInterval * yDivisions;
  const double arrowNudge = 8.0;
  final double rightArrow = rightEdge - arrowNudge;
  final double bottomArrow = bottomEdge - arrowNudge;

  final Paint paint = Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.5;

  // Draw main lines going to the right and down

  canvas.drawPath(
    Path()
      ..moveTo(rightArrow, 0)
      ..lineTo(0, 0)
      ..lineTo(0, bottomArrow),
    paint,
  );

  // Draw arrows

  paint
    ..color = color
    ..style = PaintingStyle.fill;
  canvas.drawPath(
    Path()
      ..moveTo(rightArrow, -5)
      ..lineTo(rightArrow + 10, 0)
      ..lineTo(rightArrow, 5),
    paint,
  );
  canvas.drawPath(
    Path()
      ..moveTo(-5, bottomArrow)
      ..lineTo(0, bottomArrow + 10)
      ..lineTo(5, bottomArrow),
    paint,
  );

  // Draw labels

  paintLabel(
    canvas,
    '0,0',
    offset: const Offset(-4, -4),
    alignment: Alignment.topLeft,
    style: labelStyle,
  );

  paintLabel(
    canvas,
    '+x',
    offset: Offset(rightArrow, -8),
    alignment: Alignment.topCenter,
    style: labelStyle,
  );

  paintLabel(
    canvas,
    '+y',
    offset: Offset(-8, bottomArrow),
    alignment: Alignment.centerLeft,
    style: labelStyle,
  );
}

class LineDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.srcOver);
    canvas.save();
    canvas.translate(56.0, 48.0);

    paintCoordinateGrid(canvas);

    final Paint paint = Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    final Offset start = const Offset(2, 4) * divisionInterval;
    final Offset end = const Offset(8, 2) * divisionInterval;

    canvas.drawLine(
      start,
      end,
      paint,
    );

    paintLabel(
      canvas,
      'p1',
      offset: start + const Offset(0, -8),
      alignment: Alignment.topCenter,
      style: labelStyle,
    );

    paintLabel(
      canvas,
      'p2',
      offset: end + const Offset(0, -6),
      alignment: Alignment.topCenter,
      style: labelStyle,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(LineDiagramPainter oldDelegate) => true;
}

class RectDiagramPainter extends CustomPainter {
  RectDiagramPainter({
    this.showLeft = false,
    this.showTop = false,
    this.showRight = false,
    this.showBottom = false,
    this.showWidth = false,
    this.showHeight = false,
    this.showTopLeft = false,
    this.showBottomRight = false,
    this.showCenter = false,
  });

  final bool showLeft;
  final bool showTop;
  final bool showRight;
  final bool showBottom;
  final bool showWidth;
  final bool showHeight;
  final bool showTopLeft;
  final bool showBottomRight;
  final bool showCenter;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.srcOver);
    canvas.save();
    canvas.translate(showBottom ? 90 : 60, showBottom ? 60 : 50);

    final Paint paint = Paint()
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    final Rect rect = Rect.fromPoints(
      const Offset(2, 2) * divisionInterval,
      const Offset(8, 5) * divisionInterval,
    );
    final Offset topLeft = rect.topLeft;
    final Offset bottomRight = rect.bottomRight;

    canvas.drawRect(
      Rect.fromPoints(topLeft, bottomRight),
      paint,
    );

    paint
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    if (showLeft) {
      paintLabel(
        canvas,
        'left',
        offset: Offset(topLeft.dx, -8),
        alignment: Alignment.topCenter,
        style: labelStyle,
      );
      canvas.drawLine(
        Offset(topLeft.dx, 0),
        Offset(topLeft.dx, 16),
        paint,
      );
    }

    if (showTop) {
      paintLabel(
        canvas,
        'top',
        offset: Offset(-8, topLeft.dy),
        alignment: Alignment.centerLeft,
        style: labelStyle,
      );
      canvas.drawLine(
        Offset(0, topLeft.dy),
        Offset(16, topLeft.dy),
        paint,
      );
    }

    if (showRight) {
      paintLabel(
        canvas,
        'right',
        offset: Offset(bottomRight.dx, -8),
        alignment: Alignment.topCenter,
        style: labelStyle,
      );
      canvas.drawLine(
        Offset(bottomRight.dx, 0),
        Offset(bottomRight.dx, 16),
        paint,
      );
    }

    if (showBottom) {
      paintLabel(
        canvas,
        'bottom',
        offset: Offset(-8, bottomRight.dy),
        alignment: Alignment.centerLeft,
        style: labelStyle,
      );
      canvas.drawLine(
        Offset(0, bottomRight.dy),
        Offset(16, bottomRight.dy),
        paint,
      );
    }

    if (showHeight) {
      paintLabel(
        canvas,
        'height',
        offset: rect.centerRight + const Offset(42, 0),
        alignment: Alignment.centerRight,
        style: labelStyle,
      );
      canvas.drawPath(
        Path()
          ..moveTo(bottomRight.dx + 18, topLeft.dy)
          ..lineTo(bottomRight.dx + 24, topLeft.dy)
          ..lineTo(bottomRight.dx + 24, bottomRight.dy)
          ..lineTo(bottomRight.dx + 18, bottomRight.dy),
        paint,
      );
    }

    if (showWidth) {
      paintLabel(
        canvas,
        'width',
        offset: rect.bottomCenter + const Offset(0, 42),
        alignment: Alignment.bottomCenter,
        style: labelStyle,
      );
      canvas.drawPath(
        Path()
          ..moveTo(topLeft.dx, bottomRight.dy + 18)
          ..lineTo(topLeft.dx, bottomRight.dy + 24)
          ..lineTo(bottomRight.dx, bottomRight.dy + 24)
          ..lineTo(bottomRight.dx, bottomRight.dy + 18),
        paint,
      );
    }

    if (showTopLeft) {
      paintLabel(
        canvas,
        'a',
        offset: topLeft + const Offset(-6, -6),
        alignment: Alignment.topLeft,
        style: labelStyle,
      );
      canvas.drawCircle(topLeft, 4, Paint()..color = paint.color);
    }

    if (showBottomRight) {
      paintLabel(
        canvas,
        'b',
        offset: bottomRight + const Offset(-8, -8),
        alignment: Alignment.topLeft,
        style: labelStyle,
      );
      canvas.drawCircle(bottomRight, 4, Paint()..color = paint.color);
    }

    if (showCenter) {
      paintLabel(
        canvas,
        'center',
        offset: rect.center + const Offset(0, -8),
        alignment: Alignment.topCenter,
        style: labelStyle,
      );
      canvas.drawCircle(rect.center, 2.5, Paint()..color = paint.color);
    }

    paintCoordinateGrid(
      canvas,
      xDivisions: 11,
      yDivisions: 7,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(RectDiagramPainter oldDelegate) => true;
}

class OvalDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.srcOver);
    void drawRect(Rect rect, PaintingStyle style) {
      final Paint paint = Paint()
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..color = Colors.grey;

      canvas.drawRect(
        rect,
        paint,
      );

      paintLabel(
        canvas,
        'rect',
        offset: rect.topLeft + const Offset(0, -8),
        alignment: Alignment.topRight,
        style: labelStyle.copyWith(color: paint.color),
      );

      paint
        ..color = Colors.black
        ..style = style;

      canvas.drawOval(
        rect.deflate(
          style == PaintingStyle.stroke
              ? paint.strokeWidth
              : paint.strokeWidth / 2,
        ),
        paint,
      );

      paintLabel(
        canvas,
        '$style',
        offset: rect.center,
        style: labelStyle.copyWith(
          color: style == PaintingStyle.stroke ? Colors.black : Colors.white,
          fontSize: 12,
        ),
      );
    }

    drawRect(
      const Rect.fromLTRB(
        64,
        64,
        64 * 4,
        64 * 5,
      ),
      PaintingStyle.stroke,
    );

    drawRect(
      const Rect.fromLTRB(
        64 * 5,
        64 * 1.5,
        64 * 9,
        64 * 4.5,
      ),
      PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(LineDiagramPainter oldDelegate) => true;
}

class CircleDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.srcOver);
    canvas.save();
    canvas.translate(56.0, 48.0);

    paintCoordinateGrid(canvas, xDivisions: 13, yDivisions: 8);

    final Paint paint = Paint();

    final Offset center = const Offset(6.5, 4) * divisionInterval;
    final Rect rect = Rect.fromCircle(
      center: center,
      radius: 3 * divisionInterval,
    );

    paintLabel(
      canvas,
      'center',
      offset: center + const Offset(0, -8),
      alignment: Alignment.topCenter,
      style: labelStyle,
    );

    final double cx = rect.left + rect.width / 4;
    final double cy = rect.center.dy;
    paintLabel(
      canvas,
      'radius',
      offset: Offset(cx, cy + 8),
      alignment: Alignment.bottomCenter,
      style: labelStyle,
    );

    paint
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      rect.center,
      rect.centerLeft,
      paint,
    );

    paint
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawCircle(
      center,
      3,
      paint,
    );

    paint
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    canvas.drawCircle(
      center,
      rect.width / 2,
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(LineDiagramPainter oldDelegate) => true;
}

class RectSquareDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.white, BlendMode.srcOver);
    canvas.save();
    canvas.translate(56.0, 48.0);

    paintCoordinateGrid(canvas, xDivisions: 13, yDivisions: 8);

    final Paint paint = Paint();

    final Offset center = const Offset(6.5, 4) * divisionInterval;
    final Rect rect = Rect.fromCircle(
      center: center,
      radius: 3 * divisionInterval,
    );

    paintLabel(
      canvas,
      'center',
      offset: center + const Offset(0, -8),
      alignment: Alignment.topCenter,
      style: labelStyle,
    );

    final double cx = rect.left + rect.width / 4;
    final double cy = rect.center.dy;
    paintLabel(
      canvas,
      'radius',
      offset: Offset(cx, cy + 8),
      alignment: Alignment.bottomCenter,
      style: labelStyle,
    );

    paint
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      rect.center,
      rect.centerLeft,
      paint,
    );

    paint
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawCircle(
      center,
      3,
      paint,
    );

    paint
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..color = Colors.black;

    canvas.drawRect(
      rect,
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(LineDiagramPainter oldDelegate) => true;
}

class BasicShapesStep extends DiagramStep<BasicShapesDiagram> {
  BasicShapesStep(super.controller);

  @override
  final String category = 'dart-ui';

  @override
  Future<List<BasicShapesDiagram>> get diagrams async {
    return <BasicShapesDiagram>[
      BasicShapesDiagram(
        name: 'canvas_line',
        painter: LineDiagramPainter(),
        width: 500,
        height: 325,
      ),
      BasicShapesDiagram(
        name: 'rect_from_ltrb',
        painter: RectDiagramPainter(
          showLeft: true,
          showTop: true,
          showRight: true,
          showBottom: true,
        ),
        width: 580,
        height: 380,
      ),
      BasicShapesDiagram(
        name: 'rect_from_ltwh',
        painter: RectDiagramPainter(
          showLeft: true,
          showTop: true,
          showWidth: true,
          showHeight: true,
        ),
        width: 550,
        height: 370,
      ),
      BasicShapesDiagram(
        name: 'rect_from_points',
        painter: RectDiagramPainter(
          showTopLeft: true,
          showBottomRight: true,
        ),
        width: 550,
        height: 370,
      ),
      BasicShapesDiagram(
        name: 'rect_from_center',
        painter: RectDiagramPainter(
          showWidth: true,
          showHeight: true,
          showCenter: true,
        ),
        width: 550,
        height: 370,
      ),
      BasicShapesDiagram(
        name: 'rect_from_circle',
        painter: RectSquareDiagramPainter(),
        width: 625,
        height: 410,
      ),
      BasicShapesDiagram(
        name: 'canvas_oval',
        painter: OvalDiagramPainter(),
        width: 640,
        height: 384,
      ),
      BasicShapesDiagram(
        name: 'canvas_circle',
        painter: CircleDiagramPainter(),
        width: 625,
        height: 410,
      ),
    ];
  }

  @override
  Future<File> generateDiagram(BasicShapesDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;

import 'diagram_step.dart';
import 'utils.dart';

const double _kGridSize = 40.0;
const Color _kPrimaryColor = Colors.blue;
const Color _kForegroundColor = Colors.black;
const Color _kHintColor = Colors.grey;
const Color _kBackgroundColor = Colors.white;
const EdgeInsets _kLabelPadding = EdgeInsets.all(8.0);
const TextStyle _kLabelStyle = TextStyle(
  color: _kForegroundColor,
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

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
    return Container(
      color: _kBackgroundColor,
      child: CustomPaint(
        painter: painter,
        child: SizedBox(
          width: width,
          height: height,
        ),
      ),
    );
  }
}

void _paintOffset(
  Canvas canvas,
  Offset offset, {
  String? label,
  Alignment alignment = Alignment.bottomCenter,
  EdgeInsets padding = _kLabelPadding,
  bool control = false,
  Color color = _kPrimaryColor,
}) {
  if (control) {
    final Rect rect = Rect.fromCircle(center: offset, radius: 4.0);
    canvas.drawRect(rect, Paint()..color = color);
  } else {
    canvas.drawCircle(
      offset,
      4,
      Paint()..color = color,
    );
  }
  if (label != null) {
    paintLabel(
      canvas,
      label,
      offset: offset,
      padding: padding,
      alignment: alignment,
      style: _kLabelStyle,
    );
  }
}

void _paintXYPlane(
  Canvas canvas, {
  int width = 10,
  int height = 6,
  Color color = _kForegroundColor,
}) {
  final double rightEdge = _kGridSize * width;
  final double bottomEdge = _kGridSize * height;
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
    style: _kLabelStyle,
  );

  paintLabel(
    canvas,
    '+x',
    offset: Offset(rightArrow, -8),
    alignment: Alignment.topCenter,
    style: _kLabelStyle,
  );

  paintLabel(
    canvas,
    '+y',
    offset: Offset(-8, bottomArrow),
    alignment: Alignment.centerLeft,
    style: _kLabelStyle,
  );
}

class LineDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(56.0, 48.0);

    _paintXYPlane(canvas);

    final Paint paint = Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..color = _kForegroundColor;

    final Offset start = const Offset(2, 4) * _kGridSize;
    final Offset end = const Offset(8, 2) * _kGridSize;

    canvas.drawLine(
      start,
      end,
      paint,
    );

    paintLabel(
      canvas,
      'p1',
      offset: start,
      alignment: Alignment.topCenter,
      padding: _kLabelPadding,
      style: _kLabelStyle,
    );

    paintLabel(
      canvas,
      'p2',
      offset: end,
      alignment: Alignment.topCenter,
      padding: _kLabelPadding,
      style: _kLabelStyle,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(LineDiagramPainter oldDelegate) => true;
}

class RectConstructorDiagramPainter extends CustomPainter {
  RectConstructorDiagramPainter({
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
    canvas.save();
    canvas.translate(showBottom ? 90 : 60, showBottom ? 60 : 50);

    final Paint paint = Paint()
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..color = _kForegroundColor;

    final Rect rect = Rect.fromPoints(
      const Offset(2, 2) * _kGridSize,
      const Offset(8, 5) * _kGridSize,
    );
    final Offset topLeft = rect.topLeft;
    final Offset bottomRight = rect.bottomRight;

    canvas.drawRect(
      Rect.fromPoints(topLeft, bottomRight),
      paint,
    );

    paint
      ..color = _kPrimaryColor
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
        style: _kLabelStyle,
      );
      canvas.drawLine(
        Offset(topLeft.dx, 1),
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
        style: _kLabelStyle,
      );
      canvas.drawLine(
        Offset(1, topLeft.dy),
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
        style: _kLabelStyle,
      );
      canvas.drawLine(
        Offset(bottomRight.dx, 1),
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
        style: _kLabelStyle,
      );
      canvas.drawLine(
        Offset(1, bottomRight.dy),
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
        style: _kLabelStyle,
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
        style: _kLabelStyle,
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
        offset: topLeft,
        alignment: Alignment.topLeft,
        padding: _kLabelPadding,
        style: _kLabelStyle,
      );
      canvas.drawCircle(topLeft, 4, Paint()..color = paint.color);
    }

    if (showBottomRight) {
      paintLabel(
        canvas,
        'b',
        offset: bottomRight,
        alignment: Alignment.topLeft,
        padding: _kLabelPadding,
        style: _kLabelStyle,
      );
      canvas.drawCircle(bottomRight, 4, Paint()..color = paint.color);
    }

    if (showCenter) {
      paintLabel(
        canvas,
        'center',
        offset: rect.center,
        alignment: Alignment.topCenter,
        padding: _kLabelPadding,
        style: _kLabelStyle,
      );
      canvas.drawCircle(rect.center, 4, Paint()..color = paint.color);
    }

    _paintXYPlane(canvas, width: 11, height: 7);

    canvas.restore();
  }

  @override
  bool shouldRepaint(RectConstructorDiagramPainter oldDelegate) => true;
}

class OvalDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void drawRect(Rect rect, PaintingStyle style) {
      final Paint paint = Paint()
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..color = _kHintColor;

      canvas.drawRect(
        rect,
        paint,
      );

      paintLabel(
        canvas,
        'rect',
        offset: rect.topLeft + const Offset(0, -8),
        alignment: Alignment.topRight,
        style: _kLabelStyle.copyWith(color: paint.color),
      );

      paint
        ..color = _kForegroundColor
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
        style: _kLabelStyle.copyWith(
          color: style == PaintingStyle.stroke
              ? _kForegroundColor
              : _kBackgroundColor,
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
  bool shouldRepaint(OvalDiagramPainter oldDelegate) => true;
}

class RectDiagramPainter extends CustomPainter {
  RectDiagramPainter({this.radius = 0.0, this.label = 'rect'});

  final double radius;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    void drawRect(RRect rect, PaintingStyle style) {
      final Paint paint = Paint()
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..color = _kForegroundColor;

      canvas.drawRRect(
        rect,
        paint,
      );

      paintLabel(
        canvas,
        label,
        offset: rect.outerRect.topLeft + const Offset(0, -8),
        alignment: Alignment.topRight,
        style: _kLabelStyle,
      );

      paint
        ..color = _kForegroundColor
        ..style = style;

      canvas.drawRRect(
        rect,
        paint,
      );

      paintLabel(
        canvas,
        '$style',
        offset: rect.center,
        style: _kLabelStyle.copyWith(
          color: style == PaintingStyle.stroke
              ? _kForegroundColor
              : _kBackgroundColor,
          fontSize: 12,
        ),
      );
    }

    drawRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(
          64,
          64,
          64 * 4,
          64 * 5,
        ),
        Radius.circular(radius),
      ),
      PaintingStyle.stroke,
    );

    drawRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(
          64 * 5,
          64 * 1.5,
          64 * 9,
          64 * 4.5,
        ),
        Radius.circular(radius),
      ),
      PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(RectDiagramPainter oldDelegate) => true;
}

class CircleDiagramPainter extends CustomPainter {
  CircleDiagramPainter({this.square = false});

  final bool square;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(56, 48);

    _paintXYPlane(canvas, width: 13, height: 8);

    final Paint paint = Paint();

    final Offset center = const Offset(6.5, 4) * _kGridSize;
    final Rect rect = Rect.fromCircle(
      center: center,
      radius: 3 * _kGridSize,
    );

    paintLabel(
      canvas,
      'center',
      offset: center + const Offset(0, -8),
      alignment: Alignment.topCenter,
      style: _kLabelStyle,
    );

    final double cx = rect.left + rect.width / 4;
    final double cy = rect.center.dy;
    paintLabel(
      canvas,
      'radius',
      offset: Offset(cx, cy + 8),
      alignment: Alignment.bottomCenter,
      style: _kLabelStyle,
    );

    paint
      ..color = _kPrimaryColor
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
      ..color = _kPrimaryColor;

    canvas.drawCircle(
      center,
      4,
      paint,
    );

    paint
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..color = _kForegroundColor
      ..strokeJoin = StrokeJoin.miter;

    if (square) {
      canvas.drawRect(
        rect,
        paint,
      );
    } else {
      canvas.drawCircle(
        center,
        rect.width / 2,
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CircleDiagramPainter oldDelegate) => true;
}

class ConicToDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double x = size.width * 0.1;
    final double y = (size.height * 0.9) - 15.0;
    final double x2 = size.width * 0.9;
    final double y2 = y;
    final double x1 = (x + x2) / 2;
    final double y1 = size.height * 0.1;

    final Paint paint = Paint()
      ..color = _kHintColor
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..conicTo(x1, y1, x2, y2, 2.0),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..conicTo(x1, y1, x2, y2, 0.5),
      paint,
    );

    paint.color = _kForegroundColor;

    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..conicTo(x1, y1, x2, y2, 1),
      paint,
    );

    _paintOffset(
      canvas,
      Offset(x1, y1),
      label: 'x1,y1',
      control: true,
    );
    _paintOffset(canvas, Offset(x2, y2), label: 'x2,y2');

    paintLabel(
      canvas,
      'w = 2',
      offset: Offset(size.width / 2, size.height * 0.353 + 8),
      style: _kLabelStyle.copyWith(color: _kHintColor),
      alignment: Alignment.bottomCenter,
    );

    paintLabel(
      canvas,
      'w = 1',
      offset: Offset(size.width / 2, size.height * 0.48 + 8),
      style: _kLabelStyle,
      alignment: Alignment.bottomCenter,
    );

    paintLabel(
      canvas,
      'w = 0.5',
      offset: Offset(size.width / 2, size.height * 0.605 + 8),
      style: _kLabelStyle.copyWith(color: _kHintColor),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  bool shouldRepaint(ConicToDiagramPainter oldDelegate) => true;
}

class QuadraticToDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double x = size.width * 0.1;
    final double y = (size.height * 0.9) - 15.0;
    final double x2 = size.width * 0.9;
    final double y2 = y;
    final double x1 = (x + x2) / 2;
    final double y1 = size.height * 0.1;

    final Paint paint = Paint()
      ..color = _kForegroundColor
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(x1, y1, x2, y2),
      paint,
    );

    _paintOffset(
      canvas,
      Offset(x1, y1),
      label: 'x1,y1',
      control: true,
    );
    _paintOffset(canvas, Offset(x2, y2), label: 'x2,y2');
  }

  @override
  bool shouldRepaint(QuadraticToDiagramPainter oldDelegate) => true;
}

class CubicToDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double x = size.width * 0.1;
    final double y = size.height * 0.5;
    final double x1 = size.width * 0.3;
    final double y1 = size.height * 0.15;
    final double x2 = size.width * 0.7;
    final double y2 = size.height * 0.85;
    final double x3 = size.width * 0.9;
    final double y3 = size.height * 0.5;

    final Paint paint = Paint()
      ..color = _kHintColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(x, y),
      Offset(x1, y1),
      paint,
    );

    canvas.drawLine(
      Offset(x2, y2),
      Offset(x3, y3),
      paint,
    );

    paint
      ..color = _kForegroundColor
      ..strokeWidth = 5.0;

    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..cubicTo(x1, y1, x2, y2, x3, y3),
      paint,
    );

    _paintOffset(
      canvas,
      Offset(x1, y1),
      label: 'x1,y1',
      control: true,
      alignment: Alignment.topCenter,
    );
    _paintOffset(
      canvas,
      Offset(x2, y2),
      label: 'x2,y2',
      control: true,
    );
    _paintOffset(
      canvas,
      Offset(x3, y3),
      label: 'x3,y3',
      alignment: Alignment.topCenter,
    );
  }

  @override
  bool shouldRepaint(CubicToDiagramPainter oldDelegate) => true;
}

class RadiusDiagramPainter extends CustomPainter {
  RadiusDiagramPainter({required this.radius});

  final Radius radius;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(
      size.width * 0.6 - radius.x,
      size.height * 0.6 - radius.y,
      size.width + 200,
      size.height + 200,
    );
    final RRect rrect = RRect.fromRectAndRadius(rect, radius);
    final Offset center = rect.topLeft + Offset(radius.x, radius.y);

    canvas.drawLine(
      center,
      center - Offset(radius.x, 0),
      Paint()
        ..color = _kPrimaryColor
        ..strokeWidth = 5,
    );
    paintLabel(
      canvas,
      radius.x == radius.y ? 'radius' : 'x',
      offset: Offset(rect.left + radius.x / 2, rect.top + radius.y),
      style: _kLabelStyle,
      alignment: Alignment.bottomCenter,
      padding: _kLabelPadding,
    );

    if (radius.x != radius.y) {
      canvas.drawLine(
        center,
        center - Offset(0, radius.y),
        Paint()
          ..color = _kPrimaryColor
          ..strokeWidth = 5,
      );
      paintLabel(
        canvas,
        'y',
        offset: Offset(rect.left + radius.x, rect.top + radius.y / 2),
        style: _kLabelStyle,
        alignment: Alignment.centerRight,
        padding: _kLabelPadding,
      );
    }

    _paintOffset(canvas, center, color: _kForegroundColor);

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _kForegroundColor
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke,
    );

    final ui.Rect bottomFadeRect = Rect.fromLTRB(
      rect.left - 8,
      size.height - 64,
      rect.left + 8,
      size.height,
    );
    canvas.drawRect(
      bottomFadeRect,
      Paint()
        ..shader = ui.Gradient.linear(
          bottomFadeRect.topLeft,
          bottomFadeRect.bottomLeft,
          <Color>[
            _kBackgroundColor.withOpacity(0),
            _kBackgroundColor,
          ],
        ),
    );

    final ui.Rect rightFadeRect = Rect.fromLTRB(
      size.width - 64,
      rect.top - 8,
      size.width,
      rect.top + 8,
    );
    canvas.drawRect(
      rightFadeRect,
      Paint()
        ..shader = ui.Gradient.linear(
          rightFadeRect.topLeft,
          rightFadeRect.topRight,
          <Color>[
            _kBackgroundColor.withOpacity(0),
            _kBackgroundColor,
          ],
        ),
    );
  }

  @override
  bool shouldRepaint(RadiusDiagramPainter oldDelegate) => true;
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
        name: 'canvas_rect',
        painter: RectDiagramPainter(),
        width: 640,
        height: 384,
      ),
      BasicShapesDiagram(
        name: 'canvas_rrect',
        painter: RectDiagramPainter(
          label: 'rrect',
          radius: 24,
        ),
        width: 640,
        height: 384,
      ),
      BasicShapesDiagram(
        name: 'rect_from_ltrb',
        painter: RectConstructorDiagramPainter(
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
        painter: RectConstructorDiagramPainter(
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
        painter: RectConstructorDiagramPainter(
          showTopLeft: true,
          showBottomRight: true,
        ),
        width: 550,
        height: 370,
      ),
      BasicShapesDiagram(
        name: 'rect_from_center',
        painter: RectConstructorDiagramPainter(
          showWidth: true,
          showHeight: true,
          showCenter: true,
        ),
        width: 550,
        height: 370,
      ),
      BasicShapesDiagram(
        name: 'rect_from_circle',
        painter: CircleDiagramPainter(square: true),
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
      BasicShapesDiagram(
        name: 'path_conic_to',
        painter: ConicToDiagramPainter(),
        width: 600,
        height: 350,
      ),
      BasicShapesDiagram(
        name: 'path_quadratic_to',
        painter: QuadraticToDiagramPainter(),
        width: 600,
        height: 350,
      ),
      BasicShapesDiagram(
        name: 'path_cubic_to',
        painter: CubicToDiagramPainter(),
        width: 500,
        height: 350,
      ),
      BasicShapesDiagram(
        name: 'radius_circular',
        painter: RadiusDiagramPainter(
          radius: const Radius.circular(96),
        ),
        width: 500,
        height: 350,
      ),
      BasicShapesDiagram(
        name: 'radius_elliptical',
        painter: RadiusDiagramPainter(
          radius: const Radius.elliptical(144, 96),
        ),
        width: 500,
        height: 350,
      ),
    ];
  }

  @override
  Future<File> generateDiagram(BasicShapesDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

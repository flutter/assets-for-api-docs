// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;

import 'diagram_step.dart';
import 'utils.dart';

const double _kGridSize = 40.0;
const EdgeInsets _kLabelPadding = EdgeInsets.all(8.0);

class ShapeDiagramTheme {
  ShapeDiagramTheme({
    required this.indicatorColor,
    required this.foregroundColor,
    required this.xyPlaneColor,
    required this.shapeColor,
    required this.hintColor,
  });

  final Color indicatorColor;
  final Color foregroundColor;
  final Color xyPlaneColor;
  final Color shapeColor;
  final Color hintColor;

  static final ShapeDiagramTheme light = ShapeDiagramTheme(
    indicatorColor: Colors.blue,
    foregroundColor: Colors.black,
    xyPlaneColor: Colors.grey.shade800,
    shapeColor: Colors.grey.shade800,
    hintColor: Colors.grey,
  );

  static ShapeDiagramTheme get dark => ShapeDiagramTheme(
    indicatorColor: Colors.white,
    foregroundColor: Colors.white,
    xyPlaneColor: Colors.grey,
    shapeColor: Colors.blue,
    hintColor: Colors.grey,
  );

  late final TextStyle labelStyle = TextStyle(
    color: foregroundColor,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  void paintXYPlane(Canvas canvas, {int width = 10, int height = 6}) {
    final double rightEdge = _kGridSize * width;
    final double bottomEdge = _kGridSize * height;
    const double arrowNudge = 8.0;
    final double rightArrow = rightEdge - arrowNudge;
    final double bottomArrow = bottomEdge - arrowNudge;

    final Paint paint = Paint()
      ..color = xyPlaneColor
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
      ..color = xyPlaneColor
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

  void paintOffset(
    Canvas canvas,
    Offset offset, {
    String? label,
    Alignment alignment = Alignment.bottomCenter,
    EdgeInsets padding = _kLabelPadding,
    bool control = false,
    Color? color,
  }) {
    color ??= indicatorColor;
    if (control) {
      final Rect rect = Rect.fromCircle(center: offset, radius: 4.0);
      canvas.drawRect(rect, Paint()..color = color);
    } else {
      canvas.drawCircle(offset, 4, Paint()..color = color);
    }
    if (label != null) {
      paintLabel(
        canvas,
        label,
        offset: offset,
        padding: padding,
        alignment: alignment,
        style: labelStyle,
      );
    }
  }
}

class BasicShapesDiagram extends StatelessWidget with DiagramMetadata {
  const BasicShapesDiagram({
    required this.name,
    required this.painter,
    required this.width,
    required this.height,
    this.dark = false,
    super.key,
  });

  @override
  final String name;
  final CustomPainter Function(ShapeDiagramTheme) painter;
  final double width;
  final double height;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: painter(dark ? ShapeDiagramTheme.dark : ShapeDiagramTheme.light),
      child: SizedBox(width: width, height: height),
    );
  }

  BasicShapesDiagram get asDark => BasicShapesDiagram(
    name: '${name}_dark',
    painter: painter,
    width: width,
    height: height,
    dark: true,
  );
}

class LineDiagramPainter extends CustomPainter {
  LineDiagramPainter({required this.theme});

  final ShapeDiagramTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(56.0, 48.0);

    theme.paintXYPlane(canvas);

    final Paint paint = Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..color = theme.foregroundColor;

    final Offset start = const Offset(2, 4) * _kGridSize;
    final Offset end = const Offset(8, 2) * _kGridSize;

    canvas.drawLine(start, end, paint);

    paintLabel(
      canvas,
      'p1',
      offset: start,
      alignment: Alignment.topCenter,
      padding: _kLabelPadding,
      style: theme.labelStyle,
    );

    paintLabel(
      canvas,
      'p2',
      offset: end,
      alignment: Alignment.topCenter,
      padding: _kLabelPadding,
      style: theme.labelStyle,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(LineDiagramPainter oldDelegate) => true;
}

class RectConstructorDiagramPainter extends CustomPainter {
  RectConstructorDiagramPainter({
    required this.theme,
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

  final ShapeDiagramTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(showBottom ? 90 : 60, showBottom ? 60 : 50);

    final Paint paint = Paint()
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..color = theme.shapeColor;

    final Rect rect = Rect.fromPoints(
      const Offset(2, 2) * _kGridSize,
      const Offset(8, 5) * _kGridSize,
    );
    final Offset topLeft = rect.topLeft;
    final Offset bottomRight = rect.bottomRight;

    canvas.drawRect(Rect.fromPoints(topLeft, bottomRight), paint);

    paint
      ..color = theme.indicatorColor
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
        style: theme.labelStyle,
      );
      canvas.drawLine(Offset(topLeft.dx, 1), Offset(topLeft.dx, 16), paint);
    }

    if (showTop) {
      paintLabel(
        canvas,
        'top',
        offset: Offset(-8, topLeft.dy),
        alignment: Alignment.centerLeft,
        style: theme.labelStyle,
      );
      canvas.drawLine(Offset(1, topLeft.dy), Offset(16, topLeft.dy), paint);
    }

    if (showRight) {
      paintLabel(
        canvas,
        'right',
        offset: Offset(bottomRight.dx, -8),
        alignment: Alignment.topCenter,
        style: theme.labelStyle,
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
        style: theme.labelStyle,
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
        style: theme.labelStyle,
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
        style: theme.labelStyle,
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
        style: theme.labelStyle,
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
        style: theme.labelStyle,
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
        style: theme.labelStyle,
      );
      canvas.drawCircle(rect.center, 4, Paint()..color = paint.color);
    }

    theme.paintXYPlane(canvas, width: 11, height: 7);

    canvas.restore();
  }

  @override
  bool shouldRepaint(RectConstructorDiagramPainter oldDelegate) => true;
}

class OvalDiagramPainter extends CustomPainter {
  OvalDiagramPainter({required this.theme});

  final ShapeDiagramTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    void drawRect(Rect rect, PaintingStyle style) {
      final Paint paint = Paint()
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..color = theme.hintColor;

      canvas.drawRect(rect, paint);

      paintLabel(
        canvas,
        'rect',
        offset: rect.topLeft + const Offset(0, -8),
        alignment: Alignment.topRight,
        style: theme.labelStyle.copyWith(color: paint.color),
      );

      paint
        ..color = theme.foregroundColor
        ..style = style;

      if (style == PaintingStyle.stroke) {
        canvas.drawOval(rect.deflate(paint.strokeWidth), paint);
        paintLabel(
          canvas,
          '$style',
          offset: rect.center,
          style: theme.labelStyle.copyWith(
            color: theme.foregroundColor,
            fontSize: 12,
          ),
        );
      } else {
        canvas.saveLayer(null, Paint());
        canvas.drawOval(rect.deflate(paint.strokeWidth / 2), paint);
        // Punch a hole in the solid oval with dstOut
        canvas.saveLayer(null, Paint()..blendMode = BlendMode.dstOut);
        paintLabel(
          canvas,
          '$style',
          offset: rect.center,
          style: theme.labelStyle.copyWith(color: Colors.white, fontSize: 12),
        );
        canvas.restore();
        canvas.restore();
      }
    }

    drawRect(const Rect.fromLTRB(64, 64, 64 * 4, 64 * 5), PaintingStyle.stroke);

    drawRect(
      const Rect.fromLTRB(64 * 5, 64 * 1.5, 64 * 9, 64 * 4.5),
      PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(OvalDiagramPainter oldDelegate) => true;
}

class RectDiagramPainter extends CustomPainter {
  RectDiagramPainter({
    required this.theme,
    this.radius = 0.0,
    this.label = 'rect',
  });

  final ShapeDiagramTheme theme;
  final double radius;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    void drawRect(RRect rrect, PaintingStyle style) {
      final Paint paint = Paint()
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..color = theme.foregroundColor;

      canvas.drawRRect(rrect, paint);

      paintLabel(
        canvas,
        label,
        offset: rrect.outerRect.topLeft + const Offset(0, -8),
        alignment: Alignment.topRight,
        style: theme.labelStyle,
      );

      paint
        ..color = theme.foregroundColor
        ..style = style;

      if (style == PaintingStyle.stroke) {
        canvas.drawRRect(rrect, paint);
        paintLabel(
          canvas,
          '$style',
          offset: rrect.center,
          style: theme.labelStyle.copyWith(
            color: theme.foregroundColor,
            fontSize: 12,
          ),
        );
      } else {
        canvas.saveLayer(null, Paint());
        canvas.drawRRect(rrect, paint);
        // Punch a hole in the solid rrect with dstOut
        canvas.saveLayer(null, Paint()..blendMode = BlendMode.dstOut);
        paintLabel(
          canvas,
          '$style',
          offset: rrect.center,
          style: theme.labelStyle.copyWith(color: Colors.white, fontSize: 12),
        );
        canvas.restore();
        canvas.restore();
      }
    }

    drawRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(64, 64, 64 * 4, 64 * 5),
        Radius.circular(radius),
      ),
      PaintingStyle.stroke,
    );

    drawRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(64 * 5, 64 * 1.5, 64 * 9, 64 * 4.5),
        Radius.circular(radius),
      ),
      PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(RectDiagramPainter oldDelegate) => true;
}

class CircleDiagramPainter extends CustomPainter {
  CircleDiagramPainter({required this.theme, this.square = false});

  final ShapeDiagramTheme theme;
  final bool square;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(56, 48);

    theme.paintXYPlane(canvas, width: 13, height: 8);

    final Paint paint = Paint();

    final Offset center = const Offset(6.5, 4) * _kGridSize;
    final Rect rect = Rect.fromCircle(center: center, radius: 3 * _kGridSize);

    paintLabel(
      canvas,
      'center',
      offset: center + const Offset(0, -8),
      alignment: Alignment.topCenter,
      style: theme.labelStyle,
    );

    final double cx = rect.left + rect.width / 4;
    final double cy = rect.center.dy;
    paintLabel(
      canvas,
      'radius',
      offset: Offset(cx, cy + 8),
      alignment: Alignment.bottomCenter,
      style: theme.labelStyle,
    );

    paint
      ..color = theme.indicatorColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(rect.center, rect.centerLeft, paint);

    paint
      ..style = PaintingStyle.fill
      ..color = theme.indicatorColor;

    canvas.drawCircle(center, 4, paint);

    paint
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..color = theme.shapeColor
      ..strokeJoin = StrokeJoin.miter;

    if (square) {
      canvas.drawRect(rect, paint);
    } else {
      canvas.drawCircle(center, rect.width / 2, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CircleDiagramPainter oldDelegate) => true;
}

class ConicToDiagramPainter extends CustomPainter {
  ConicToDiagramPainter({required this.theme});

  final ShapeDiagramTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final double x = size.width * 0.1;
    final double y = (size.height * 0.9) - 15.0;
    final double x2 = size.width * 0.9;
    final double y2 = y;
    final double x1 = (x + x2) / 2;
    final double y1 = size.height * 0.1;

    final Paint paint = Paint()
      ..color = theme.hintColor
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

    paint.color = theme.shapeColor;

    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..conicTo(x1, y1, x2, y2, 1),
      paint,
    );

    theme.paintOffset(canvas, Offset(x1, y1), label: 'x1,y1', control: true);
    theme.paintOffset(canvas, Offset(x2, y2), label: 'x2,y2');

    paintLabel(
      canvas,
      'w = 2',
      offset: Offset(size.width / 2, size.height * 0.353 + 8),
      style: theme.labelStyle.copyWith(color: theme.hintColor),
      alignment: Alignment.bottomCenter,
    );

    paintLabel(
      canvas,
      'w = 1',
      offset: Offset(size.width / 2, size.height * 0.48 + 8),
      style: theme.labelStyle.copyWith(color: theme.shapeColor),
      alignment: Alignment.bottomCenter,
    );

    paintLabel(
      canvas,
      'w = 0.5',
      offset: Offset(size.width / 2, size.height * 0.605 + 8),
      style: theme.labelStyle.copyWith(color: theme.hintColor),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  bool shouldRepaint(ConicToDiagramPainter oldDelegate) => true;
}

class QuadraticToDiagramPainter extends CustomPainter {
  QuadraticToDiagramPainter({required this.theme});

  final ShapeDiagramTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final double x = size.width * 0.1;
    final double y = (size.height * 0.9) - 15.0;
    final double x2 = size.width * 0.9;
    final double y2 = y;
    final double x1 = (x + x2) / 2;
    final double y1 = size.height * 0.1;

    final Paint paint = Paint()
      ..color = theme.shapeColor
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..quadraticBezierTo(x1, y1, x2, y2),
      paint,
    );

    theme.paintOffset(canvas, Offset(x1, y1), label: 'x1,y1', control: true);
    theme.paintOffset(canvas, Offset(x2, y2), label: 'x2,y2');
  }

  @override
  bool shouldRepaint(QuadraticToDiagramPainter oldDelegate) => true;
}

class CubicToDiagramPainter extends CustomPainter {
  CubicToDiagramPainter({required this.theme});

  final ShapeDiagramTheme theme;

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
      ..color = theme.hintColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(x, y), Offset(x1, y1), paint);

    canvas.drawLine(Offset(x2, y2), Offset(x3, y3), paint);

    paint
      ..color = theme.shapeColor
      ..strokeWidth = 5.0;

    canvas.drawPath(
      Path()
        ..moveTo(x, y)
        ..cubicTo(x1, y1, x2, y2, x3, y3),
      paint,
    );

    theme.paintOffset(
      canvas,
      Offset(x1, y1),
      label: 'x1,y1',
      control: true,
      alignment: Alignment.topCenter,
    );
    theme.paintOffset(canvas, Offset(x2, y2), label: 'x2,y2', control: true);
    theme.paintOffset(
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
  RadiusDiagramPainter({required this.theme, required this.radius});

  final ShapeDiagramTheme theme;
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

    if (radius.x != radius.y) {
      canvas.drawLine(
        center,
        center - Offset(0, radius.y),
        Paint()
          ..color = theme.indicatorColor
          ..strokeWidth = 4,
      );
      paintLabel(
        canvas,
        'y',
        offset: Offset(rect.left + radius.x, rect.top + radius.y / 2),
        style: theme.labelStyle,
        alignment: Alignment.centerRight,
        padding: _kLabelPadding,
      );
    }

    canvas.saveLayer(null, Paint());
    canvas.drawLine(
      center,
      center - Offset(radius.x, 0),
      Paint()
        ..color = theme.indicatorColor
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    paintLabel(
      canvas,
      radius.x == radius.y ? 'radius' : 'x',
      offset: Offset(rect.left + radius.x / 2, rect.top + radius.y),
      style: theme.labelStyle,
      alignment: Alignment.bottomCenter,
      padding: _kLabelPadding,
    );

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = theme.shapeColor
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke,
    );

    canvas.drawPaint(
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(0, size.height),
          <Color>[Colors.white, Colors.white.withValues(alpha: 0)],
          <double>[1 - 64 / size.height, 1.0],
        )
        ..blendMode = BlendMode.dstIn,
    );

    canvas.drawPaint(
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, 0),
          <Color>[Colors.white, Colors.white.withValues(alpha: 0)],
          <double>[1 - 64 / size.width, 1.0],
        )
        ..blendMode = BlendMode.dstIn,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(RadiusDiagramPainter oldDelegate) => true;
}

class BasicShapesStep extends DiagramStep {
  @override
  final String category = 'dart-ui';

  @override
  Future<List<BasicShapesDiagram>> get diagrams async {
    final List<BasicShapesDiagram> lightDiagrams = <BasicShapesDiagram>[
      BasicShapesDiagram(
        name: 'canvas_line',
        painter: (ShapeDiagramTheme theme) => LineDiagramPainter(theme: theme),
        width: 500,
        height: 325,
      ),
      BasicShapesDiagram(
        name: 'canvas_rect',
        painter: (ShapeDiagramTheme theme) => RectDiagramPainter(theme: theme),
        width: 640,
        height: 384,
      ),
      BasicShapesDiagram(
        name: 'canvas_rrect',
        painter: (ShapeDiagramTheme theme) =>
            RectDiagramPainter(theme: theme, label: 'rrect', radius: 24),
        width: 640,
        height: 384,
      ),
      BasicShapesDiagram(
        name: 'rect_from_ltrb',
        painter: (ShapeDiagramTheme theme) => RectConstructorDiagramPainter(
          theme: theme,
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
        painter: (ShapeDiagramTheme theme) => RectConstructorDiagramPainter(
          theme: theme,
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
        painter: (ShapeDiagramTheme theme) => RectConstructorDiagramPainter(
          theme: theme,
          showTopLeft: true,
          showBottomRight: true,
        ),
        width: 550,
        height: 370,
      ),
      BasicShapesDiagram(
        name: 'rect_from_center',
        painter: (ShapeDiagramTheme theme) => RectConstructorDiagramPainter(
          theme: theme,
          showWidth: true,
          showHeight: true,
          showCenter: true,
        ),
        width: 550,
        height: 370,
      ),
      BasicShapesDiagram(
        name: 'rect_from_circle',
        painter: (ShapeDiagramTheme theme) =>
            CircleDiagramPainter(theme: theme, square: true),
        width: 625,
        height: 410,
      ),
      BasicShapesDiagram(
        name: 'canvas_oval',
        painter: (ShapeDiagramTheme theme) => OvalDiagramPainter(theme: theme),
        width: 640,
        height: 384,
      ),
      BasicShapesDiagram(
        name: 'canvas_circle',
        painter: (ShapeDiagramTheme theme) =>
            CircleDiagramPainter(theme: theme),
        width: 625,
        height: 410,
      ),
      BasicShapesDiagram(
        name: 'path_conic_to',
        painter: (ShapeDiagramTheme theme) =>
            ConicToDiagramPainter(theme: theme),
        width: 600,
        height: 350,
      ),
      BasicShapesDiagram(
        name: 'path_quadratic_to',
        painter: (ShapeDiagramTheme theme) =>
            QuadraticToDiagramPainter(theme: theme),
        width: 600,
        height: 350,
      ),
      BasicShapesDiagram(
        name: 'path_cubic_to',
        painter: (ShapeDiagramTheme theme) =>
            CubicToDiagramPainter(theme: theme),
        width: 500,
        height: 350,
      ),
      BasicShapesDiagram(
        name: 'radius_circular',
        painter: (ShapeDiagramTheme theme) => RadiusDiagramPainter(
          theme: theme,
          radius: const Radius.circular(96),
        ),
        width: 500,
        height: 350,
      ),
      BasicShapesDiagram(
        name: 'radius_elliptical',
        painter: (ShapeDiagramTheme theme) => RadiusDiagramPainter(
          theme: theme,
          radius: const Radius.elliptical(144, 96),
        ),
        width: 500,
        height: 350,
      ),
    ];

    return <BasicShapesDiagram>[
      ...lightDiagrams,
      for (final BasicShapesDiagram diagram in lightDiagrams) diagram.asDark,
    ];
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;

import 'diagram_step.dart';
import 'utils.dart';

const ImageProvider _backgroundImageProvider = ExactAssetImage(
  'assets/blend_mode_destination.jpeg',
  package: 'diagrams',
);

ui.Image? _backgroundImage;

class ClipDiagram extends StatelessWidget with DiagramMetadata {
  const ClipDiagram({required this.name, required this.painter, super.key});

  @override
  final String name;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomPaint(
        painter: painter,
        child: const SizedBox(width: 700, height: 400),
      ),
    );
  }
}

void _drawBackground(ui.Canvas canvas, ui.Size size) {
  final FittedSizes sizes = applyBoxFit(
    BoxFit.cover,
    Size(
      _backgroundImage!.width.toDouble(),
      _backgroundImage!.height.toDouble(),
    ),
    size,
  );
  canvas.drawImageRect(
    _backgroundImage!,
    Offset.zero & sizes.source,
    Offset.zero & sizes.destination,
    Paint(),
  );
}

class ClipRectPainter extends CustomPainter {
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.saveLayer(Offset.zero & size, Paint()..color = Colors.white30);
    _drawBackground(canvas, size);
    canvas.restore();

    const Rect rect = Rect.fromLTWH(100, 100, 500.0, 200.0);

    canvas.save();
    canvas.clipRect(rect);
    _drawBackground(canvas, size);
    canvas.restore();

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 3.0;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(ClipRectPainter oldDelegate) => false;
}

class ClipRRectPainter extends CustomPainter {
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.saveLayer(Offset.zero & size, Paint()..color = Colors.white30);
    _drawBackground(canvas, size);
    canvas.restore();

    const Rect rect = Rect.fromLTWH(100, 100, 500.0, 200.0);
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(32.0),
    );

    canvas.save();
    canvas.clipRRect(rrect);
    _drawBackground(canvas, size);
    canvas.restore();

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 3.0;
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(ClipRectPainter oldDelegate) => false;
}

class ClipPathPainter extends CustomPainter {
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.saveLayer(Offset.zero & size, Paint()..color = Colors.white30);
    _drawBackground(canvas, size);
    canvas.restore();

    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double leftAnchorX = cx - 150;
    final double rightAnchorX = cx + 150;
    final double middleAnchorY = cy - 25;
    final double topAnchorY = cy - 85;
    final double bottomAnchorY = cy + 150;
    const double bottomControl = 20.0;
    const double topControl = 60.0;
    const double middleControl = 75.0;

    final Path path = Path()
      ..moveTo(cx, bottomAnchorY)
      ..cubicTo(
        cx - bottomControl,
        bottomAnchorY,
        leftAnchorX,
        middleAnchorY + middleControl,
        leftAnchorX,
        middleAnchorY,
      )
      ..cubicTo(
        leftAnchorX,
        middleAnchorY - middleControl,
        cx - topControl,
        topAnchorY - topControl,
        cx,
        topAnchorY,
      )
      ..cubicTo(
        cx + topControl,
        topAnchorY - topControl,
        rightAnchorX,
        middleAnchorY - middleControl,
        rightAnchorX,
        middleAnchorY,
      )
      ..cubicTo(
        rightAnchorX,
        middleAnchorY + middleControl,
        cx + bottomControl,
        bottomAnchorY,
        cx,
        bottomAnchorY,
      );

    canvas.save();
    canvas.clipPath(path);
    _drawBackground(canvas, size);
    canvas.restore();

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 3.0;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ClipRectPainter oldDelegate) => false;
}

class ClipDiagramStep extends DiagramStep {
  @override
  final String category = 'dart-ui';

  @override
  Future<List<ClipDiagram>> get diagrams async {
    _backgroundImage ??= await getImage(_backgroundImageProvider);
    return <ClipDiagram>[
      ClipDiagram(name: 'clip_rect', painter: ClipRectPainter()),
      ClipDiagram(name: 'clip_rrect', painter: ClipRRectPainter()),
      ClipDiagram(name: 'clip_path', painter: ClipPathPainter()),
    ];
  }
}

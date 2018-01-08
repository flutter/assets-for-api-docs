// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Hole extends StatelessWidget {
  const Hole({
    Key key,
    this.color: const Color(0xFFFFFFFF),
    this.child,
  }) : super(key: key);

  final Color color;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: 1.0,
      child: new Padding(
        padding: const EdgeInsets.all(4.0),
        child: new Placeholder(
          strokeWidth: 2.0,
          color: color,
        ),
      ),
    );
  }
}

class Label {
  const Label(this.key, this.text, this.anchor);
  final GlobalKey key;
  final String text;
  final FractionalOffset anchor;
}

typedef void PaintMessageCallback(String message);

class Labeller extends CustomPainter {
  Labeller({
    this.labels,
    this.heroKey,
    this.canvasKey,
    @required this.filename,
    this.onPaintMessage: print,
  }) : assert(onPaintMessage != null) {
    _painters = <Label, TextPainter>{};
    for (Label label in labels) {
      final TextPainter painter = new TextPainter(
          textDirection: TextDirection.ltr,
          text: new TextSpan(text: label.text, style: _labelTextStyle));
      painter.layout();
      _painters[label] = painter;
    }
  }

  final List<Label> labels;
  final GlobalKey heroKey;
  final GlobalKey canvasKey;
  final String filename;
  final PaintMessageCallback onPaintMessage;

  Map<Label, TextPainter> _painters;

  static const TextStyle _labelTextStyle = const TextStyle(color: const Color(0xFF000000));

  static const double margin = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox hero = heroKey.currentContext.findRenderObject();
    final RenderBox diagram = canvasKey.currentContext.findRenderObject();
    final Paint dotPaint = new Paint();
    final Paint linePaint = new Paint()..strokeWidth = 2.0;
    final Offset heroTopLeft = diagram.globalToLocal(hero.localToGlobal(Offset.zero));
    double leftmost = heroTopLeft.dx;
    double rightmost = heroTopLeft.dx + hero.size.width;
    double topmost = heroTopLeft.dy;
    double bottommost = heroTopLeft.dy + hero.size.height;
    for (Label label in labels) {
      final RenderBox box = label.key.currentContext.findRenderObject();
      final Offset anchor = diagram.globalToLocal(box.localToGlobal(label.anchor.alongSize(box.size)));
      final Offset anchorOnHero = anchor - heroTopLeft;
      final FractionalOffset relativeAnchor = new FractionalOffset.fromOffsetAndSize(anchorOnHero, hero.size);
      final double distanceToTop = anchorOnHero.dy;
      final double distanceToBottom = hero.size.height - anchorOnHero.dy;
      final double distanceToLeft = anchorOnHero.dx;
      final double distanceToRight = hero.size.width - anchorOnHero.dx;
      Offset labelPosition;
      Offset textPosition = Offset.zero;
      final TextPainter painter = _painters[label];
      if (distanceToTop <= distanceToLeft &&
          distanceToTop <= distanceToRight &&
          distanceToTop <= distanceToBottom) {
        labelPosition = new Offset(anchor.dx + (relativeAnchor.dx - 0.5) * margin, heroTopLeft.dy - margin);
        textPosition = new Offset(labelPosition.dx - painter.width / 2.0, labelPosition.dy - painter.height);
      } else if (distanceToBottom < distanceToLeft &&
          distanceToBottom < distanceToRight &&
          distanceToTop > distanceToBottom) {
        labelPosition = new Offset(anchor.dx, heroTopLeft.dy + hero.size.height + margin);
        textPosition = new Offset(labelPosition.dx - painter.width / 2.0, labelPosition.dy);
      } else if (distanceToLeft < distanceToRight) {
        labelPosition = new Offset(heroTopLeft.dx - margin, anchor.dy);
        textPosition = new Offset(labelPosition.dx - painter.width - 2.0, labelPosition.dy - painter.height / 2.0);
      } else if (distanceToLeft > distanceToRight) {
        labelPosition = new Offset(heroTopLeft.dx + hero.size.width + margin, anchor.dy);
        textPosition = new Offset(labelPosition.dx, labelPosition.dy - painter.height / 2.0);
      } else {
        labelPosition = new Offset(anchor.dx, heroTopLeft.dy - margin * 2.0);
        textPosition = new Offset(anchor.dx - painter.width / 2.0, anchor.dy - margin - painter.height);
      }
      canvas.drawCircle(anchor, 4.0, dotPaint);
      canvas.drawLine(anchor, labelPosition, linePaint);
      painter.paint(canvas, textPosition);
      leftmost = math.min(leftmost, textPosition.dx);
      rightmost = math.max(rightmost, textPosition.dx + painter.width);
      topmost = math.min(topmost, textPosition.dy);
      bottommost = math.max(bottommost, textPosition.dy + painter.height);
    }
    final double center = hero.size.center(heroTopLeft).dx;
    final double horizontalEdge = math.max(center - leftmost, rightmost - center) + margin;
    leftmost = center - horizontalEdge;
    rightmost = center + horizontalEdge;
    topmost -= margin;
    bottommost += margin;
    final Offset topLeft = diagram.localToGlobal(Offset.zero);
    final int w = ((rightmost - leftmost) * ui.window.devicePixelRatio).round();
    final int h = ((bottommost - topmost) * ui.window.devicePixelRatio).round();
    final int x = ((topLeft.dx + leftmost) * ui.window.devicePixelRatio).round();
    final int y = ((topLeft.dy + topmost) * ui.window.devicePixelRatio).round();
    onPaintMessage(
      'The following command extracts the image from a screenshot file.\n'
      'You can obtain a screenshot by pressing "s" in the "flutter run" console.\n'
      'Make sure the whole diagram is visible (you may need to rotate the device).\n'
      'COMMAND: convert flutter_01.png -crop ${w}x$h+$x+$y -resize \'450x450>\' $filename'
    );
  }

  @override
  bool shouldRepaint(Labeller oldDelegate) {
    return labels != oldDelegate.labels || canvasKey != oldDelegate.canvasKey;
  }

  @override
  bool hitTest(Offset position) => false;
}

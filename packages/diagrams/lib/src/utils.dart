// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// This defines a colored placeholder with padding, used to represent a
/// generic widget in diagrams.
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

/// This is a struct to represent a text label in the [LabelPainterWidget].
class Label {
  const Label(this.key, this.text, this.anchor);
  final GlobalKey key;
  final String text;
  final FractionalOffset anchor;
}

/// The will take a list of locations that a label should point to, defined
/// by the [Label] structure.
class LabelPainterWidget extends StatelessWidget {
  /// Creates a widget that paints labels in defined locations.
  ///
  /// All parameters are required and must not be null.
  LabelPainterWidget({
    @required GlobalKey key,
    @required List<Label> labels,
    @required GlobalKey heroKey,
  })  : assert(key != null),
        assert(labels != null),
        assert(heroKey != null),
        painter = new LabelPainter(labels: labels, heroKey: heroKey, canvasKey: key),
        super(key: key);

  final LabelPainter painter;

  @override
  Widget build(BuildContext context) => new CustomPaint(painter: painter);
}

/// The custom painter that [LabelPainterWidget] uses to paint the list of
/// labels it is given.
class LabelPainter extends CustomPainter {
  LabelPainter({
    this.labels,
    this.heroKey,
    this.canvasKey,
  }) {
    _painters = <Label, TextPainter>{};
    for (Label label in labels) {
      final TextPainter painter = new TextPainter(
        textDirection: TextDirection.ltr,
        text: new TextSpan(text: label.text, style: _labelTextStyle),
      );
      painter.layout();
      _painters[label] = painter;
    }
  }

  final List<Label> labels;
  final GlobalKey heroKey;
  final GlobalKey canvasKey;

  Map<Label, TextPainter> _painters;

  static const TextStyle _labelTextStyle = TextStyle(color: Color(0xFF000000));

  static const double margin = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox hero = heroKey.currentContext.findRenderObject();
    final RenderBox diagram = canvasKey.currentContext.findRenderObject();
    final Paint dotPaint = new Paint();
    final Paint linePaint = new Paint()..strokeWidth = 2.0;
    final Offset heroTopLeft = diagram.globalToLocal(hero.localToGlobal(Offset.zero));
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
      if (distanceToTop <= distanceToLeft && distanceToTop <= distanceToRight && distanceToTop <= distanceToBottom) {
        labelPosition = new Offset(anchor.dx + (relativeAnchor.dx - 0.5) * margin, heroTopLeft.dy - margin);
        textPosition = new Offset(labelPosition.dx - painter.width / 2.0, labelPosition.dy - painter.height);
      } else if (distanceToBottom < distanceToLeft && distanceToBottom < distanceToRight && distanceToTop > distanceToBottom) {
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
    }
  }

  @override
  bool shouldRepaint(LabelPainter oldDelegate) {
    return labels != oldDelegate.labels || canvasKey != oldDelegate.canvasKey;
  }

  @override
  bool hitTest(Offset position) => false;
}

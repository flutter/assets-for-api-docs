// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

class CurveDescription extends CustomPainter {
  CurveDescription(this.filename, this.caption, this.curve) :
    _caption = _createLabelPainter(caption);

  final String filename;

  final String caption;

  final Curve curve;

  GlobalKey get key => new GlobalObjectKey(this);

  Widget get widget => new KeyedSubtree(
    key: key,
    child: new ConstrainedBox(
      constraints: new BoxConstraints(maxWidth: 130.0),
      child: new AspectRatio(
        aspectRatio: 1.7,
        child: new Padding(
          padding: new EdgeInsets.all(ui.window.devicePixelRatio),
          child: new CustomPaint(
            painter: this,
          ),
        ),
      ),
    ),
  );

  static TextPainter _t = _createLabelPainter('t', style: FontStyle.italic);
  static TextPainter _x = _createLabelPainter('x', style: FontStyle.italic);
  static TextPainter _zero = _createLabelPainter('0.0');
  static TextPainter _one = _createLabelPainter('1.0');
  final TextPainter _caption;

  static TextPainter _createLabelPainter(String label, { FontStyle style: FontStyle.normal }) {
    TextPainter result = new TextPainter(
      text: new TextSpan(
        text: label,
        style: new TextStyle(
          color: Colors.black,
          fontStyle: style,
          fontSize: 6.0,
        ),
      )
    );
    result.layout();
    return result;
  }

  static Paint _axisPaint = new Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static Paint _dashPaint = new Paint()
    ..color = Colors.black45
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.0;

  static Paint _graphPaint = new Paint()
    ..color = Colors.blue.shade900
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    double unit = _zero.width / 4.0;
    double leftMargin = unit * 5.0;
    double rightMargin = unit + _t.width;
    double verticalHeadroom = size.height * 0.2;
    Rect area = new Rect.fromLTRB(
      leftMargin,
      verticalHeadroom,
      size.width - rightMargin,
      size.height - verticalHeadroom,
    );
    Path axes = new Path()
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
    Path dashLine = new Path();
    double delta = 1.0 / (area.width / 4.0);
    for (double t = 0.0; t < 1.0; t += delta) {
      Offset point1 = new FractionalOffset(t, 0.0).withinRect(area);
      Offset point2 = new FractionalOffset(t + delta / 2.0, 0.0).withinRect(area);
      dashLine
        ..moveTo(point1.dx, point1.dy)
        ..lineTo(point2.dx, point2.dy);
    }
    canvas.drawPath(dashLine, _dashPaint);
    _one.paint(canvas, new Offset(area.left - leftMargin, area.top - _one.height / 2.0));
    _x.paint(canvas, new Offset(unit, (area.bottom) / 2.0));
    _zero.paint(canvas, new Offset(area.left - leftMargin, area.bottom - _zero.height / 2.0));
    _t.paint(canvas, new Offset(size.width - rightMargin + unit, area.bottom - _t.height / 2.0));
    _caption.paint(canvas, new Offset(leftMargin + (area.width - _caption.width) / 2.0, size.height - (verticalHeadroom + _caption.height) / 2.0));
    Path graph = new Path()
      ..moveTo(area.left, area.bottom);
    for (double t = 0.0; t <= 1.0; t += 1.0 / (area.width * ui.window.devicePixelRatio)) {
      Offset point = new FractionalOffset(t, 1.0 - curve.transform(t)).withinRect(area);
      graph.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(graph, _graphPaint);
  }

  @override
  bool shouldRepaint(CurveDescription oldDelegate) {
    return caption != oldDelegate.caption
        || curve != oldDelegate.curve;
  }
}

void main() {
  List<CurveDescription> curves = <CurveDescription>[
    new CurveDescription('bounce_in', 'Curves.bounceIn', Curves.bounceIn),
    new CurveDescription('bounce_in_out', 'Curves.bounceInOut', Curves.bounceInOut),
    new CurveDescription('bounce_out', 'Curves.bounceOut', Curves.bounceOut),
    new CurveDescription('decelerate', 'Curves.decelerate', Curves.decelerate),
    new CurveDescription('ease', 'Curves.ease', Curves.ease),
    new CurveDescription('ease_in', 'Curves.easeIn', Curves.easeIn),
    new CurveDescription('ease_in_out', 'Curves.easeInOut', Curves.easeInOut),
    new CurveDescription('ease_out', 'Curves.easeOut', Curves.easeOut),
    new CurveDescription('elastic_in', 'Curves.elasticIn', Curves.elasticIn),
    new CurveDescription('elastic_in_out', 'Curves.elasticInOut', Curves.elasticInOut),
    new CurveDescription('elastic_out', 'Curves.elasticOut', Curves.elasticOut),
    new CurveDescription('fast_out_slow_in', 'Curves.fastOutSlowIn', Curves.fastOutSlowIn),
    new CurveDescription('linear', 'Curves.linear', Curves.linear),
    new CurveDescription('interval', 'const Interval(0.25, 0.25)', const Interval(0.25, 0.75)),
    new CurveDescription('sawtooth', 'const SawTooth(3)', const SawTooth(3)),
    new CurveDescription('threshold', 'const Threshold(0.75)', const Threshold(0.75)),
    new CurveDescription('flipped', 'Curves.bounceIn.flipped', Curves.bounceIn.flipped),
    new CurveDescription('flipped_curve', 'const FlippedCurve(Curves.bounceIn)', const FlippedCurve(Curves.bounceIn)),
  ];
  runApp(
    new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Material(
        child: new Builder(
          builder: (BuildContext context) {
            return new Padding(
              padding: MediaQuery.of(context).padding,
              child: new Wrap(
                alignment: WrapAlignment.spaceEvenly,
                runAlignment: WrapAlignment.spaceEvenly,
                children: curves.map((CurveDescription curve) => curve.widget).toList(),
              ),
            );
          },
        ),
      ),
    ),
  );
  new Timer(const Duration(seconds: 1), () {
    print('The following commands extract out the ${curves.length} images from a screenshot file.');
    print('You can obtain a screenshot by pressing "s" in the "flutter run" console.');
    print('export FILE=flutter_01.png # or whatever the file name is');
    for (CurveDescription curve in curves) {
      final RenderBox box = curve.key.currentContext.findRenderObject();
      final Rect area = (box.localToGlobal(Offset.zero) * ui.window.devicePixelRatio) & (box.size * ui.window.devicePixelRatio);
      print('convert \$FILE -crop ${area.width}x${area.height}+${area.left}+${area.top} -resize \'300x300>\' curve_${curve.filename}.png');
    }
  });
}

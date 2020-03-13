// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const double _kFontSize = 14.0;
const Duration _kCurveAnimationDuration = Duration(seconds: 2);
const double _kCurveAnimationFrameRate = 60.0;

/// A custom painter to draw the graph of the curve.
class CurveDescription extends CustomPainter {
  CurveDescription(this.caption, this.curve, this.position)
      : _caption = _createLabelPainter(
          caption,
          color: Colors.black,
        );

  final String caption;
  final Curve curve;
  final double position;

  static final TextPainter _t = _createLabelPainter('t', style: FontStyle.italic);
  static final TextPainter _x = _createLabelPainter('x', style: FontStyle.italic);
  static final TextPainter _zero = _createLabelPainter('0.0');
  static final TextPainter _one = _createLabelPainter('1.0');
  final TextPainter _caption;

  static TextPainter _createLabelPainter(
    String label, {
    FontStyle style: FontStyle.normal,
    Color color: Colors.black45,
  }) {
    final TextPainter result = new TextPainter(
      textDirection: TextDirection.ltr,
      text: new TextSpan(
        text: label,
        style: new TextStyle(
          color: color,
          fontStyle: style,
          fontSize: _kFontSize,
        ),
      ),
    );
    result.layout();
    return result;
  }

  static final Paint _axisPaint = new Paint()
    ..color = Colors.black45
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static final Paint _positionPaint = new Paint()
    ..color = Colors.black45
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.0;

  static final Paint _dashPaint = new Paint()
    ..color = Colors.black45
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.0;

  static final Paint _graphPaint = new Paint()
    ..color = Colors.blue.shade900
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0;

  static final Paint _graphProgressPaint = new Paint()
    ..color = Colors.black26
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0;

  static final Paint _valueMarkerPaint = new Paint()
    ..color = const Color(0xffA02020)
    ..style = PaintingStyle.fill;

  static final Paint _positionCirclePaint = new Paint()
    ..color = Colors.blue.shade900
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    assert(size != Size.zero);
    final double unit = _zero.width / 4.0;
    final double leftMargin = unit * 6.0;
    final double rightMargin = 3.0 * unit + _t.width;
    final double bottomMargin = unit / 2.0;
    final double verticalHeadroom = size.height * 0.2;
    final double markerWidth = unit * 3.0;

    final Rect area = new Rect.fromLTRB(
      leftMargin,
      verticalHeadroom,
      size.width - rightMargin,
      size.height - verticalHeadroom,
    );
    final Path axes = new Path()
      ..moveTo(area.left - unit, area.top) // vertical axis 1.0 tick
      ..lineTo(area.left, area.top) // vertical axis
      ..lineTo(area.left, area.bottom) // origin
      ..lineTo(area.right, area.bottom) // horizontal axis
      ..lineTo(area.right, area.bottom + unit); // horizontal axis 1.0 tick
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

    _one.paint(
      canvas,
      new Offset(area.left - leftMargin + (_zero.width - _one.width), area.top - _one.height / 2.0),
    );
    _one.paint(canvas, new Offset(area.right - _one.width / 2.0, area.bottom + bottomMargin + unit));
    _x.paint(canvas, new Offset(area.left + _x.width, area.top));
    _t.paint(canvas, new Offset(area.right - _t.width, area.bottom - _t.height - unit / 2.0));
    _caption.paint(
      canvas,
      new Offset(
        leftMargin + (area.width - _caption.width) / 2.0,
        size.height - (verticalHeadroom + _caption.height) / 2.0,
      ),
    );
    final Offset activePoint = new FractionalOffset(
      position,
      1.0 - curve.transform(position),
    ).withinRect(area);
    // Skip drawing the tracing line if we're at 0.0 because we want the
    // initial paused state to not include the position indicators. They just
    // add clutter before the animation is started.
    if (position != 0.0) {
      final Path positionLine = new Path()
        ..moveTo(activePoint.dx, area.bottom)
        ..lineTo(activePoint.dx, area.top); // vertical pointer from base
      canvas.drawPath(positionLine, _positionPaint);
      final Path valueMarker = new Path()
        ..moveTo(area.right + unit, activePoint.dy)
        ..lineTo(area.right + unit * 2.0, activePoint.dy - unit)
        ..lineTo(area.right + unit * 2.0 + markerWidth, activePoint.dy - unit)
        ..lineTo(area.right + unit * 2.0 + markerWidth, activePoint.dy + unit)
        ..lineTo(area.right + unit * 2.0, activePoint.dy + unit)
        ..lineTo(area.right + unit, activePoint.dy);
      canvas.drawPath(valueMarker, _valueMarkerPaint);
    }
    final Path graph = new Path()..moveTo(area.left, area.bottom);
    final double stepSize = 1.0 / (area.width * ui.window.devicePixelRatio);
    for (double t = 0.0; t <= (position == 0.0 ? 1.0 : position); t += stepSize) {
      final Offset point = new FractionalOffset(t, 1.0 - curve.transform(t)).withinRect(area);
      graph.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(graph, _graphPaint);
    if (position != 0.0) {
      final Offset startPoint = new FractionalOffset(
        position,
        1.0 - curve.transform(position),
      ).withinRect(area);
      final Path graphProgress = new Path()..moveTo(startPoint.dx, startPoint.dy);
      for (double t = position; t <= 1.0; t += stepSize) {
        final Offset point = new FractionalOffset(t, 1.0 - curve.transform(t)).withinRect(area);
        graphProgress.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(graphProgress, _graphProgressPaint);
      canvas.drawCircle(new Offset(activePoint.dx, activePoint.dy), 4.0, _positionCirclePaint);
    }
  }

  @override
  bool shouldRepaint(CurveDescription oldDelegate) {
    return caption != oldDelegate.caption || curve != oldDelegate.curve;
  }
}

/// A sample tile that shows the effect of a curve on translation.
class TranslateSampleTile extends StatelessWidget {
  const TranslateSampleTile({
    Key key,
    this.animation,
    this.name,
  }) : super(key: key);

  static const double blockHeight = 20.0;
  static const double blockWidth = 30.0;
  static const double containerSize = 48.0;

  final Animation<double> animation;
  final String name;

  Widget mutate({Widget child}) {
    return new Transform.translate(
      offset: new Offset(0.0, 13.0 - animation.value * 26.0),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    const BorderRadius outerRadius = BorderRadius.all(
      Radius.circular(8.0),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: ClipRRect(
            borderRadius: outerRadius,
            child: new Container(
              width: containerSize,
              height: containerSize,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(4.0),
              decoration: new BoxDecoration(
                borderRadius: outerRadius,
                border: new Border.all(
                  color: Colors.black45,
                  width: 1.0,
                ),
              ),
              child: mutate(
                child: new Container(
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.all(
                      Radius.circular(4.0),
                    ),
                  ),
                  width: blockWidth,
                  height: blockHeight,
                ),
              ),
            ),
          ),
        ),
        new Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyText1.copyWith(
                color: Colors.black,
                fontSize: 12.0,
              ),
        ),
      ],
    );
  }
}

/// A sample tile that shows the effect of a curve on rotation.
class RotateSampleTile extends TranslateSampleTile {
  const RotateSampleTile({Key key, Animation<double> animation, String name})
      : super(
          key: key,
          animation: animation,
          name: name,
        );

  @override
  Widget mutate({Widget child}) {
    return new Transform.rotate(
      angle: animation.value * math.pi / 2.0,
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// A sample tile that shows the effect of a curve on scale.
class ScaleSampleTile extends TranslateSampleTile {
  const ScaleSampleTile({Key key, Animation<double> animation, String name})
      : super(
          key: key,
          animation: animation,
          name: name,
        );

  @override
  Widget mutate({Widget child}) {
    return new Transform.scale(
      scale: math.max(animation.value, 0.0),
      child: child,
    );
  }
}

/// A sample tile that shows the effect of a curve on opacity.
class OpacitySampleTile extends TranslateSampleTile {
  const OpacitySampleTile({Key key, Animation<double> animation, String name})
      : super(
          key: key,
          animation: animation,
          name: name,
        );

  @override
  Widget mutate({Widget child}) {
    return new Opacity(opacity: animation.value.clamp(0.0, 1.0), child: child);
  }
}

class CurveDiagram extends StatefulWidget implements DiagramMetadata {
  const CurveDiagram({
    String name,
    this.caption,
    this.duration = _kCurveAnimationDuration,
    this.curve,
  }) : name = 'curve_$name';

  @override
  final String name;
  final String caption;
  final Curve curve;
  final Duration duration;

  @override
  CurveDiagramState createState() {
    return new CurveDiagramState();
  }
}

class CurveDiagramState extends State<CurveDiagram> with TickerProviderStateMixin<CurveDiagram> {
  AnimationController controller;
  CurvedAnimation animation;

  @override
  void didUpdateWidget(CurveDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.value = 0.0;
    animation = new CurvedAnimation(curve: widget.curve, parent: controller);
    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
      duration: widget.duration,
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    )..addListener(() {
        setState(() {});
      });
    animation = new CurvedAnimation(curve: widget.curve, parent: controller);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CurveDescription description = new CurveDescription(
      widget.caption,
      widget.curve,
      controller.value,
    );
    return new Container(
      padding: const EdgeInsets.all(7.0),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: new BoxConstraints.tight(const Size(450.0, 178.0)),
        child: Row(
          children: <Widget>[
            ConstrainedBox(
              constraints: new BoxConstraints.tight(const Size(300.0, 178.0)),
              key: new UniqueKey(),
              child: new CustomPaint(
                painter: description,
              ),
            ),
            Container(
              constraints: new BoxConstraints.tight(const Size(150.0, 178.0)),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new TranslateSampleTile(animation: animation, name: 'translation'),
                      new RotateSampleTile(animation: animation, name: 'rotation'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new ScaleSampleTile(animation: animation, name: 'scale'),
                      new OpacitySampleTile(animation: animation, name: 'opacity'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurveDiagramStep extends DiagramStep<CurveDiagram> {
  CurveDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.addAll(<CurveDiagram>[
      const CurveDiagram(name: 'bounce_in', caption: 'Curves.bounceIn', curve: Curves.bounceIn),
      const CurveDiagram(name: 'bounce_in_out', caption: 'Curves.bounceInOut', curve: Curves.bounceInOut),
      const CurveDiagram(name: 'bounce_out', caption: 'Curves.bounceOut', curve: Curves.bounceOut),
      const CurveDiagram(name: 'decelerate', caption: 'Curves.decelerate', curve: Curves.decelerate),
      const CurveDiagram(name: 'ease', caption: 'Curves.ease', curve: Curves.ease),
      const CurveDiagram(name: 'ease_in', caption: 'Curves.easeIn', curve: Curves.easeIn),
      const CurveDiagram(name: 'ease_in_sine', caption: 'Curves.easeInSine', curve: Curves.easeInSine),
      const CurveDiagram(name: 'ease_in_quad', caption: 'Curves.easeInQuad', curve: Curves.easeInSine),
      const CurveDiagram(name: 'ease_in_cubic', caption: 'Curves.easeInCubic', curve: Curves.easeInCubic),
      const CurveDiagram(name: 'ease_in_quart', caption: 'Curves.easeInQuart', curve: Curves.easeInQuart),
      const CurveDiagram(name: 'ease_in_quint', caption: 'Curves.easeInQuint', curve: Curves.easeInQuint),
      const CurveDiagram(name: 'ease_in_expo', caption: 'Curves.easeInExpo', curve: Curves.easeInExpo),
      const CurveDiagram(name: 'ease_in_circ', caption: 'Curves.easeInCirc', curve: Curves.easeInCirc),
      const CurveDiagram(name: 'ease_in_back', caption: 'Curves.easeInBack', curve: Curves.easeInBack),
      const CurveDiagram(name: 'ease_in_out', caption: 'Curves.easeInOut', curve: Curves.easeInOut),
      const CurveDiagram(name: 'ease_in_out_sine', caption: 'Curves.easeInOutSine', curve: Curves.easeInOutSine),
      const CurveDiagram(name: 'ease_in_out_quad', caption: 'Curves.easeInOutQuad', curve: Curves.easeInOutSine),
      const CurveDiagram(name: 'ease_in_out_cubic', caption: 'Curves.easeInOutCubic', curve: Curves.easeInOutCubic),
      const CurveDiagram(name: 'ease_in_out_quart', caption: 'Curves.easeInOutQuart', curve: Curves.easeInOutQuart),
      const CurveDiagram(name: 'ease_in_out_quint', caption: 'Curves.easeInOutQuint', curve: Curves.easeInOutQuint),
      const CurveDiagram(name: 'ease_in_out_expo', caption: 'Curves.easeInOutExpo', curve: Curves.easeInOutExpo),
      const CurveDiagram(name: 'ease_in_out_circ', caption: 'Curves.easeInOutCirc', curve: Curves.easeInOutCirc),
      const CurveDiagram(name: 'ease_in_out_back', caption: 'Curves.easeInOutBack', curve: Curves.easeInOutBack),
      const CurveDiagram(name: 'ease_out', caption: 'Curves.easeOut', curve: Curves.easeOut),
      const CurveDiagram(name: 'ease_out_sine', caption: 'Curves.easeOutSine', curve: Curves.easeOutSine),
      const CurveDiagram(name: 'ease_out_quad', caption: 'Curves.easeOutQuad', curve: Curves.easeOutSine),
      const CurveDiagram(name: 'ease_out_cubic', caption: 'Curves.easeOutCubic', curve: Curves.easeOutCubic),
      const CurveDiagram(name: 'ease_out_quart', caption: 'Curves.easeOutQuart', curve: Curves.easeOutQuart),
      const CurveDiagram(name: 'ease_out_quint', caption: 'Curves.easeOutQuint', curve: Curves.easeOutQuint),
      const CurveDiagram(name: 'ease_out_expo', caption: 'Curves.easeOutExpo', curve: Curves.easeOutExpo),
      const CurveDiagram(name: 'ease_out_circ', caption: 'Curves.easeOutCirc', curve: Curves.easeOutCirc),
      const CurveDiagram(name: 'ease_out_back', caption: 'Curves.easeOutBack', curve: Curves.easeOutBack),
      const CurveDiagram(name: 'elastic_in', caption: 'Curves.elasticIn', curve: Curves.elasticIn),
      const CurveDiagram(name: 'elastic_in_out', caption: 'Curves.elasticInOut', curve: Curves.elasticInOut),
      const CurveDiagram(name: 'elastic_out', caption: 'Curves.elasticOut', curve: Curves.elasticOut),
      const CurveDiagram(name: 'fast_out_slow_in', caption: 'Curves.fastOutSlowIn', curve: Curves.fastOutSlowIn),
      const CurveDiagram(name: 'slow_middle', caption: 'Curves.slowMiddle', curve: Curves.slowMiddle),
      new CurveDiagram(name: 'flipped', caption: 'Curves.bounceIn.flipped', curve: Curves.bounceIn.flipped),
      const CurveDiagram(name: 'flipped_curve', caption: 'FlippedCurve(Curves.bounceIn)', curve: FlippedCurve(Curves.bounceIn)),
      const CurveDiagram(name: 'interval', caption: 'Interval(0.25, 0.75)', curve: Interval(0.25, 0.75)),
      const CurveDiagram(name: 'linear', caption: 'Curves.linear', curve: Curves.linear),
      const CurveDiagram(name: 'sawtooth', caption: 'SawTooth(3)', curve: SawTooth(3)),
      const CurveDiagram(name: 'threshold', caption: 'Threshold(0.75)', curve: Threshold(0.75)),
      const CurveDiagram(name: 'linear_to_ease_out', caption: 'Curves.linearToEaseOut', curve: Curves.linearToEaseOut),
      const CurveDiagram(name: 'ease_in_to_linear', caption: 'Curves.easeInToLinear', curve: Curves.easeInToLinear),
      const CurveDiagram(name: 'fast_linear_to_slow_ease_in', caption: 'Curves.fastLinearToSlowEaseIn', curve: Curves.fastLinearToSlowEaseIn),
    ]);
  }

  @override
  final String category = 'animation';

  final List<CurveDiagram> _diagrams = <CurveDiagram>[];

  @override
  Future<List<CurveDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(CurveDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kCurveAnimationDuration,
      frameRate: _kCurveAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
  }
}

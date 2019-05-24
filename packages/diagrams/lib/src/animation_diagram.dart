// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const Duration _kAnimationDuration = Duration(seconds: 2);
const double _kFontSize = 14.0;
const double _kLogoSize = 150.0;

/// Use the class name as the basis for the caption to display, since
/// that is directly related to the name of the transition.
String _getCaption(Type type) {
  return type.toString().replaceAll('Diagram', '');
}

/// Convert the caption CamelCase name into lower_with_underscores.
String getName(Type type) {
  final RegExp uppercase = new RegExp(r'([A-Z])');
  return _getCaption(type).replaceAllMapped(
    uppercase,
    (Match match) {
      if (match.start != 0) {
        return '_${match.group(1).toLowerCase()}';
      } else {
        return match.group(1).toLowerCase();
      }
    },
  );
}

/// A base class for diagrams that show explicit animation transitions, like
/// [FadeTransition]. See transitions.dart for more examples.
abstract class TransitionDiagram<T> extends StatefulWidget implements DiagramMetadata {
  const TransitionDiagram({
    Key key,
    this.decorate = true,
  }) : super(key: key);

  /// Whether or not to decorate this diagram with an animation curve and top label.
  final bool decorate;

  /// The animation curve for both the animation and the sparkline to use.
  Curve get curve;
  Animation<T> buildAnimation(AnimationController controller);
  Widget buildTransition(BuildContext context, Animation<T> animation);

  @override
  String get name => getName(runtimeType) + (decorate ? '' : '_plain');

  /// The label to be shown on the top of the diagram if [decorate] is true.
  String get caption => _getCaption(runtimeType);

  @override
  TransitionDiagramState<T> createState() => new TransitionDiagramState<T>();
}

class TransitionDiagramState<T> extends State<TransitionDiagram<T>>
    with TickerProviderStateMixin<TransitionDiagram<T>> {
  bool selected = false;
  Animation<T> animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
      duration: _kAnimationDuration,
      vsync: this,
    )..addListener(() {
        setState(() {
          // The animation controller is changing the animation value, so we
          // need to redraw.
        });
      });
    animation = widget.buildAnimation(_controller);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.decorate) {
      child = new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Text(
            widget.caption,
            style: const TextStyle(
              color: Color(0xff000000),
              fontStyle: FontStyle.normal,
              fontSize: _kFontSize,
            ),
          ),
          new Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              border: new Border.all(color: Colors.black26, width: 1.0),
            ),
            constraints: const BoxConstraints.tightFor(
              width: 250.0,
              height: 250.0,
            ),
            child: widget.buildTransition(context, animation),
          ),
          new Container(height: 25.0),
          new Container(
            width: 100.0,
            height: 50.0,
            child: Sparkline(curve: widget.curve, position: _controller.value),
          ),
        ],
      );
    } else {
      child = widget.buildTransition(context, animation);
    }

    return new GestureDetector(
      onTap: () {
        setState(() {
          selected = !selected;
          selected ? _controller.forward() : _controller.reverse();
        });
      },
      child: new Container(
        // Height must be an even number for ffmpeg to be able to create a video
        // from the output.
        constraints: new BoxConstraints.tightFor(
          width: widget.decorate ? 300.0 : 250.0,
          height: widget.decorate ? 378.0 : 250.0,
        ),
        padding: new EdgeInsets.only(
          top: 25.0 - (widget.decorate ? _kFontSize - 1.0 : 0.0),
          left: 25.0,
          right: 25.0,
          bottom: 25.0,
        ),
        color: const Color(0xffffffff),
        child: child,
      ),
    );
  }
}

abstract class ImplicitAnimationDiagram<T> extends StatefulWidget implements DiagramMetadata {
  const ImplicitAnimationDiagram({Key key}) : super(key: key);

  /// The animation curve for the animation to use.
  Curve get curve;
  Widget buildImplicitAnimation(BuildContext context, bool selected);

  @override
  String get name => getName(runtimeType);

  String get caption => _getCaption(runtimeType);

  Size get size => const Size(250.0, 250.0);

  @override
  ImplicitAnimationDiagramState<T> createState() => new ImplicitAnimationDiagramState<T>();
}

class ImplicitAnimationDiagramState<T> extends State<ImplicitAnimationDiagram<T>> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    final Widget child = widget.buildImplicitAnimation(context, selected);
    return new GestureDetector(
      onTap: () {
        setState(() {
          selected = !selected;
        });
      },
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Text(
              widget.caption,
              style: const TextStyle(
                color: Color(0xff000000),
                fontStyle: FontStyle.normal,
                fontSize: _kFontSize,
              ),
            ),
            new Container(
              // Height must be an even number for ffmpeg to be able to create a video
              // from the output.
              constraints: BoxConstraints.tightFor(
                width: widget.size.width,
                height: widget.size.height,
              ),
              padding: const EdgeInsets.only(
                top: 25.0 - _kFontSize - 1.0,
                left: 25.0,
                right: 25.0,
                bottom: 25.0,
              ),
              color: const Color(0xffffffff),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom painter to draw the graph of the curve.
class SparklinePainter extends CustomPainter {
  SparklinePainter(this.curve, this.position);

  final Curve curve;
  final double position;

  static final Paint _axisPaint = new Paint()
    ..color = Colors.black45
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;

  static final Paint _sparklinePaint = new Paint()
    ..color = Colors.blue.shade900
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0;

  static final Paint _graphProgressPaint = new Paint()
    ..color = Colors.black26
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 4.0;

  static final Paint _positionCirclePaint = new Paint()
    ..color = Colors.blue.shade900
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    assert(size != Size.zero);
    const double unit = 4.0;
    const double leftMargin = unit;
    const double rightMargin = unit;
    const double topMargin = unit;

    final Rect area = new Rect.fromLTRB(
      leftMargin,
      topMargin,
      size.width - rightMargin,
      size.height - topMargin,
    );
    final Path axes = new Path()
      ..moveTo(area.left, area.top) // vertical axis
      ..lineTo(area.left, area.bottom) // origin
      ..lineTo(area.right, area.bottom); // horizontal axis
    canvas.drawPath(axes, _axisPaint);
    final Offset activePoint = new FractionalOffset(
      position,
      1.0 - curve.transform(position),
    ).withinRect(area);

    // The sparkline itself.
    final Path sparkline = new Path()..moveTo(area.left, area.bottom);
    final double stepSize = 1.0 / (area.width * ui.window.devicePixelRatio);
    for (double t = 0.0; t <= position; t += stepSize) {
      final Offset point = new FractionalOffset(t, 1.0 - curve.transform(t)).withinRect(area);
      sparkline.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(sparkline, _sparklinePaint);
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

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) {
    return curve != oldDelegate.curve || position != oldDelegate.position;
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline({Key key, this.curve, this.position});

  final Curve curve;
  final double position;

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(painter: SparklinePainter(curve, position));
  }
}

class SampleWidget extends StatelessWidget {
  const SampleWidget({Key key, this.small = false}) : super(key: key);

  final bool small;

  @override
  Widget build(BuildContext context) {
    if (small) {
      return const FlutterLogo(size: _kLogoSize / 2.0);
    }
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: FlutterLogo(size: _kLogoSize),
    );
  }
}

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

final GlobalKey _transitionKey = new GlobalKey();

const Duration _kAnimationDuration = const Duration(seconds: 2);
const Duration _kOverallAnimationDuration = const Duration(seconds: 6);
const double _kAnimationFrameRate = 60.0;
const double _kLogoSize = 150.0;

class TransitionDiagramStep extends DiagramStep {
  TransitionDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(const DecoratedBoxTransitionDiagram());
    _diagrams.add(const FadeTransitionDiagram());
    _diagrams.add(const PositionedTransitionDiagram());
    _diagrams.add(const RelativePositionedTransitionDiagram());
    _diagrams.add(const RotationTransitionDiagram());
    _diagrams.add(const ScaleTransitionDiagram());
    _diagrams.add(const SizeTransitionDiagram());
    _diagrams.add(const SlideTransitionDiagram());
  }

  final List<TransitionDiagram<dynamic>> _diagrams = <TransitionDiagram<dynamic>>[];

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final TransitionDiagram<dynamic> typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;

    final Map<Duration, DiagramKeyframe> keyframes = <Duration, DiagramKeyframe>{
      Duration.zero: (Duration now) async {
        final RenderBox target = _transitionKey.currentContext.findRenderObject();
        final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
        final TestGesture gesture = await controller.startGesture(targetOffset);
        await gesture.up();
      },
      const Duration(seconds: 3): (Duration now) async {
        final RenderBox target = _transitionKey.currentContext.findRenderObject();
        final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
        final TestGesture gesture = await controller.startGesture(targetOffset);
        await gesture.up();
      },
    };

    final File result = await controller.drawAnimatedDiagramToFiles(
      end: _kOverallAnimationDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
      keyframes: keyframes,
    );
    return result;
  }
}

Widget content({bool small = false}) {
  if (small) {
    return const FlutterLogo(size: _kLogoSize / 2.0);
  }
  return const Padding(
    padding: const EdgeInsets.all(8.0),
    child: const FlutterLogo(size: _kLogoSize),
  );
}

abstract class TransitionDiagram<T> extends StatefulWidget implements DiagramMetadata {
  const TransitionDiagram({
    Key key,
  }) : super(key: key);

  /// The animation curve for both the animation and the sparkline to use.
  Curve get curve;
  Animation<T> buildAnimation(AnimationController controller);
  Widget buildTransition(BuildContext context, Animation<T> animation);

  @override
  TransitionDiagramState<T> createState() => new TransitionDiagramState<T>();
}

class TransitionDiagramState<T> extends State<TransitionDiagram<T>> //
    with
        TickerProviderStateMixin<TransitionDiagram<T>> {
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
      setState(() {});
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
        constraints: const BoxConstraints.tightFor(width: 300.0, height: 376.0),
        padding: const EdgeInsets.all(25.0),
        color: const Color(0xffffffff),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints.tightFor(width: 250.0, height: 250.0),
              child: widget.buildTransition(context, animation),
            ),
            new Container(height: 25.0),
            new Container(
              width: 100.0,
              height: 50.0,
              child: Sparkline(curve: widget.curve, position: _controller.value),
            ),
          ],
        ),
      ),
    );
  }
}

class DecoratedBoxTransitionDiagram extends TransitionDiagram<Decoration> {
  const DecoratedBoxTransitionDiagram({Key key}) : super(key: key);

  @override
  String get name => 'decorated_box_transition';

  @override
  Curve get curve => Curves.decelerate;

  @override
  Animation<Decoration> buildAnimation(AnimationController controller) {
    return _decorationTween.animate(new CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static const BorderRadius _beginRadius = const BorderRadius.all(const Radius.circular(50.0));
  static const BorderRadius _endRadius = const BorderRadius.all(const Radius.circular(0.0));
  static final DecorationTween _decorationTween = new DecorationTween(
    begin: new BoxDecoration(
      borderRadius: _beginRadius,
      color: const Color(0xffffffff),
      boxShadow: kElevationToShadow[8],
    ),
    end: const BoxDecoration(
      borderRadius: _endRadius,
      color: const Color(0xffffffff),
    ),
  );

  @override
  Widget buildTransition(BuildContext context, Animation<Decoration> animation) {
    return new DecoratedBoxTransition(
      key: _transitionKey,
      decoration: animation,
      child: new Container(
        width: 158.0,
        height: 158.0,
        child: content(),
      ),
    );
  }
}

class FadeTransitionDiagram extends TransitionDiagram<double> {
  const FadeTransitionDiagram({Key key}) : super(key: key);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return new ReverseAnimation(
      new CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  @override
  String get name => 'fade_transition';

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return new FadeTransition(
      key: _transitionKey,
      opacity: animation,
      child: content(),
    );
  }
}

class PositionedTransitionDiagram extends TransitionDiagram<RelativeRect> {
  const PositionedTransitionDiagram({Key key}) : super(key: key);

  @override
  String get name => 'positioned_transition';

  @override
  Curve get curve => Curves.elasticInOut;

  @override
  Animation<RelativeRect> buildAnimation(AnimationController controller) {
    return _rectTween.animate(new CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static final RelativeRectTween _rectTween = new RelativeRectTween(
    begin: const RelativeRect.fromLTRB(10.0, 10.0, 150.0, 150.0),
    end: const RelativeRect.fromLTRB(100.0, 100.0, 10.0, 10.0),
  );

  @override
  Widget buildTransition(BuildContext context, Animation<RelativeRect> animation) {
    return new Center(
      child: new Stack(
        children: <Widget>[
          new Container(color: const Color(0xffffffff), width: 250.0, height: 250.0),
          new PositionedTransition(
            key: _transitionKey,
            rect: animation,
            child: content(small: true),
          ),
        ],
      ),
    );
  }
}

class RelativePositionedTransitionDiagram extends TransitionDiagram<Rect> {
  const RelativePositionedTransitionDiagram({Key key}) : super(key: key);

  @override
  String get name => 'relative_positioned_transition';

  @override
  Curve get curve => Curves.elasticInOut;

  @override
  Animation<Rect> buildAnimation(AnimationController controller) {
    return _rectTween.animate(new CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static final RectTween _rectTween = new RectTween(
    begin: new Rect.fromLTRB(0.0, 0.0, 50.0, 50.0),
    end: new Rect.fromLTRB(140.0, 140.0, 150.0, 150.0),
  );

  @override
  Widget buildTransition(BuildContext context, Animation<Rect> animation) {
    return new Center(
      child: new Stack(
        children: <Widget>[
          new Container(color: const Color(0xffffffff), width: 200.0, height: 200.0),
          new RelativePositionedTransition(
            key: _transitionKey,
            size: const Size(150.0, 150.0),
            rect: animation,
            child: content(small: true),
          ),
        ],
      ),
    );
  }
}

class RotationTransitionDiagram extends TransitionDiagram<double> {
  const RotationTransitionDiagram({Key key}) : super(key: key);

  @override
  String get name => 'rotation_transition';

  @override
  Curve get curve => Curves.elasticOut;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return new CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return new RotationTransition(
      key: _transitionKey,
      turns: animation,
      child: content(),
    );
  }
}

class ScaleTransitionDiagram extends TransitionDiagram<double> {
  const ScaleTransitionDiagram({Key key}) : super(key: key);

  @override
  String get name => 'scale_transition';

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return new ReverseAnimation(
      new CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return new ScaleTransition(
      key: _transitionKey,
      scale: animation,
      child: content(),
    );
  }
}

class SizeTransitionDiagram extends TransitionDiagram<double> {
  const SizeTransitionDiagram({Key key}) : super(key: key);

  @override
  String get name => 'size_transition';

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return new ReverseAnimation(
      new CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return new Container(
      constraints: const BoxConstraints.tightFor(width: _kLogoSize),
      child: new SizeTransition(
        key: _transitionKey,
        axis: Axis.vertical,
        axisAlignment: 0.0,
        sizeFactor: animation,
        child: content(),
      ),
    );
  }
}

class SlideTransitionDiagram extends TransitionDiagram<Offset> {
  const SlideTransitionDiagram({Key key}) : super(key: key);

  @override
  String get name => 'slide_transition';

  @override
  Curve get curve => Curves.elasticIn;

  @override
  Animation<Offset> buildAnimation(AnimationController controller) {
    return _offsetTween.animate(
      new CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  static final Tween<Offset> _offsetTween = new Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  );

  @override
  Widget buildTransition(BuildContext context, Animation<Offset> animation) {
    return new Center(
      child: new SlideTransition(
        key: _transitionKey,
        position: animation,
        child: content(),
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


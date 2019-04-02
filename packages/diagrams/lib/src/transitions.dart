// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'animation_diagram.dart';
import 'diagram_step.dart';

final GlobalKey _transitionKey = new GlobalKey();

const Duration _kOverallAnimationDuration = Duration(seconds: 6);
const double _kAnimationFrameRate = 60.0;
const double _kLogoSize = 150.0;

class TransitionDiagramStep extends DiagramStep {
  TransitionDiagramStep(DiagramController controller) : super(controller) {
    _diagrams.add(const AlignTransitionDiagram());
    _diagrams.add(const DecoratedBoxTransitionDiagram());
    _diagrams.add(const FadeTransitionDiagram());
    _diagrams.add(const PositionedTransitionDiagram());
    _diagrams.add(const RelativePositionedTransitionDiagram());
    _diagrams.add(const RotationTransitionDiagram());
    _diagrams.add(const ScaleTransitionDiagram());
    _diagrams.add(const SizeTransitionDiagram());
    _diagrams.add(const SlideTransitionDiagram());
    _diagrams.add(const AlignTransitionDiagram(decorate: false));
    _diagrams.add(const DecoratedBoxTransitionDiagram(decorate: false));
    _diagrams.add(const FadeTransitionDiagram(decorate: false));
    _diagrams.add(const PositionedTransitionDiagram(decorate: false));
    _diagrams.add(const RelativePositionedTransitionDiagram(decorate: false));
    _diagrams.add(const RotationTransitionDiagram(decorate: false));
    _diagrams.add(const ScaleTransitionDiagram(decorate: false));
    _diagrams.add(const SizeTransitionDiagram(decorate: false));
    _diagrams.add(const SlideTransitionDiagram(decorate: false));
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

class AlignTransitionDiagram extends TransitionDiagram<AlignmentGeometry> {
  const AlignTransitionDiagram({Key key, bool decorate = true}) : super(key: key, decorate: decorate);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<AlignmentGeometry> buildAnimation(AnimationController controller) {
    return _offsetTween.animate(
      new CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  static final Tween<AlignmentGeometry> _offsetTween = new AlignmentGeometryTween(
    begin: AlignmentDirectional.bottomStart,
    end: AlignmentDirectional.center,
  );

  @override
  Widget buildTransition(BuildContext context, Animation<AlignmentGeometry> animation) {
    return new Center(
      child: new AlignTransition(
        key: _transitionKey,
        alignment: animation,
        child: const SampleWidget(small: true),
      ),
    );
  }
}

class DecoratedBoxTransitionDiagram extends TransitionDiagram<Decoration> {
  const DecoratedBoxTransitionDiagram({Key key, bool decorate = true}) : super(key: key, decorate: decorate);

  @override
  Curve get curve => Curves.decelerate;

  @override
  Animation<Decoration> buildAnimation(AnimationController controller) {
    return _decorationTween.animate(new CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static const BorderRadius _beginRadius = BorderRadius.all(Radius.circular(50.0));
  static const BorderRadius _endRadius = BorderRadius.all(Radius.circular(0.0));
  static final DecorationTween _decorationTween = new DecorationTween(
    begin: new BoxDecoration(
      borderRadius: _beginRadius,
      color: const Color(0xffffffff),
      boxShadow: kElevationToShadow[8],
    ),
    end: const BoxDecoration(
      borderRadius: _endRadius,
      color: Color(0xffffffff),
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
        child: const SampleWidget(),
      ),
    );
  }
}

class FadeTransitionDiagram extends TransitionDiagram<double> {
  const FadeTransitionDiagram({Key key, bool decorate = true}) : super(key: key, decorate: decorate);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return new CurvedAnimation(
      parent: controller,
      curve: curve,
  );
  }

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return new FadeTransition(
      key: _transitionKey,
      opacity: animation,
      child: const SampleWidget(),
    );
  }
}

class PositionedTransitionDiagram extends TransitionDiagram<RelativeRect> {
  const PositionedTransitionDiagram({Key key, bool decorate = true}) : super(key: key, decorate: decorate);

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
          new Container(width: 250.0, height: 250.0),
          new PositionedTransition(
            key: _transitionKey,
            rect: animation,
            child: const SampleWidget(small: true),
          ),
        ],
      ),
    );
  }
}

class RelativePositionedTransitionDiagram extends TransitionDiagram<Rect> {
  const RelativePositionedTransitionDiagram({Key key, bool decorate = true}) : super(key: key, decorate: decorate);

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
            child: const SampleWidget(small: true),
          ),
        ],
      ),
    );
  }
}

class RotationTransitionDiagram extends TransitionDiagram<double> {
  const RotationTransitionDiagram({Key key, bool decorate = true}) : super(key: key, decorate: decorate);

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
      child: const SampleWidget(),
    );
  }
}

class ScaleTransitionDiagram extends TransitionDiagram<double> {
  const ScaleTransitionDiagram({Key key, bool decorate = true}) : super(key: key, decorate: decorate);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return new CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return new ScaleTransition(
      key: _transitionKey,
      scale: animation,
      child: const SampleWidget(),
    );
  }
}

class SizeTransitionDiagram extends TransitionDiagram<double> {
  const SizeTransitionDiagram({Key key, bool decorate = true}) : super(key: key, decorate: decorate);

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return new CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
        new Container(
          // TODO(gspencer): remove these constraints when
          // https://github.com/flutter/flutter/issues/19850 is fixed.
          // SizeTransition hard codes alignment at the beginning, so we have
          // to restrict the width to make it look centered.
          constraints: const BoxConstraints.tightFor(width: _kLogoSize),
          child: new SizeTransition(
            key: _transitionKey,
            axis: Axis.vertical,
            axisAlignment: 0.0,
            sizeFactor: animation,
            child: const SampleWidget(),
          ),
        ),
      ],
    );
  }
}

class SlideTransitionDiagram extends TransitionDiagram<Offset> {
  const SlideTransitionDiagram({Key key, bool decorate = true}) : super(key: key, decorate: decorate);

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
        child: const SampleWidget(),
      ),
    );
  }
}

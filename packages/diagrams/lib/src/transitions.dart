// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'animation_diagram.dart';
import 'diagram_step.dart';
import 'utils.dart';

const Duration _kOverallAnimationDuration = Duration(seconds: 6);
const double _kLogoSize = 150.0;

class TransitionDiagramTapper extends StatefulWidget {
  const TransitionDiagramTapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<TransitionDiagramTapper> createState() =>
      _TransitionDiagramTapperState();
}

class _TransitionDiagramTapperState extends State<TransitionDiagramTapper>
    with TickerProviderStateMixin, LockstepStateMixin {
  Future<void> startAnimation() async {
    // Wait for the tree to finish building before attempting to find our
    // RenderObject.
    await Future<void>.delayed(Duration.zero);

    final WidgetController controller = DiagramWidgetController.of(context);

    final RenderBox target = context.findRenderObject()! as RenderBox;
    Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    await controller.tapAt(targetOffset);

    await waitLockstep(const Duration(seconds: 3));

    targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    await controller.tapAt(targetOffset);
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class TransitionDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async {
    return const <DiagramMetadata>[
      AlignTransitionDiagram(),
      DecoratedBoxTransitionDiagram(),
      FadeTransitionDiagram(),
      PositionedTransitionDiagram(),
      RelativePositionedTransitionDiagram(),
      RotationTransitionDiagram(),
      ScaleTransitionDiagram(),
      SizeTransitionDiagram(),
      SlideTransitionDiagram(),
      AlignTransitionDiagram(decorate: false),
      DecoratedBoxTransitionDiagram(decorate: false),
      FadeTransitionDiagram(decorate: false),
      PositionedTransitionDiagram(decorate: false),
      RelativePositionedTransitionDiagram(decorate: false),
      RotationTransitionDiagram(decorate: false),
      ScaleTransitionDiagram(decorate: false),
      SizeTransitionDiagram(decorate: false),
      SlideTransitionDiagram(decorate: false),
    ];
  }
}

// Required because AlignTransition requires an Animation<Rect>, not a Animation<Rect?>.
class _NonNullableAlignmentGeometryTween extends Tween<AlignmentGeometry> {
  /// Creates a fractional offset geometry tween.
  _NonNullableAlignmentGeometryTween({
    required AlignmentGeometry begin,
    required AlignmentGeometry end,
  }) : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  AlignmentGeometry lerp(double t) => AlignmentGeometry.lerp(begin, end, t)!;
}

class AlignTransitionDiagram extends TransitionDiagram<AlignmentGeometry> {
  const AlignTransitionDiagram({super.key, super.decorate});

  @override
  Duration get duration => _kOverallAnimationDuration;

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<AlignmentGeometry> buildAnimation(AnimationController controller) {
    return _offsetTween.animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  static final _NonNullableAlignmentGeometryTween _offsetTween =
      _NonNullableAlignmentGeometryTween(
    begin: AlignmentDirectional.bottomStart,
    end: AlignmentDirectional.center,
  );

  @override
  Widget buildTransition(
    BuildContext context,
    Animation<AlignmentGeometry> animation,
  ) {
    return Center(
      child: TransitionDiagramTapper(
        child: AlignTransition(
          alignment: animation,
          child: const SampleWidget(small: true),
        ),
      ),
    );
  }
}

class DecoratedBoxTransitionDiagram extends TransitionDiagram<Decoration> {
  const DecoratedBoxTransitionDiagram({super.key, super.decorate});

  @override
  Duration get duration => _kOverallAnimationDuration;

  @override
  Curve get curve => Curves.decelerate;

  @override
  Animation<Decoration> buildAnimation(AnimationController controller) {
    return _decorationTween.animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static const BorderRadius _beginRadius =
      BorderRadius.all(Radius.circular(50.0));
  static const BorderRadius _endRadius = BorderRadius.zero;
  static final DecorationTween _decorationTween = DecorationTween(
    begin: BoxDecoration(
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
  Widget buildTransition(
      BuildContext context, Animation<Decoration> animation) {
    return TransitionDiagramTapper(
      child: DecoratedBoxTransition(
        decoration: animation,
        child: const SizedBox(
          width: 158.0,
          height: 158.0,
          child: SampleWidget(),
        ),
      ),
    );
  }
}

class FadeTransitionDiagram extends TransitionDiagram<double> {
  const FadeTransitionDiagram({super.key, super.decorate});

  @override
  Duration get duration => _kOverallAnimationDuration;

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return TransitionDiagramTapper(
      child: FadeTransition(
        opacity: animation,
        child: const SampleWidget(),
      ),
    );
  }
}

class PositionedTransitionDiagram extends TransitionDiagram<RelativeRect> {
  const PositionedTransitionDiagram({super.key, super.decorate});

  @override
  Duration get duration => _kOverallAnimationDuration;

  @override
  Curve get curve => Curves.elasticInOut;

  @override
  Animation<RelativeRect> buildAnimation(AnimationController controller) {
    return _rectTween.animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static final RelativeRectTween _rectTween = RelativeRectTween(
    begin: const RelativeRect.fromLTRB(10.0, 10.0, 150.0, 150.0),
    end: const RelativeRect.fromLTRB(100.0, 100.0, 10.0, 10.0),
  );

  @override
  Widget buildTransition(
      BuildContext context, Animation<RelativeRect> animation) {
    return Center(
      child: Stack(
        children: <Widget>[
          const SizedBox(width: 250.0, height: 250.0),
          TransitionDiagramTapper(
            child: PositionedTransition(
              rect: animation,
              child: const SampleWidget(small: true),
            ),
          ),
        ],
      ),
    );
  }
}

// Required because RelativePositionedTransition wants an Animation<Rect>, not a Animation<Rect?>.
class _NonNullableRectTween extends Tween<Rect> {
  /// Creates a [Rect] tween.
  _NonNullableRectTween({required Rect begin, required Rect end})
      : super(begin: begin, end: end);

  /// Returns the value this variable has at the given animation clock value.
  @override
  Rect lerp(double t) => Rect.lerp(begin, end, t)!;
}

class RelativePositionedTransitionDiagram extends TransitionDiagram<Rect> {
  const RelativePositionedTransitionDiagram({super.key, super.decorate});

  @override
  Duration get duration => _kOverallAnimationDuration;

  @override
  Curve get curve => Curves.elasticInOut;

  @override
  Animation<Rect> buildAnimation(AnimationController controller) {
    return _rectTween.animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  static final _NonNullableRectTween _rectTween = _NonNullableRectTween(
    begin: const Rect.fromLTRB(0.0, 0.0, 50.0, 50.0),
    end: const Rect.fromLTRB(140.0, 140.0, 150.0, 150.0),
  );

  @override
  Widget buildTransition(BuildContext context, Animation<Rect> animation) {
    return Center(
      child: Stack(
        children: <Widget>[
          Container(
              color: const Color(0xffffffff), width: 200.0, height: 200.0),
          TransitionDiagramTapper(
            child: RelativePositionedTransition(
              size: const Size(150.0, 150.0),
              rect: animation,
              child: const SampleWidget(small: true),
            ),
          ),
        ],
      ),
    );
  }
}

class RotationTransitionDiagram extends TransitionDiagram<double> {
  const RotationTransitionDiagram({super.key, super.decorate});

  @override
  Duration get duration => _kOverallAnimationDuration;

  @override
  Curve get curve => Curves.elasticOut;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return TransitionDiagramTapper(
      child: RotationTransition(
        turns: animation,
        child: const SampleWidget(),
      ),
    );
  }
}

class ScaleTransitionDiagram extends TransitionDiagram<double> {
  const ScaleTransitionDiagram({super.key, super.decorate});

  @override
  Duration get duration => _kOverallAnimationDuration;

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }

  @override
  Widget buildTransition(BuildContext context, Animation<double> animation) {
    return TransitionDiagramTapper(
      child: ScaleTransition(
        scale: animation,
        child: const SampleWidget(),
      ),
    );
  }
}

class SizeTransitionDiagram extends TransitionDiagram<double> {
  const SizeTransitionDiagram({super.key, super.decorate});

  @override
  Duration get duration => _kOverallAnimationDuration;

  @override
  Curve get curve => Curves.fastOutSlowIn;

  @override
  Animation<double> buildAnimation(AnimationController controller) {
    return CurvedAnimation(
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
        Container(
          // TODO(gspencer): remove these constraints when
          // https://github.com/flutter/flutter/issues/19850 is fixed.
          // SizeTransition hard codes alignment at the beginning, so we have
          // to restrict the width to make it look centered.
          constraints: const BoxConstraints.tightFor(width: _kLogoSize),
          child: TransitionDiagramTapper(
            child: SizeTransition(
              sizeFactor: animation,
              child: const SampleWidget(),
            ),
          ),
        ),
      ],
    );
  }
}

class SlideTransitionDiagram extends TransitionDiagram<Offset> {
  const SlideTransitionDiagram({super.key, super.decorate});

  @override
  Duration get duration => _kOverallAnimationDuration;

  @override
  Curve get curve => Curves.elasticIn;

  @override
  Animation<Offset> buildAnimation(AnimationController controller) {
    return _offsetTween.animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }

  static final Tween<Offset> _offsetTween = Tween<Offset>(
    begin: Offset.zero,
    end: const Offset(1.5, 0.0),
  );

  @override
  Widget buildTransition(BuildContext context, Animation<Offset> animation) {
    return Center(
      child: TransitionDiagramTapper(
        child: SlideTransition(
          position: animation,
          child: const SampleWidget(),
        ),
      ),
    );
  }
}

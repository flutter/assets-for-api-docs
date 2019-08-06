import 'dart:async';

import 'package:flutter/widgets.dart';

/// A [ScrollActivity] that simulates a user dragging their finger over the
/// screen to scroll.
///
/// We cannot use [ScrollController.animateTo] for this animation because it
/// sets [SliverConstraints.userScrollDirection] to [ScrollDirection.idle] to
/// indicate that there is no real user scrolling. However, [SliverAppBar]s use
/// this property to show or hide the app bar when the user changes scrolling
/// direction and we want to show that in the animations.
///
/// This implementation is inspired by [DrivenScrollActivity], but instead
/// of using [ScrollActivityDelegate.setPixels] it uses
/// [ScrollActivityDelegate.applyUserOffset] to simulate real scrolling and
/// to trigger all scroll-related effects in [SliverAppBar]s.
class FakeDragScrollActivity extends ScrollActivity {
  FakeDragScrollActivity(
      ScrollActivityDelegate delegate, {
        @required double from,
        @required double to,
        @required Duration duration,
        @required Curve curve,
        @required TickerProvider vsync,
      }) : assert(from != null),
        assert(to != null),
        assert(duration != null),
        assert(duration > Duration.zero),
        assert(curve != null),
        super(delegate) {
    _lastValue = from;
    _completer = Completer<void>();
    _controller = AnimationController.unbounded(
      value: from,
      debugLabel: '$runtimeType',
      vsync: vsync,
    )
      ..addListener(_tick)
      ..animateTo(to, duration: duration, curve: curve)
          .whenComplete(_end);
  }

  Completer<void> _completer;
  AnimationController _controller;

  Future<void> get done => _completer.future;

  @override
  double get velocity => _controller.velocity;

  double _lastValue;

  void _tick() {
    delegate.applyUserOffset(_lastValue - _controller.value);
    _lastValue = _controller.value;
  }

  void _end() {
    delegate?.goBallistic(velocity);
  }

  @override
  void dispatchOverscrollNotification(ScrollMetrics metrics, BuildContext context, double overscroll) {
    OverscrollNotification(metrics: metrics, context: context, overscroll: overscroll, velocity: velocity).dispatch(context);
  }

  @override
  bool get shouldIgnorePointer => true;

  @override
  bool get isScrolling => true;

  @override
  void dispose() {
    _completer.complete();
    _controller.dispose();
    super.dispose();
  }
}

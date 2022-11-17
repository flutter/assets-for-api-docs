// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../logic/diagram_ticker_controller.dart';

/// Controls the [TickerMode] of a diagram and observes how much time has passed
/// from its perspective.
class DiagramTickerMode extends StatefulWidget {
  const DiagramTickerMode({
    super.key,
    required this.controller,
    required this.child,
  });

  final DiagramTickerController controller;
  final Widget child;

  @override
  State<DiagramTickerMode> createState() => _DiagramTickerModeState();
}

class _DiagramTickerModeState extends State<DiagramTickerMode> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (BuildContext context, Widget? child) {
        return TickerMode(
          key: widget.controller.diagramKey,
          enabled: widget.controller.ticking,
          child: _TickerDurationObserver(
            notifier: widget.controller.elapsed,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _TickerDurationObserver extends StatefulWidget {
  const _TickerDurationObserver({
    required this.notifier,
    required this.child,
  });

  final ValueNotifier<Duration> notifier;
  final Widget child;

  @override
  State<_TickerDurationObserver> createState() =>
      _TickerDurationObserverState();
}

class _TickerDurationObserverState extends State<_TickerDurationObserver>
    with TickerProviderStateMixin {
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker((Duration elapsed) {
      widget.notifier.value = elapsed;
    });
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

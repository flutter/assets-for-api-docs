// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class TickerDurationObserver extends StatefulWidget {
  const TickerDurationObserver({
    super.key,
    this.enabled = true,
    required this.notifier,
    required this.child,
  });

  final bool enabled;
  final ValueNotifier<Duration> notifier;
  final Widget child;

  @override
  State<TickerDurationObserver> createState() => _TickerDurationObserverState();
}

class _TickerDurationObserverState extends State<TickerDurationObserver>
    with TickerProviderStateMixin {
  late final Ticker ticker;

  @override
  void initState() {
    super.initState();
    ticker = createTicker((Duration elapsed) {
      if (widget.enabled) {
        widget.notifier.value = elapsed;
      }
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

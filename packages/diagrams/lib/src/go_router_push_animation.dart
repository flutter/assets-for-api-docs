// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:animation_metadata/animation_metadata.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

const Duration _pauseDuration = Duration(seconds: 1);
const Duration _openDuration = Duration(milliseconds: 300);
const Duration _closeDuration = Duration(milliseconds: 300);
final Duration _totalDuration = _pauseDuration +
    _pauseDuration +
    _openDuration +
    _pauseDuration +
    _closeDuration +
    _pauseDuration;

final GlobalKey _pushShell1 = GlobalKey();
final GlobalKey _pushShell2 = GlobalKey();
final GlobalKey _pushRegularRoute = GlobalKey();

final GlobalKey<NavigatorState> _innerNavigator = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _outerNavigator = GlobalKey<NavigatorState>();

class PushRegularRouteDiagram extends StatefulWidget with DiagramMetadata {
  const PushRegularRouteDiagram({super.key});

  @override
  String get name => 'push_regular_route';

  @override
  VideoFormat get videoFormat => VideoFormat.gif;

  @override
  State<PushRegularRouteDiagram> createState() =>
      _PushRegularRouteDiagramState();

  @override
  Duration? get duration => _totalDuration;
}

class _PushRegularRouteDiagramState extends State<PushRegularRouteDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  Future<void> _tap(GlobalKey key) async {
    final RenderBox target =
        key.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset =
        target.localToGlobal(target.size.center(Offset.zero));
    final WidgetController controller = DiagramWidgetController.of(context);
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await waitLockstep(_pauseDuration);
    await gesture.up();
    await waitLockstep(_openDuration);
  }

  Future<void> _pause() async {
    await waitLockstep(_pauseDuration);
  }

  Future<void> startAnimation() async {
    await _pause();
    await _tap(_pushRegularRoute);
    await _pause();
    _outerNavigator.currentState!.pop();
    await waitLockstep(_closeDuration);
    await _pause();
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return _MainApp();
  }
}

class PushSameShellDiagram extends StatefulWidget with DiagramMetadata {
  const PushSameShellDiagram({super.key});

  @override
  String get name => 'push_same_shell';

  @override
  VideoFormat get videoFormat => VideoFormat.gif;

  @override
  State<PushSameShellDiagram> createState() => _PushSameShellDiagramState();

  @override
  Duration? get duration => _totalDuration;
}

class _PushSameShellDiagramState extends State<PushSameShellDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  Future<void> _tap(GlobalKey key) async {
    final RenderBox target =
        key.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset =
        target.localToGlobal(target.size.center(Offset.zero));
    final WidgetController controller = DiagramWidgetController.of(context);
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await waitLockstep(_pauseDuration);
    await gesture.up();
    await waitLockstep(_openDuration);
  }

  Future<void> _pause() async {
    await waitLockstep(_pauseDuration);
  }

  Future<void> startAnimation() async {
    await _pause();
    await _tap(_pushShell1);
    await _pause();
    _innerNavigator.currentState!.pop();
    await waitLockstep(_closeDuration);
    await _pause();
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return _MainApp();
  }
}

class PushDifferentShellDiagram extends StatefulWidget with DiagramMetadata {
  const PushDifferentShellDiagram({super.key});

  @override
  String get name => 'push_different_shell';

  @override
  VideoFormat get videoFormat => VideoFormat.gif;

  @override
  State<PushDifferentShellDiagram> createState() =>
      _PushDifferentShellDiagramState();

  @override
  Duration? get duration => _totalDuration;
}

class _PushDifferentShellDiagramState extends State<PushDifferentShellDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  Future<void> _tap(GlobalKey key) async {
    final RenderBox target =
        key.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset =
        target.localToGlobal(target.size.center(Offset.zero));
    final WidgetController controller = DiagramWidgetController.of(context);
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await waitLockstep(_pauseDuration);
    await gesture.up();
    await waitLockstep(_openDuration);
  }

  Future<void> _pause() async {
    await waitLockstep(_pauseDuration);
  }

  Future<void> startAnimation() async {
    await _pause();
    await _tap(_pushShell2);
    await _pause();
    _outerNavigator.currentState!.pop();
    await waitLockstep(_closeDuration);
    await _pause();
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return _MainApp();
  }
}

class _MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(350, 622)),
      child: Navigator(
        key: _outerNavigator,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          return PageRouteBuilder<void>(
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Shell1'),
                ),
                body: _Shell1(),
              );
            },
          );
        },
      ),
    );
  }
}

class _Shell1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _innerNavigator,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        return PageRouteBuilder<void>(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextButton(
                  key: _pushShell1,
                  onPressed: () {
                    _innerNavigator.currentState!
                        .push(MaterialPageRoute<void>(builder: (_) {
                      return const Center(child: Text('shell1 body'));
                    }));
                  },
                  child: const Text('push the same shell route /shell1'),
                ),
                TextButton(
                  key: _pushShell2,
                  onPressed: () {
                    _outerNavigator.currentState!
                        .push(MaterialPageRoute<void>(builder: (_) {
                      return Scaffold(
                          appBar: AppBar(
                            title: const Text('shell2'),
                          ),
                          body: const Center(child: Text('shell2 body')));
                    }));
                  },
                  child: const Text('push the different shell route /shell2'),
                ),
                TextButton(
                  key: _pushRegularRoute,
                  onPressed: () {
                    _outerNavigator.currentState!
                        .push(MaterialPageRoute<void>(builder: (_) {
                      return const Scaffold(
                          body: Center(child: Text('Regular Route')));
                    }));
                  },
                  child: const Text('push the regular route /regular-route'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class GoRouterDiagramStep extends DiagramStep {
  @override
  final String category = 'go_router';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
        const PushRegularRouteDiagram(),
        const PushSameShellDiagram(),
        const PushDifferentShellDiagram(),
      ];
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

const Duration _pauseDuration = Duration(seconds: 1);
const Duration _openDuration = Duration(milliseconds: 300);
final Duration _totalDuration =
    _pauseDuration +
    _pauseDuration +
    _openDuration +
    _pauseDuration +
    _openDuration +
    _pauseDuration;
final GlobalKey _openDialogKey = GlobalKey();
final GlobalKey _treasuryKey = GlobalKey();
final GlobalKey _stateKey = GlobalKey();

class SimpleDialogDiagram extends StatefulWidget with DiagramMetadata {
  const SimpleDialogDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  State<SimpleDialogDiagram> createState() => _SimpleDialogDiagramState();

  @override
  Duration? get duration => _totalDuration;
}

class _SimpleDialogDiagramState extends State<SimpleDialogDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  Future<void> _tap(GlobalKey key) async {
    final RenderBox target =
        key.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset = target.localToGlobal(
      target.size.center(Offset.zero),
    );
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
    await _tap(_openDialogKey);
    await _pause();
    await _pause();
    await _pause();
    await _tap(_treasuryKey);
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(350, 622)),
      child: Navigator(
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          return PageRouteBuilder<void>(
            pageBuilder:
                (
                  BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation,
                ) {
                  return Scaffold(
                    appBar: AppBar(title: const Text('SimpleDialog Demo')),
                    body: Center(
                      child: Builder(
                        builder: (BuildContext context) {
                          return OutlinedButton(
                            key: _openDialogKey,
                            child: const Text('Show Options'),
                            onPressed: () => _askedToLead(context),
                          );
                        },
                      ),
                    ),
                  );
                },
          );
        },
      ),
    );
  }

  Future<void> _askedToLead(BuildContext context) async {
    final Department result = (await showDialog<Department>(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select assignment'),
          children: <Widget>[
            SimpleDialogOption(
              key: _treasuryKey,
              onPressed: () {
                Navigator.pop<Department>(context, Department.treasury);
              },
              child: const Text('Treasury department'),
            ),
            SimpleDialogOption(
              key: _stateKey,
              onPressed: () {
                Navigator.pop<Department>(context, Department.state);
              },
              child: const Text('State department'),
            ),
          ],
        );
      },
    ))!;

    switch (result) {
      case Department.treasury:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Treasury')));
        break;
      case Department.state:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('State')));
        break;
    }
  }
}

enum Department { treasury, state }

class SimpleDialogDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<SimpleDialogDiagram>> get diagrams async => <SimpleDialogDiagram>[
    const SimpleDialogDiagram('simple_dialog'),
  ];
}

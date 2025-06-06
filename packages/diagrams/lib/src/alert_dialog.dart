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
final Duration _totalDuration = _pauseDuration + _openDuration + _pauseDuration;

class AlertDialogDiagram extends StatefulWidget with DiagramMetadata {
  const AlertDialogDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  State<AlertDialogDiagram> createState() => _AlertDialogDiagramState();

  @override
  Duration? get duration => _totalDuration;
}

class _AlertDialogDiagramState extends State<AlertDialogDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  final GlobalKey _openDialogKey = GlobalKey();

  Future<void> startAnimation() async {
    await waitLockstep(_pauseDuration);

    final RenderBox target =
        _openDialogKey.currentContext!.findRenderObject()! as RenderBox;
    final Offset targetOffset = target.localToGlobal(
      target.size.center(Offset.zero),
    );
    final WidgetController controller = DiagramWidgetController.of(context);
    final TestGesture gesture = await controller.startGesture(targetOffset);

    await waitLockstep(_openDuration);

    await gesture.up();
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
                    appBar: AppBar(title: const Text('AlertDialog Demo')),
                    body: Center(
                      child: Builder(
                        builder: (BuildContext context) {
                          return OutlinedButton(
                            key: _openDialogKey,
                            child: const Text('Show Dialog'),
                            onPressed: () => _neverSatisfied(context),
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

  Future<void> _neverSatisfied(BuildContext context) async {
    return showDialog<void>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class AlertDialogDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<AlertDialogDiagram>> get diagrams async => <AlertDialogDiagram>[
    const AlertDialogDiagram('alert_dialog'),
  ];
}

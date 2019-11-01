// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

const Duration _pauseDuration = Duration(seconds: 1);
const Duration _openDuration = Duration(milliseconds: 300);
final Duration _totalDuration = _pauseDuration + _openDuration + _pauseDuration;
final GlobalKey _openDialogKey = GlobalKey();

class AlertDialogDiagram extends StatelessWidget implements DiagramMetadata {
  const AlertDialogDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(350, 622)),
      child: Navigator(
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
                  title: const Text('AlertDialog Demo'),
                ),
                body: Center(
                  child: Builder(
                    builder: (BuildContext context) {
                      return RaisedButton(
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
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Approve'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

class AlertDialogDiagramStep extends DiagramStep<AlertDialogDiagram> {
  AlertDialogDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<AlertDialogDiagram>> get diagrams async => <AlertDialogDiagram>[
        const AlertDialogDiagram('alert_dialog'),
      ];

  @override
  Future<File> generateDiagram(AlertDialogDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    controller.advanceTime(Duration.zero);

    final Future<File> result = controller.drawAnimatedDiagramToFiles(
      end: _totalDuration,
      frameRate: 60,
      name: diagram.name,
      category: category,
    );

    await Future<void>.delayed(_pauseDuration);

    final RenderBox target = _openDialogKey.currentContext.findRenderObject();
    final Offset targetOffset =
        target.localToGlobal(target.size.center(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await Future<void>.delayed(_pauseDuration);
    await gesture.up();

    await Future<void>.delayed(_openDuration + _pauseDuration);

    return result;
  }
}

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
final Duration _totalDuration = _pauseDuration +
    _pauseDuration +
    _openDuration +
    _pauseDuration +
    _openDuration +
    _pauseDuration;
final GlobalKey _openDialogKey = GlobalKey();
final GlobalKey _treasuryKey = GlobalKey();
final GlobalKey _stateKey = GlobalKey();

class SimpleDialogDiagram extends StatelessWidget implements DiagramMetadata {
  const SimpleDialogDiagram(this.name);

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
                  title: const Text('SimpleDialog Demo'),
                ),
                body: Center(
                  child: Builder(
                    builder: (BuildContext context) {
                      return RaisedButton(
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
    final Department result = await showDialog<Department>(
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
    );

    switch (result) {
      case Department.treasury:
        Scaffold.of(context).showSnackBar(
          const SnackBar(content: Text('Treasury')),
        );
        break;
      case Department.state:
        Scaffold.of(context).showSnackBar(
          const SnackBar(content: Text('State')),
        );
        break;
    }
  }
}

enum Department {
  treasury,
  state,
}

class SimpleDialogDiagramStep extends DiagramStep<SimpleDialogDiagram> {
  SimpleDialogDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<SimpleDialogDiagram>> get diagrams async => <SimpleDialogDiagram>[
        const SimpleDialogDiagram('simple_dialog'),
      ];

  @override
  Future<File> generateDiagram(SimpleDialogDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    controller.advanceTime(Duration.zero);

    final Future<File> result = controller.drawAnimatedDiagramToFiles(
      end: _totalDuration,
      frameRate: 60,
      name: diagram.name,
      category: category,
    );

    await _pause();
    await _tap(_openDialogKey);
    await _pause();
    await _pause();
    await _pause();
    await _tap(_treasuryKey);
    await _pause();

    return result;
  }

  Future<void> _tap(GlobalKey key) async {
    final RenderBox target = key.currentContext.findRenderObject();
    final Offset targetOffset =
        target.localToGlobal(target.size.center(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await Future<void>.delayed(_pauseDuration);
    await gesture.up();
    await Future<void>.delayed(_openDuration);
  }

  Future<void> _pause() async {
    await Future<void>.delayed(_pauseDuration);
  }
}

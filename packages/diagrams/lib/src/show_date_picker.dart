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
final Duration _totalDuration = _pauseDuration + _pauseDuration + _openDuration + _pauseDuration;
final GlobalKey _buttonKey = GlobalKey();

class ShowDatePickerDiagram extends StatelessWidget implements DiagramMetadata {
  const ShowDatePickerDiagram(this.name);

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
                appBar: AppBar(title: const Text('showDatePicker Demo')),
                body: Center(
                  child: Builder(
                    builder: (BuildContext context) {
                      return RaisedButton(
                        key: _buttonKey,
                        child: const Text('showDatePicker'),
                        onPressed: () {
                          showDatePicker(
                            context: context,
                            useRootNavigator: false,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2018),
                            lastDate: DateTime(2030),
                            builder: (BuildContext context, Widget child) {
                              return Theme(
                                data: ThemeData.dark(),
                                child: child,
                              );
                            },
                          );
                        },
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
}

class ShowDatePickerDiagramStep extends DiagramStep<ShowDatePickerDiagram> {
  ShowDatePickerDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<ShowDatePickerDiagram>> get diagrams async => <ShowDatePickerDiagram>[
        const ShowDatePickerDiagram('show_date_picker'),
      ];

  @override
  Future<File> generateDiagram(ShowDatePickerDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    controller.advanceTime(Duration.zero);

    final Future<File> result = controller.drawAnimatedDiagramToFiles(
      end: _totalDuration,
      frameRate: 60,
      name: diagram.name,
      category: category,
    );

    await _pause();
    await _tap(_buttonKey.currentContext.findRenderObject());
    await _pause();

    return result;
  }

  Future<void> _tap(RenderBox target) async {
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

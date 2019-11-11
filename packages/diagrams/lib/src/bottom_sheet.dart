// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

const String _showBottomSheet = 'show_bottom_sheet';
const String _showModalBottomSheet = 'show_modal_bottom_sheet';
const Duration _pauseDuration = Duration(seconds: 1);
const Duration _openDuration = Duration(milliseconds: 300);
const Duration _totalDuration = Duration(seconds: 4);
final GlobalKey _openKey = GlobalKey();
final GlobalKey _closeKey = GlobalKey();

class BottomSheetDiagram extends StatelessWidget implements DiagramMetadata {
  const BottomSheetDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _showBottomSheet:
        returnWidget = Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('showBottomSheet Demo'),
          ),
          body: Center(
            child: Builder(
              builder: (BuildContext context) {
                return RaisedButton(
                  key: _openKey,
                  child: const Text('showBottomSheet'),
                  onPressed: () {
                    Scaffold.of(context).showBottomSheet<void>(
                      (BuildContext context) {
                        return Container(
                          height: 200,
                          color: Colors.amber,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('BottomSheet'),
                                RaisedButton(
                                  key: _closeKey,
                                  child: const Text('Close BottomSheet'),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
        break;
      case _showModalBottomSheet:
        returnWidget = Scaffold(
          appBar: AppBar(title: const Text('showModalBottomSheet Demo')),
          body: Center(
            child: Builder(
              builder: (BuildContext context) {
                return RaisedButton(
                  key: _openKey,
                  child: const Text('showModalBottomSheet'),
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 200,
                          color: Colors.amber,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('Modal BottomSheet'),
                                RaisedButton(
                                  key: _closeKey,
                                  child: const Text('Close BottomSheet'),
                                  onPressed: () => Navigator.pop(context),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
        break;
    }

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
              return returnWidget;
            },
          );
        },
      ),
    );
  }
}

class BottomSheetDiagramStep extends DiagramStep<BottomSheetDiagram> {
  BottomSheetDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<BottomSheetDiagram>> get diagrams async => <BottomSheetDiagram>[
        const BottomSheetDiagram(_showBottomSheet),
        const BottomSheetDiagram(_showModalBottomSheet),
      ];

  @override
  Future<File> generateDiagram(BottomSheetDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    controller.advanceTime(Duration.zero);

    final Future<File> result = controller.drawAnimatedDiagramToFiles(
      end: _totalDuration,
      frameRate: 60,
      name: diagram.name,
      category: category,
    );

    await _pause();
    await _tap(_openKey);
    await _pause();
    await _pause();
    await _pause();
    await _pause();
    await _tap(_closeKey);
    await _pause();

    return result;
  }

  Future<void> _tap(GlobalKey key) async {
    final RenderBox target = key.currentContext.findRenderObject();
    final Offset targetOffset =
        target.localToGlobal(target.size.center(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await _pause();
    await _pause();
    await gesture.up();
    await Future<void>.delayed(_openDuration);
  }

  Future<void> _pause() => Future<void>.delayed(_pauseDuration);
}

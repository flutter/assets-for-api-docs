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
const Duration _drawerOpenDuration = Duration(milliseconds: 300);
final Duration _totalDuration =
    _pauseDuration + _drawerOpenDuration + _pauseDuration;
final GlobalKey _menuKey = GlobalKey();

class DrawerDiagram extends StatelessWidget implements DiagramMetadata {
  const DrawerDiagram(this.name);

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
              return Container(
                alignment: FractionalOffset.center,
                color: Colors.white,
                child: Scaffold(
                  appBar: AppBar(
                    title: const Text('Drawer Demo'),
                    automaticallyImplyLeading: false,
                    leading: Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          key: _menuKey,
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        );
                      },
                    ),
                  ),
                  drawer: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: const <Widget>[
                        DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Text(
                            'Drawer Header',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        ListTile(
                          leading: Icon(Icons.message),
                          title: Text('Messages'),
                        ),
                        ListTile(
                          leading: Icon(Icons.account_circle),
                          title: Text('Profile'),
                        ),
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text('Settings'),
                        ),
                      ],
                    ),
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

class DrawerDiagramStep extends DiagramStep<DrawerDiagram> {
  DrawerDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DrawerDiagram>> get diagrams async => <DrawerDiagram>[
        const DrawerDiagram('drawer'),
      ];

  @override
  Future<File> generateDiagram(DrawerDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    controller.advanceTime(Duration.zero);

    final Future<File> result = controller.drawAnimatedDiagramToFiles(
      end: _totalDuration,
      frameRate: 60,
      name: diagram.name,
      category: category,
    );

    await Future<void>.delayed(_pauseDuration);

    final RenderBox target = _menuKey.currentContext.findRenderObject();
    final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    await gesture.up();

    await Future<void>.delayed(_drawerOpenDuration + _pauseDuration);

    return result;
  }
}

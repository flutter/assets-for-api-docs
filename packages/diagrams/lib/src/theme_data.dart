// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';
import 'utils.dart';

const String _themeData = 'theme_data';
const String _materialAppThemeData = 'material_app_theme_data';
final GlobalKey _heroKey = GlobalKey();
final GlobalKey _canvasKey = GlobalKey();
final GlobalKey _bodyKey = GlobalKey();
final GlobalKey _appBarKey = GlobalKey();
final GlobalKey _fabKey = GlobalKey();

class ThemeDataDiagram extends StatelessWidget implements DiagramMetadata {
  const ThemeDataDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _themeData:
        returnWidget = ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(150.0, 150.0)),
          child: Container(
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: Center(
              child: Theme(
                data: ThemeData(primaryColor: Colors.blue),
                child: Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Theme.of(context).primaryColor,
                    );
                  },
                ),
              ),
            ),
          ),
        );
        break;
      case _materialAppThemeData:
        returnWidget = ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(420, 533)),
          child: Container(
            padding: const EdgeInsets.only(right: 120),
            color: Colors.white,
            child: Center(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primaryColor: Colors.blue,
                  accentColor: Colors.green,
                  textTheme: TextTheme(bodyText2: TextStyle(color: Colors.purple)),
                ),
                home: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Scaffold(
                        key: _heroKey,
                        appBar: AppBar(
                          key: _appBarKey,
                          title: const Text('ThemeData Demo'),
                        ),
                        floatingActionButton: FloatingActionButton(
                          child: const Icon(Icons.add),
                          onPressed: () {},
                          key: _fabKey,
                        ),
                        body: Center(
                          child: Text(
                            'Button pressed 0 times',
                            key: _bodyKey,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: LabelPainterWidget(
                        key: _canvasKey,
                        heroKey: _heroKey,
                        labels: <Label>[
                          Label(
                            _bodyKey,
                            ' body1',
                            const FractionalOffset(1.1, 0.5),
                          ),
                          Label(
                            _appBarKey,
                            ' primaryColor',
                            const FractionalOffset(0.9, 0.5),
                          ),
                          Label(
                            _fabKey,
                            ' accentColor',
                            const FractionalOffset(0.8, 0.5),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
        break;
    }

    return returnWidget;
  }
}

class ThemeDataDiagramStep extends DiagramStep<ThemeDataDiagram> {
  ThemeDataDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<ThemeDataDiagram>> get diagrams async => <ThemeDataDiagram>[
        const ThemeDataDiagram(_themeData),
        const ThemeDataDiagram(_materialAppThemeData),
      ];

  @override
  Future<File> generateDiagram(ThemeDataDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

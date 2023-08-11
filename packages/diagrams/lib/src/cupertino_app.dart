// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'diagram_step.dart';

const String _basic = 'basic_cupertino_app';
const String _theme = 'theme_cupertino_app';

class CupertinoAppDiagram extends StatelessWidget with DiagramMetadata {
  const CupertinoAppDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    late Widget returnWidget;

    switch (name) {
      case _basic:
        returnWidget = const CupertinoApp(
          home: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text('Home'),
            ),
            child: Center(child: Icon(CupertinoIcons.share)),
          ),
          debugShowCheckedModeBanner: false,
        );
        break;
      case _theme:
        returnWidget = const CupertinoApp(
          theme: CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: CupertinoColors.systemOrange,
          ),
          home: CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text('CupertinoApp Theme'),
            ),
            child: Center(child: Icon(CupertinoIcons.share)),
          ),
          debugShowCheckedModeBanner: false,
        );
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 533.33)),
      child: Container(
        color: CupertinoColors.white,
        child: returnWidget,
      ),
    );
  }
}

class CupertinoAppDiagramStep extends DiagramStep {
  @override
  final String category = 'cupertino';

  // This diagram will only be created when run on macOS, so that the fonts are
  // correct.
  @override
  Set<DiagramPlatform> get platforms =>
      <DiagramPlatform>{DiagramPlatform.macos};

  @override
  Future<List<CupertinoAppDiagram>> get diagrams async => <CupertinoAppDiagram>[
        const CupertinoAppDiagram(_basic),
        const CupertinoAppDiagram(_theme),
      ];
}

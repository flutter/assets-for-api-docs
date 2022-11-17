// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pages/diagram_catalog.dart';

void main() {
  runApp(const DiagramViewerApp());
}

class DiagramViewerApp extends StatefulWidget {
  const DiagramViewerApp({super.key});

  @override
  State<DiagramViewerApp> createState() => DiagramViewerAppState();

  static DiagramViewerAppState of(BuildContext context) =>
      context.findAncestorStateOfType()!;
}

class DiagramViewerAppState extends State<DiagramViewerApp> {
  bool _dark = false;

  void toggleBrightness() {
    setState(() {
      _dark = !_dark;
    });
  }

  late final WidgetController widgetController = LiveWidgetController(
    WidgetsBinding.instance,
  );

  @override
  Widget build(BuildContext context) {
    return DiagramWidgetController(
      controller: widgetController,
      child: MaterialApp(
        theme:
            ThemeData(brightness: _dark ? Brightness.dark : Brightness.light),
        home: const DiagramCatalogPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

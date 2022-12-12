// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'pages/diagram_catalog.dart';

void main() {
  runApp(const DiagramViewerApp());
}

class DiagramViewerApp extends StatefulWidget {
  const DiagramViewerApp({
    super.key,
    this.home,
  });

  final Widget? home;

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(brightness: _dark ? Brightness.dark : Brightness.light),
      home: widget.home ?? const DiagramCatalogPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

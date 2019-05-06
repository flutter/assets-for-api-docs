// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

final Duration _kTotalDuration = _kPauseDuration * 5;
const Duration _kPauseDuration = Duration(seconds: 1);
const double _kAnimationFrameRate = 60.0;

class TabsDiagram extends StatefulWidget implements DiagramMetadata {
  const TabsDiagram(this.name);

  @override
  final String name;

  @override
  State<TabsDiagram> createState() => TabsDiagramState();
}

class TabsDiagramState extends State<TabsDiagram> with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = const <Tab>[
    Tab(text: 'Left'),
    Tab(text: 'Right'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);

    // schedule a callback to invoke taps after specific amount of time
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return ConstrainedBox(
    //   key: UniqueKey(),
    //   constraints: BoxConstraints.tight(const Size(540.0, 260.0)),
    //   child: MaterialApp(
      return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: myTabs,
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: myTabs.map((Tab tab) {
              return Center(child: Text(tab.text));
            }).toList(),
          ),
        ),
      );
    //   ),
    // );
  }
}

class TabsDiagramStep extends DiagramStep {
  TabsDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const TabsDiagram('tabs'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final TabsDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
    );
  }
}
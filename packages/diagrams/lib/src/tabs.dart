// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

const Duration _kTabScrollDuration = Duration(milliseconds: 300);
const Duration _kPauseDuration = Duration(seconds: 1);
final Duration _kTotalAnimationTime =
    _kTabScrollDuration
  + _kPauseDuration
  + _kTabScrollDuration
  + _kPauseDuration;
const double _kAnimationFrameRate = 60.0;
final List<GlobalKey> _tabKeys = <GlobalKey>[
  GlobalKey(),
  GlobalKey(),
];

class TabsDiagram extends StatefulWidget implements DiagramMetadata {
  const TabsDiagram(this.name);

  @override
  final String name;

  @override
  State<TabsDiagram> createState() => TabsDiagramState();
}

class TabsDiagramState extends State<TabsDiagram> with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(key: _tabKeys[0], text: 'Left'),
    Tab(key: _tabKeys[1], text: 'Right'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(540.0, 960.0)),
      child: MaterialApp(
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
      ),
    );
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

  void tapTabs(DiagramController controller, Duration now) async {
    RenderBox target;
    switch(now.inMilliseconds) {
      case 0:
        target = _tabKeys[1].currentContext.findRenderObject();
        break;
      case 1300:
        target = _tabKeys[0].currentContext.findRenderObject();
        break;
      default:
        return;
    }
    final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    gesture.up();
  }

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final TabsDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalAnimationTime,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
      gestureCallback: tapTabs,
    );
  }
}
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';
import 'utils.dart';

const Duration _kTabAnimationDuration = Duration(milliseconds: 300);
const Duration _kPauseDuration = Duration(seconds: 2);
final Duration _kTotalAnimationTime =
    _kPauseDuration +
    _kTabAnimationDuration +
    _kPauseDuration +
    _kTabAnimationDuration +
    _kPauseDuration;

class TabsDiagram extends StatefulWidget with DiagramMetadata {
  const TabsDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  State<TabsDiagram> createState() => TabsDiagramState();

  @override
  Duration? get duration => _kTotalAnimationTime;
}

class TabsDiagramState extends State<TabsDiagram>
    with TickerProviderStateMixin, LockstepStateMixin {
  final List<GlobalKey> _tabKeys = <GlobalKey>[GlobalKey(), GlobalKey()];

  late final List<Tab> myTabs = <Tab>[
    Tab(key: _tabKeys[0], text: 'LEFT'),
    Tab(key: _tabKeys[1], text: 'RIGHT'),
  ];

  late TabController _tabController;

  Future<void> startAnimation() async {
    await waitLockstep(_kPauseDuration);

    final RenderBox tab0 =
        _tabKeys[0].currentContext!.findRenderObject()! as RenderBox;
    final RenderBox tab1 =
        _tabKeys[1].currentContext!.findRenderObject()! as RenderBox;
    final Offset tab0Offset = tab0.localToGlobal(tab0.size.center(Offset.zero));
    final Offset tab1Offset = tab1.localToGlobal(tab1.size.center(Offset.zero));
    final WidgetController controller = DiagramWidgetController.of(context);

    await controller.tapAt(tab1Offset);

    await waitLockstep(_kPauseDuration);

    await controller.tapAt(tab0Offset);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    startAnimation();
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
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            bottom: TabBar(controller: _tabController, tabs: myTabs),
          ),
          body: TabBarView(
            controller: _tabController,
            children: myTabs.map((Tab tab) {
              final String label = tab.text!.toLowerCase();
              return Center(
                child: Text(
                  'This is the $label tab',
                  style: const TextStyle(fontSize: 36),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class TabsDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<TabsDiagram>> get diagrams async => const <TabsDiagram>[
    TabsDiagram('tabs'),
  ];
}

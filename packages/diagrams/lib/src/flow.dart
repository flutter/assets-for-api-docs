// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

final List<GlobalKey> keys = List<GlobalKey>.generate(5, (int index) => new GlobalKey());
final Duration _kTotalDuration = _kPauseDuration * 5;
const Duration _kPauseDuration = Duration(seconds: 1);
const double _kAnimationFrameRate = 60.0;

class FlowDiagram extends StatefulWidget implements DiagramMetadata {
  const FlowDiagram(this.name);

  @override
  final String name;

  @override
  State<FlowDiagram> createState() => FlowDiagramState();
}

class FlowDiagramState extends State<FlowDiagram> with SingleTickerProviderStateMixin {
  AnimationController menuAnimation;
  IconData lastTapped = Icons.notifications;
  final List<IconData> menuItems = <IconData>[
    Icons.home,
    Icons.new_releases,
    Icons.notifications,
    Icons.settings,
    Icons.menu,
  ];

  void _updateMenu(IconData icon) {
    setState(() {
      if (icon != Icons.menu)
        lastTapped = icon;
    });
  }

  @override
  void initState() {
    super.initState();
    menuAnimation = AnimationController(
      lowerBound: 0,
      upperBound: 1,
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  Widget flowMenuItem(IconData icon) {
    final double buttonDiameter = MediaQuery.of(context).size.width / menuItems.length;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: RawMaterialButton(
        key: keys[menuItems.indexOf(icon)],
        fillColor: lastTapped == icon ? Colors.amber[700] : Colors.blue,
        splashColor: Colors.amber[100],
        shape: const CircleBorder(),
        constraints: BoxConstraints.tight(Size(buttonDiameter, buttonDiameter)),
        onPressed: () {
          _updateMenu(icon);
          menuAnimation.status == AnimationStatus.completed
            ? menuAnimation.reverse()
            : menuAnimation.forward();
        },
        child: Icon(
          icon,
          color: Colors.white,
          size: 45.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: new BoxConstraints.tight(const Size(450.0, 100.0)),
      child: new Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.only(left: 10.0),
        color: Colors.white,
        child: Flow(
          delegate: FlowMenuDelegate(menuAnimation: menuAnimation),
          children: menuItems.map<Widget>((IconData icon) => flowMenuItem(icon)).toList(),
        ),
      ),
    );
  }
}

class FlowMenuDelegate extends FlowDelegate {
  FlowMenuDelegate({this.menuAnimation}) : super(repaint: menuAnimation);

  final Animation<double> menuAnimation;

  @override
  bool shouldRepaint(FlowMenuDelegate oldDelegate) {
    return menuAnimation != oldDelegate.menuAnimation;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    double dx = 0.0;
    for (int i = 0; i < context.childCount; ++i) {
      dx = context.getChildSize(i).width * i;
      context.paintChild(
        i,
        transform: Matrix4.translationValues(
          dx * menuAnimation.value,
          0,
          0,
        ),
      );
    }
  }
}

class FlowDiagramStep extends DiagramStep<FlowDiagram> {
  FlowDiagramStep(DiagramController controller) : super(controller);

  void tapFlowMenuItem(DiagramController controller, Duration now) async {
    RenderBox target;
    switch (now.inMilliseconds) {
      case 1000:
        target = keys[4].currentContext.findRenderObject();
        break;
      case 2000:
        target = keys[0].currentContext.findRenderObject();
        break;
      case 3100:
        target = keys[4].currentContext.findRenderObject();
        break;
      case 4100:
        target = keys[3].currentContext.findRenderObject();
        break;
      default:
        target = keys[4].currentContext.findRenderObject();
        return;
    }
    final Offset targetOffset = target.localToGlobal(target.size.center(Offset.zero));
    final TestGesture gesture = await controller.startGesture(targetOffset);
    gesture.up();
  }

  @override
  final String category = 'widgets';

  @override
  Future<List<FlowDiagram>> get diagrams async => <FlowDiagram>[
    const FlowDiagram('flow_menu'),
  ];

  @override
  Future<File> generateDiagram(FlowDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
      gestureCallback: tapFlowMenuItem,
    );
  }
}

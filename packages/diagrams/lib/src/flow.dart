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
  int active = 1;
  final Map<int, IconData> menuItems = <IconData>[
    Icons.home,
    Icons.new_releases,
    Icons.notifications,
    Icons.settings,
    Icons.menu,
  ].asMap();

  @override
  void initState() {
    super.initState();
    menuAnimation = AnimationController(
      lowerBound: 1,
      upperBound: 1000,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  Widget buildItem(int k, IconData v) {
    return GestureDetector(
      key: keys[k],
      onTap: () {
        if (k != 4)
          active = k;
        menuAnimation.value == 1000 ? menuAnimation.reverse() : menuAnimation.forward();
        setState(() {});
      },
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active == k ? Colors.amber[700] : Colors.blue,
          boxShadow: const <BoxShadow>[BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          )]
        ),
        child: Center(
          child: Icon(
            v,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: new BoxConstraints.tight(const Size(560.0, 150.0)),
      child: new Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.only(left: 5.0),
        color: Colors.white,
        child:Flow(
          delegate: FlowMenuDelegate(menuAnimation: menuAnimation),
          children: menuItems
            .map<int, Widget>((int k, IconData v) => MapEntry<int, Widget>(k, buildItem(k, v)))
            .values
            .toList(),
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
          dx * 0.001 * menuAnimation.value,
          0,
          0,
        ),
      );
    }
  }
}

class FlowDiagramStep extends DiagramStep {
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
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const FlowDiagram('flow_menu'),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final FlowDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawAnimatedDiagramToFiles(
      end: _kTotalDuration,
      frameRate: _kAnimationFrameRate,
      name: diagram.name,
      category: category,
      gestureCallback: tapFlowMenuItem,
    );
  }
}
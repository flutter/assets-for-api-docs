// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import '../diagrams.dart';

class AppLifecycleDiagram extends StatefulWidget with DiagramMetadata {
  const AppLifecycleDiagram({super.key, required this.name});

  @override
  final String name;

  static const Color arrowBorderColor = Color(0xFF858585);
  static const Color arrowColor = arrowBorderColor;
  static const Color transitionLabelColor = arrowBorderColor;
  static const Color mobileTransitionColor = Color(0xff6d9eeb);
  static const double arrowThickness = 20;
  static const double stateBoxWidth = 244;
  static const double stateBoxHeight = 100;
  static const double overallWidth = 1000;
  static const double overallHeight = 360;
  static const double middleArrowWidth = (overallWidth - 3 * stateBoxWidth) / 2;
  static const double startArrowWidth = overallWidth - 2 * stateBoxWidth;
  static const double verticalArrowHeight = overallHeight - 2 * stateBoxHeight;
  static const double middleSpacerHeight = verticalArrowHeight;

  @override
  State<AppLifecycleDiagram> createState() => _DiagramState();
}

class _DiagramState extends State<AppLifecycleDiagram> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(
        const Size(
          AppLifecycleDiagram.overallWidth,
          AppLifecycleDiagram.overallHeight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Column(
              children: <Widget>[
                AppLifecycleStateBox(appState: AppLifecycleState.detached),
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 90.0),
                  child: LabeledArrow(
                    fillColor: AppLifecycleDiagram.mobileTransitionColor,
                    length: AppLifecycleDiagram.verticalArrowHeight,
                    orientation: AxisDirection.up,
                    label: TransitionLabel(
                      'onDetach',
                      color: AppLifecycleDiagram.mobileTransitionColor,
                    ),
                  ),
                ),
                AppLifecycleStateBox(appState: AppLifecycleState.paused),
              ],
            ),
            Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  height: AppLifecycleDiagram.stateBoxHeight,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: LabeledArrow(
                      fillColor: AppLifecycleDiagram.arrowColor,
                      length: AppLifecycleDiagram.startArrowWidth,
                      label: TransitionLabel('onStart'),
                    ),
                  ),
                ),
                const SizedBox(height: AppLifecycleDiagram.middleSpacerHeight),
                const SizedBox(
                  height: AppLifecycleDiagram.stateBoxHeight,
                  child: Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          LabeledArrow(
                            fillColor:
                                AppLifecycleDiagram.mobileTransitionColor,
                            length: AppLifecycleDiagram.middleArrowWidth,
                            label: TransitionLabel(
                              'onRestart',
                              color: AppLifecycleDiagram.mobileTransitionColor,
                            ),
                          ),
                          LabeledArrow(
                            fillColor:
                                AppLifecycleDiagram.mobileTransitionColor,
                            length: AppLifecycleDiagram.middleArrowWidth,
                            label: TransitionLabel(
                              'onPause',
                              color: AppLifecycleDiagram.mobileTransitionColor,
                            ),
                            orientation: AxisDirection.left,
                          ),
                        ],
                      ),
                      AppLifecycleStateBox(appState: AppLifecycleState.hidden),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          LabeledArrow(
                            fillColor: AppLifecycleDiagram.arrowColor,
                            length: AppLifecycleDiagram.middleArrowWidth,
                            label: TransitionLabel('onShow'),
                          ),
                          LabeledArrow(
                            fillColor: AppLifecycleDiagram.arrowColor,
                            length: AppLifecycleDiagram.middleArrowWidth,
                            label: TransitionLabel('onHide'),
                            orientation: AxisDirection.left,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Column(
              children: <Widget>[
                AppLifecycleStateBox(appState: AppLifecycleState.resumed),
                Row(
                  children: <Widget>[
                    LabeledArrow(
                      fillColor: AppLifecycleDiagram.arrowColor,
                      orientation: AxisDirection.down,
                      length: AppLifecycleDiagram.verticalArrowHeight,
                      label: TransitionLabel('onInactive'),
                    ),
                    LabeledArrow(
                      fillColor: AppLifecycleDiagram.arrowColor,
                      length: AppLifecycleDiagram.verticalArrowHeight,
                      orientation: AxisDirection.up,
                      label: TransitionLabel('onResume'),
                    ),
                  ],
                ),
                AppLifecycleStateBox(appState: AppLifecycleState.inactive),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransitionLabel extends StatelessWidget {
  const TransitionLabel(
    this.label, {
    super.key,
    this.color = AppLifecycleDiagram.transitionLabelColor,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(fontFamily: 'Noto Sans', color: color, fontSize: 20),
    );
  }
}

class AppLifecycleStateBox extends StatelessWidget {
  const AppLifecycleStateBox({super.key, required this.appState});

  final AppLifecycleState appState;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: AppLifecycleDiagram.stateBoxWidth,
      height: AppLifecycleDiagram.stateBoxHeight,
      decoration: ShapeDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.blue.shade100
            : Colors.blue.shade800,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        appState.name,
        style: const TextStyle(fontFamily: 'Noto Sans', fontSize: 30),
      ),
    );
  }
}

class LabeledArrow extends StatelessWidget {
  const LabeledArrow({
    super.key,
    required this.fillColor,
    this.orientation = AxisDirection.right,
    this.length = 400,
    this.tipSize = 20,
    this.thickness = 2,
    required this.label,
  });

  final Color fillColor;
  final AxisDirection orientation;
  final Widget label;
  final double thickness;
  final double tipSize;
  final double length;

  @override
  Widget build(BuildContext context) {
    int quarterTurns = 0;
    bool isVertical;
    switch (orientation) {
      case AxisDirection.up:
        isVertical = true;
        quarterTurns = 3;
        break;
      case AxisDirection.right:
        isVertical = false;
        quarterTurns = 0;
        break;
      case AxisDirection.down:
        isVertical = true;
        quarterTurns = 1;
        break;
      case AxisDirection.left:
        isVertical = false;
        quarterTurns = 2;
        break;
    }

    final Widget arrow = RotatedBox(
      quarterTurns: quarterTurns,
      child: CustomPaint(
        painter: ArrowPainter(fillColor: fillColor, thickness: thickness),
        child: SizedBox(height: tipSize, width: length),
      ),
    );

    if (isVertical) {
      return Row(
        children: <Widget>[
          if (orientation == AxisDirection.down) label,
          arrow,
          if (orientation == AxisDirection.up) label,
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          if (orientation == AxisDirection.right) label,
          arrow,
          if (orientation == AxisDirection.left) label,
        ],
      );
    }
  }
}

class ArrowPainter extends CustomPainter {
  const ArrowPainter({
    required this.fillColor,
    this.thickness = 10,
    this.orientation = AxisDirection.right,
  });

  final Color fillColor;
  final AxisDirection orientation;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final List<Offset> points = <Offset>[
      Offset(0, center.dy - thickness),
      Offset(size.width - size.height, center.dy - thickness),
      Offset(size.width - size.height, 0),
      Offset(size.width, center.dy),
      Offset(size.width - size.height, size.height),
      Offset(size.width - size.height, center.dy + thickness),
      Offset(0, center.dy + thickness),
    ];

    final Path arrowPath = Path()..addPolygon(points, true);

    canvas.drawPath(arrowPath, Paint()..color = fillColor);

    canvas.drawPath(
      arrowPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = AppLifecycleDiagram.arrowBorderColor,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AppLifecycleDiagramStep extends DiagramStep {
  @override
  final String category = 'dart-ui';

  @override
  Future<List<AppLifecycleDiagram>> get diagrams async {
    return <AppLifecycleDiagram>[
      const AppLifecycleDiagram(name: 'app_lifecycle'),
    ];
  }
}

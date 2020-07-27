// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';
import 'utils.dart';

class HeroesDiagram extends StatefulWidget implements DiagramMetadata {
  const HeroesDiagram();

  @override
  String get name => 'heroes';

  static const Color borderColor = Colors.black;

  @override
  _HeroesDiagramState createState() {
    return _HeroesDiagramState();
  }
}

class _HeroesDiagramState extends State<HeroesDiagram> {
  final GlobalKey fromRoute = GlobalKey();
  final GlobalKey toRoute = GlobalKey();
  final GlobalKey fromHero = GlobalKey();
  final GlobalKey fromPlaceholder = GlobalKey();
  final GlobalKey toHero = GlobalKey();
  final GlobalKey key = GlobalKey();
  final GlobalKey heroKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.white,
        height:480.0,
        width: 900.0,
        child: Stack(
          children: <Widget>[
            Center(
              child: SizedBox(
                width: 500.0,
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      Column(
                        key: heroKey,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            height: 400.0,
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  left: 0.0,
                                  top: 0.0,
                                  bottom: 0.0,
                                  width: 300.0,
                                  child: Material(
                                    key: fromRoute,
                                    color: Colors.grey[400],
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          key: fromHero,
                                          height: 100.0,
                                          width: 100.0,
                                          color: Colors.blue[300],
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                              key: fromPlaceholder,
                                              color: Colors.red[200],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0.0,
                                  top: 0.0,
                                  bottom: 0.0,
                                  width: 300.0,
                                  child: Material(
                                    key: toRoute,
                                    color: Colors.grey[300],
                                    elevation: 20.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Align(
                                        alignment: const Alignment(1.0, -0.5),
                                        child: Container(
                                          key: toHero,
                                          height: 180.0,
                                          width: 180.0,
                                          color: Colors.blue[300],
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Container(
                                              color: Colors.red[200],
                                              child: const Align(
                                                alignment: Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('placeholderBuilder'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CustomPaint(
                              painter: RightArrowPainter(fillColor: Colors.orange),
                              child: SizedBox(
                                height: 60.0,
                                width: 400.0,
                                child: Center(
                                  child: Text(
                                    'Push',
                                    style: TextStyle(fontSize: 24.0),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        left: 60.0,
                        top: 140.0,
                        child: Transform.rotate(
                          angle: -0.2,
                          child: CustomPaint(
                            size: const Size(320.0, 20.0),
                            painter: RightArrowPainter(fillColor: Colors.blue[600]),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 140.0,
                        top: 100.0,
                        height: 140.0,
                        width: 140.0,
                        child: Container(
                          color: Colors.blue[400],
                          child: const Center(
                            child: Text('flightShuttleBuilder'),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: LabelPainterWidget(
                key: key,
                heroKey: heroKey,
                labels: <Label>[
                  Label(
                    fromRoute,
                    '"bottom" route\nor\n"from" route (when pushing)',
                    const FractionalOffset(0.1, 0.95),
                  ),
                  Label(
                    toRoute,
                    '"top" route\nor\n"to" route (when pushing)',
                    const FractionalOffset(0.9, 0.95),
                  ),
                  Label(
                    fromHero,
                    '"from" hero (when pushing)',
                    const FractionalOffset(0.05, 0.95),
                  ),
                  Label(
                    fromPlaceholder,
                    'placeholderBuilder',
                    const FractionalOffset(0.5, 0.6),
                  ),
                  Label(
                    toHero,
                    '"to" hero (when pushing)',
                    const FractionalOffset(0.95, 0.95),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightArrowPainter extends CustomPainter {
  const RightArrowPainter({ this.fillColor });

  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> points = <Offset>[
      const Offset(0.0, 0.0),
      Offset(size.width - size.height / 2.0, 0.0),
      Offset(size.width, size.height / 2.0),
      Offset(size.width - size.height / 2.0, size.height),
      Offset(0.0, size.height),
      Offset(size.height / 2.0, size.height / 2.0),
    ];

    final Path arrowPath = Path()..addPolygon(points, true);

    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = fillColor,
    );

    canvas.drawPath(
      arrowPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = HeroesDiagram.borderColor,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeroesDiagramStep extends DiagramStep<HeroesDiagram> {
  HeroesDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'interaction';

  @override
  Future<List<HeroesDiagram>> get diagrams async => <HeroesDiagram>[const HeroesDiagram()];

  @override
  Future<File> generateDiagram(HeroesDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

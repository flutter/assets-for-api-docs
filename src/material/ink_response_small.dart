// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'lib/utils.dart';

final GlobalKey canvasKey = new GlobalKey();
final GlobalKey childKey = new GlobalKey();
final GlobalKey heroKey = new GlobalKey();
final GlobalKey splashKey = new GlobalKey();

String currentMessage;

void main() {
  runApp(new Diagram());
  new Timer(
    const Duration(milliseconds: 1000),
    () {
      final RenderBox target = splashKey.currentContext.findRenderObject();
      final Offset targetOffset = target.localToGlobal(target.size.bottomRight(Offset.zero)) *
          ui.window.devicePixelRatio;
      ui.window.onPointerDataPacket(new ui.PointerDataPacket(data: <ui.PointerData>[
        new ui.PointerData(
          change: ui.PointerChange.down,
          physicalX: targetOffset.dx,
          physicalY: targetOffset.dy,
        ),
      ]));
    },
  );
  new Timer(
    const Duration(milliseconds: 1700),
    () {
      ui.window.onBeginFrame = ui.window.onDrawFrame = null;
      print(currentMessage);
      print('DONE DRAWING');
    },
  );
}

class Diagram extends StatefulWidget {
  Diagram({ Key key }) : super(key: key);

  @override
  _DiagramState createState() => new _DiagramState();
}

class _DiagramState extends State<Diagram> {
  Labeller _labeller;

  @override
  void initState() {
    super.initState();
    _labeller = new Labeller(
      labels: <Label>[
        new Label(childKey, 'child', const FractionalOffset(0.2, 0.8)),
        new Label(splashKey, 'splash', const FractionalOffset(0.8, 0.6)),
        new Label(heroKey, 'highlight', const FractionalOffset(0.45, 0.25)),
      ],
      heroKey: heroKey,
      canvasKey: canvasKey,
      filename: 'ink_response_small.png',
      onPaintMessage: (String message) {
        currentMessage = message;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Material(
        color: const Color(0xFFFFFFFF),
        child: new Stack(
          children: <Widget>[
            new Center(
              child: new Container(
                key: heroKey,
                width: 150.0,
                height: 100.0,
                alignment: FractionalOffset.center,
                child: new Container(
                  height: 45.0,
                  width: 100.0,
                  child: new InkResponse(
                    onTap: () {},
                    child: new Hole(
                      color: Colors.blue,
                      key: childKey,
                    ),
                  ),
                ),
              ),
            ),
            new Center(
              child: new Container(
                key: splashKey,
                width: 90.0,
                height: 20.0,
              ),
            ),
            new Positioned.fill(
              child: new CustomPaint(
                key: canvasKey,
                painter: _labeller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

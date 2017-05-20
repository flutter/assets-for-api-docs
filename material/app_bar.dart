// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  runApp(new Diagram());
}

class Diagram extends StatefulWidget {
  Diagram({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _DiagramState createState() => new _DiagramState();
}

class _DiagramState extends State<Diagram> {
  final GlobalKey leading = new GlobalKey();
  final GlobalKey actions = new GlobalKey();
  final GlobalKey title = new GlobalKey();
  final GlobalKey flexibleSpace = new GlobalKey();
  final GlobalKey bottom = new GlobalKey();
  final GlobalKey heroKey = new GlobalKey();
  final GlobalKey canvasKey = new GlobalKey();

  Labeller _labeller;

  @override
  void initState() {
    super.initState();
    _labeller = new Labeller(
      <Label>[
        new Label(leading, 'leading', const FractionalOffset(0.5, 0.25)),
        new Label(actions, 'actions', const FractionalOffset(0.25, 0.5)),
        new Label(title, 'title', const FractionalOffset(0.5, 0.5)),
        new Label(flexibleSpace, 'flexibleSpace', const FractionalOffset(0.2, 0.5)),
        new Label(bottom, 'bottom', const FractionalOffset(0.5, 0.75)),
      ],
      heroKey,
      canvasKey,
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
        child: new MediaQuery(
          data: new MediaQueryData(
            padding: new EdgeInsets.all(0.0),
          ),
          child: new Stack(
            children: <Widget>[
              new Center(
                child: new Container(
                  width: 300.0,
                  height: kToolbarHeight * 2.0 + 50.0,
                  child: new AppBar(
                    key: heroKey,
                    leading: new Hole(key: leading),
                    title: new Text('Abc', key: title),
                    actions: <Widget>[
                      new Hole(),
                      new Hole(),
                      new Hole(key: actions),
                    ],
                    flexibleSpace: new DecoratedBox(
                      key: flexibleSpace,
                      decoration: new BoxDecoration(
                        gradient: new LinearGradient(
                          begin: new FractionalOffset(0.50, 0.0),
                          end: new FractionalOffset(0.48, 1.0),
                          colors: [Colors.blue.shade500, Colors.blue.shade800]
                        ),
                      ),
                    ),
                    bottom: new PreferredSize(
                      key: bottom,
                      preferredSize: const Size(0.0, kToolbarHeight),
                      child: new Container(
                        height: 50.0,
                        padding: new EdgeInsets.all(4.0),
                        child: new Placeholder(
                          strokeWidth: 2.0,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
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
      ),
    );
  }
}

class Hole extends StatelessWidget {
  const Hole({ Key key, this.child }) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: 1.0,
      child: new Padding(
        padding: new EdgeInsets.all(4.0),
        child: new Placeholder(
          strokeWidth: 2.0,
          color: const Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}

class Label {
  const Label(this.key, this.text, this.anchor);
  final GlobalKey key;
  final String text;
  final FractionalOffset anchor;
}

class Labeller extends CustomPainter {
  Labeller(this.labels, this.heroKey, this.canvasKey) {
    _painters = <Label, TextPainter>{};
    for (Label label in labels) {
      final TextPainter painter = new TextPainter(text: new TextSpan(text: label.text, style: textStyle));
      painter.layout();
      _painters[label] = painter;
    }
  }

  final List<Label> labels;
  final GlobalKey heroKey;
  final GlobalKey canvasKey;
  Map<Label, TextPainter> _painters;

  static const TextStyle textStyle = const TextStyle(color: const Color(0xFF000000));

  static const double margin = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox hero = heroKey.currentContext.findRenderObject();
    final RenderBox diagram = canvasKey.currentContext.findRenderObject();
    final Paint dotPaint = new Paint();
    final Paint linePaint = new Paint()..strokeWidth = 2.0;
    final Offset heroTopLeft = diagram.globalToLocal(hero.localToGlobal(Offset.zero));
    double leftmost = heroTopLeft.dx;
    double rightmost = heroTopLeft.dx + hero.size.width;
    double topmost = heroTopLeft.dy;
    double bottommost = heroTopLeft.dy + hero.size.height;
    for (Label label in labels) {
      final RenderBox box = label.key.currentContext.findRenderObject();
      final Offset anchor = diagram.globalToLocal(box.localToGlobal(label.anchor.alongSize(box.size)));
      final Offset anchorOnHero = anchor - heroTopLeft;
      final FractionalOffset relativeAnchor = new FractionalOffset.fromOffsetAndSize(anchorOnHero, hero.size);
      final double distanceToTop = anchorOnHero.dy;
      final double distanceToBottom = hero.size.height - anchorOnHero.dy;
      final double distanceToLeft = anchorOnHero.dx;
      final double distanceToRight = hero.size.width - anchorOnHero.dx;
      Offset labelPosition;
      Offset textPosition = Offset.zero;
      final TextPainter painter = _painters[label];
      if (distanceToTop < distanceToLeft && distanceToTop < distanceToRight && distanceToTop < distanceToBottom) {
        labelPosition = new Offset(anchor.dx + (relativeAnchor.dx - 0.5) * margin, heroTopLeft.dy - margin);
        textPosition = new Offset(labelPosition.dx - painter.width / 2.0, labelPosition.dy - painter.height);
      } else if (distanceToBottom < distanceToLeft && distanceToBottom < distanceToRight && distanceToTop > distanceToBottom) {
        labelPosition = new Offset(anchor.dx, heroTopLeft.dy + hero.size.height + margin);
        textPosition = new Offset(labelPosition.dx - painter.width / 2.0, labelPosition.dy);
      } else if (distanceToLeft < distanceToRight) {
        labelPosition = new Offset(heroTopLeft.dx - margin, anchor.dy);
        textPosition = new Offset(labelPosition.dx - painter.width - 2.0, labelPosition.dy - painter.height / 2.0);
      } else if (distanceToLeft < distanceToRight) {
        labelPosition = new Offset(heroTopLeft.dx + hero.size.width + margin, anchor.dy);
        textPosition = new Offset(labelPosition.dx, labelPosition.dy - painter.height / 2.0);
      } else {
        labelPosition = new Offset(anchor.dx - margin, heroTopLeft.dy - margin * 2.0);
      }
      canvas.drawCircle(anchor, 4.0, dotPaint);
      canvas.drawLine(anchor, labelPosition, linePaint);
      painter.paint(canvas, textPosition);
      leftmost = math.min(leftmost, textPosition.dx);
      rightmost = math.max(rightmost, textPosition.dx + painter.width);
      topmost = math.min(topmost, textPosition.dy);
      bottommost = math.max(bottommost, textPosition.dy + painter.height);
    }
    final double center = hero.size.center(heroTopLeft).dx;
    final double horizontalEdge = math.max(center - leftmost, rightmost - center) + margin;
    leftmost = center - horizontalEdge;
    rightmost = center + horizontalEdge;
    topmost -= margin;
    bottommost += margin;
    final Offset topLeft = diagram.localToGlobal(Offset.zero);
    print('The following command extracts the image from a screenshot file.');
    print('You can obtain a screenshot by pressing "s" in the "flutter run" console.');
    print('Make sure the whole diagram is visible (you may need to rotate the device).');
    print('export FILE=flutter_01.png # or whatever the file name is');
    int w = ((rightmost - leftmost) * ui.window.devicePixelRatio).round();
    int h = ((bottommost - topmost) * ui.window.devicePixelRatio).round();
    int x = ((topLeft.dx + leftmost) * ui.window.devicePixelRatio).round();
    int y = ((topLeft.dy + topmost) * ui.window.devicePixelRatio).round();
    print('convert \$FILE -crop ${w}x$h+$x+$y -resize \'450x450>\' app_bar.png');
  }

  @override
  bool shouldRepaint(Labeller oldDelegate) => labels != oldDelegate.labels || canvasKey != oldDelegate.canvasKey;
}

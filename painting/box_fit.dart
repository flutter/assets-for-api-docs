// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  List<Widget> children = <Widget>[];
  for (BoxFit fit in BoxFit.values) {
    final Widget inner = new Container(
      decoration: new BoxDecoration(
        border: new Border.all(width: 2.0, color: Colors.blue[300]),
        color: Colors.blue[100],
      ),
      child: new FittedBox(
        fit: fit,
        child: new Container(
          width: 5.0 * 12.0,
          height: 5.0 * 12.0,
          decoration: new BoxDecoration(
            border: new Border.all(width: 2.0, color: Colors.teal[700]),
            color: Colors.teal[600],
          ),
          child: new GridPaper(
            color: Colors.teal[400],
            divisions: 1,
            interval: 18.5,
            subdivisions: 1,
            child: new Center(
              child: new Text('${fit.toString().split(".").join("\n")}'),
            ),
          ),
        ),
      ),
    );
    children.add(
      new Container(
        width: 300.0,
        height: 90.0,
        child: new Row(
          key: new GlobalObjectKey(fit),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Expanded(
              flex: 180,
              child: new Center(
                child: new AspectRatio(
                  aspectRatio: 2.5,
                  child: inner,
                ),
              ),
            ),
            new SizedBox(width: 10.0),
            new Expanded(
              flex: 80,
              child: inner,
            ),
            new SizedBox(width: 10.0),
            new Expanded(
              flex: 200,
              child: inner,
            ),
          ],
        ),
      ),
    );
  }
  runApp(
    new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Material(
        color: Colors.white,
        child: new DefaultTextStyle(
          style: new TextStyle(fontSize: 8.0, color: Colors.white),
          textAlign: TextAlign.center,
          child: new Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runAlignment: WrapAlignment.end,
            spacing: 10.0,
            runSpacing: 2.0,
            children: children,
          ),
        ),
      ),
    ),
  );
  new Timer(const Duration(seconds: 1), () {
    print('The following commands extract out the ${BoxFit.values.length} images from a screenshot file.');
    print('You can obtain a screenshot by pressing "s" in the "flutter run" console.');
    print('export FILE=flutter_01.png # or whatever the file name is');
    for (BoxFit fit in BoxFit.values) {
      final RenderBox box = new GlobalObjectKey(fit).currentContext.findRenderObject();
      final Rect area = (box.localToGlobal(Offset.zero) * ui.window.devicePixelRatio) & (box.size * ui.window.devicePixelRatio);
      print('convert \$FILE -crop ${area.width}x${area.height}+${area.left}+${area.top} -resize \'300x300>\' box_fit_${fit.toString().split(".")[1]}.png');
    }
  });
}

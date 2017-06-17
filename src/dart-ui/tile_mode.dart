// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui show window;

import 'package:flutter/material.dart';

const double topPadding = 30.0;
const double width = 175.0;
const double height = 200.0;
const double spacing = 8.0;
const double borderSize = 1.0;

void main() {
  runApp(new MyApp());
  new Timer(const Duration(seconds: 1), () {
    print('The following commands extract out the six images from a screenshot file.');
    print('You can obtain a screenshot by pressing "s" in the "flutter run" console.');
    print('BASH: export FILE=flutter_01.png # or whatever the file name is');
    final double w = width * ui.window.devicePixelRatio;
    final double h = (height - spacing * 2.0) * ui.window.devicePixelRatio;
    final double xStride = (width + spacing * 2.0) * ui.window.devicePixelRatio;
    final double yStride = height * ui.window.devicePixelRatio;
    final double left = spacing * ui.window.devicePixelRatio;
    final double top = (topPadding + spacing) * ui.window.devicePixelRatio;
    double x = left;
    double y = top;
    print('BASH: convert \$FILE -crop ${w}x$h+$x+$y -resize \'200x200>\' tile_mode_clamp_linear.png');
    x += xStride;
    print('BASH: convert \$FILE -crop ${w}x$h+$x+$y -resize \'200x200>\' tile_mode_clamp_radial.png');
    x = left;
    y += yStride;
    print('BASH: convert \$FILE -crop ${w}x$h+$x+$y -resize \'200x200>\' tile_mode_repeated_linear.png');
    x += xStride;
    print('BASH: convert \$FILE -crop ${w}x$h+$x+$y -resize \'200x200>\' tile_mode_repeated_radial.png');
    x = left;
    y += yStride;
    print('BASH: convert \$FILE -crop ${w}x$h+$x+$y -resize \'200x200>\' tile_mode_mirror_linear.png');
    x += xStride;
    print('BASH: convert \$FILE -crop ${w}x$h+$x+$y -resize \'200x200>\' tile_mode_mirror_radial.png');
  });
}

class Demo extends StatelessWidget {
  Demo(this.radial, this.tileMode);

  final bool radial;
  final TileMode tileMode;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: new TextStyle(
        color: const Color(0xFF000000),
      ),
      child: new Container(
        margin: new EdgeInsets.all(spacing),
        width: width,
        decoration: new BoxDecoration(
          border: new Border.all(width: borderSize),
          color: const Color(0xFFFFFFFF),
        ),
        child: new Column(
          children: <Widget>[
            new Expanded(
              child: new Container(
                decoration: new BoxDecoration(
                  gradient: radial ? new RadialGradient(
                    center: FractionalOffset.center,
                    radius: 0.2,
                    colors: [const Color(0xFF0000FF), const Color(0xFF00FF00)],
                    stops: [0.0, 1.0],
                    tileMode: tileMode,
                  ) : new LinearGradient(
                    begin: const FractionalOffset(0.4, 0.5),
                    end: const FractionalOffset(0.6, 0.5),
                    colors: [const Color(0xFF0000FF), const Color(0xFF00FF00)],
                    stops: [0.0, 1.0],
                    tileMode: tileMode,
                  ),
                  border: new Border(bottom: new BorderSide(width: 1.0)),
                ),
              ),
            ),
            new Container(height: 3.0),
            new Text('${radial ? "Radial" : "Linear"} Gradient', textAlign: TextAlign.center),
            new Text('$tileMode', textAlign: TextAlign.center),
            new Container(height: 3.0),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: const Color(0xFF00FFFF),
      child: new ListView(
        padding: new EdgeInsets.only(top: topPadding),
        itemExtent: height,
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Demo(false, TileMode.clamp),
              new Demo(true, TileMode.clamp),
            ],
          ),
         new Row(
            children: <Widget>[
              new Demo(false, TileMode.repeated),
              new Demo(true, TileMode.repeated),
            ],
          ),
          new Row(
            children: <Widget>[
              new Demo(false, TileMode.mirror),
              new Demo(true, TileMode.mirror),
            ],
          ),
        ],
      ),
    );
  }
}

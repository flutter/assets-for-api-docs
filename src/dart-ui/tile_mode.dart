// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui show window;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

Completer<Null> touch;
int pageIndex = 0;

const double topPadding = 30.0;
const double width = 350.0;
const double height = 200.0;
const double spacing = 8.0;
const double borderSize = 1.0;

enum GradientMode { linear, radial, sweep }

Future<Null> main() async {
  if (ui.window.defaultRouteName == 'list') {
    for (GradientMode mode in GradientMode.values) {
      print('ROUTE: $mode');
    }
    print('END');
    return;
  }
  new WidgetsFlutterBinding();
  if (ui.window.defaultRouteName != '/') {
    showDemo(GradientMode.values
        .where((GradientMode mode) =>
            mode.toString() == ui.window.defaultRouteName)
        .single);
  } else {
    while (true) {
      print('Tap on the screen to advance to the next gradient mode.');
      for (GradientMode mode in GradientMode.values) {
        await showDemo(mode);
      }
      print('DONE');
    }
  }
}

Future<Null> showDemo(GradientMode mode) async {
  touch = new Completer<Null>();
  runApp(new MaterialApp(home: new Demo(mode)));
  await SchedulerBinding.instance.endOfFrame;

  final double w = (width - spacing) * ui.window.devicePixelRatio;
  final double h = (height - spacing * 2.0) * ui.window.devicePixelRatio;
  final double yStride = height * ui.window.devicePixelRatio;
  final double left = spacing * ui.window.devicePixelRatio;
  final double top = (topPadding + spacing) * ui.window.devicePixelRatio;
  final double x = left;
  double y = top;
  print(
      'COMMAND: convert flutter_${(pageIndex + 1).toString().padLeft(2, "0")}.png '
      "-crop ${w}x$h+$x+$y -resize '400x200>' tile_mode_clamp_${describeEnum(mode)}.png");
  y += yStride;
  print(
      'COMMAND: convert flutter_${(pageIndex + 1).toString().padLeft(2, "0")}.png '
      "-crop ${w}x$h+$x+$y -resize '400x200>' tile_mode_repeated_${describeEnum(mode)}.png");
  y += yStride;
  print(
      'COMMAND: convert flutter_${(pageIndex + 1).toString().padLeft(2, "0")}.png '
      "-crop ${w}x$h+$x+$y -resize '400x200>' tile_mode_mirror_${describeEnum(mode)}.png");
  print('DONE DRAWING');
  pageIndex += 1;
  await touch.future;
}

class DemoItem extends StatelessWidget {
  const DemoItem(this.gradientMode, this.tileMode);

  final GradientMode gradientMode;
  final TileMode tileMode;

  Gradient _buildGradient() {
    Gradient gradient;
    switch (gradientMode) {
      case GradientMode.linear:
        gradient = new LinearGradient(
          begin: const FractionalOffset(0.4, 0.5),
          end: const FractionalOffset(0.6, 0.5),
          colors: const <Color>[
            const Color(0xFF0000FF),
            const Color(0xFF00FF00)
          ],
          stops: const <double>[0.0, 1.0],
          tileMode: tileMode,
        );
        break;
      case GradientMode.radial:
        gradient = new RadialGradient(
          center: FractionalOffset.center,
          radius: 0.2,
          colors: const <Color>[
            const Color(0xFF0000FF),
            const Color(0xFF00FF00)
          ],
          stops: const <double>[0.0, 1.0],
          tileMode: tileMode,
        );
        break;
      case GradientMode.sweep:
        gradient = new SweepGradient(
          center: FractionalOffset.center,
          startAngle: 0.0,
          endAngle: math.pi / 2,
          colors: const <Color>[
            const Color(0xFF0000FF),
            const Color(0xFF00FF00)
          ],
          stops: const <double>[0.0, 1.0],
          tileMode: tileMode,
        );
        break;
    }
    return gradient;
  }

  String _getGradientName(GradientMode mode) {
    final String s = describeEnum(gradientMode);
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: const TextStyle(
        fontSize: 10.0,
        color: const Color(0xFF000000),
      ),
      child: new Directionality(
        textDirection: TextDirection.ltr,
        child: new Container(
          margin: const EdgeInsets.all(spacing),
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
                    gradient: _buildGradient(),
                    border: const Border(bottom: const BorderSide(width: 1.0)),
                  ),
                ),
              ),
              new Container(height: 3.0),
              new Text(
                '${_getGradientName(gradientMode)} Gradient',
                textAlign: TextAlign.center,
              ),
              new Text('$tileMode', textAlign: TextAlign.center),
              new Container(height: 3.0),
            ],
          ),
        ),
      ),
    );
  }
}

class Demo extends StatelessWidget {
  const Demo(this.mode);

  final GradientMode mode;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        touch.complete();
      },
      child: new Material(
        child: new Directionality(
          textDirection: TextDirection.ltr,
          child: new Container(
            color: const Color(0xFF00FFFF),
            child: new ListView(
              padding: const EdgeInsets.only(top: topPadding),
              itemExtent: height,
              children: <Widget>[
                new DemoItem(mode, TileMode.clamp),
                new DemoItem(mode, TileMode.repeated),
                new DemoItem(mode, TileMode.mirror),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

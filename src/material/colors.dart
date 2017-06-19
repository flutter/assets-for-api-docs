// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

abstract class Page {
  const Page();
  String get filename;
  Widget build(BuildContext context);

  GlobalKey get key => new GlobalObjectKey(this);

  Widget buildSwatch(BuildContext context, Widget child) {
    return new GestureDetector(
        onTap: () async {
          await SchedulerBinding.instance.endOfFrame;
          final Rect area = interestingArea;
          print('BASH: convert flutter_`printf %02d \$N`.png -crop '
              '${area.width}x${area.height}+${area.left}+${area.top} -resize '
              '\'400x600>\' ${filename}.png; ((N++))');
          Navigator.of(context).pop();
        },
        child: child);
  }

  Rect get interestingArea {
    final RenderBox box = key.currentContext.findRenderObject();
    final Rect area =
        ((box.localToGlobal(Offset.zero) * ui.window.devicePixelRatio) &
            (box.size * ui.window.devicePixelRatio));
    return area;
  }
}

class SwatchPage extends Page {
  const SwatchPage(this.name, this.swatch, this.keys);
  final String name;
  final ColorSwatch<int> swatch;
  final List<int> keys;

  @override
  String get filename => name;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = <Widget>[];
    for (int key in keys) {
      Color textColor =
          ThemeData.estimateBrightnessForColor(swatch[key]) == Brightness.light
              ? Colors.black
              : Colors.white;
      TextStyle style = new TextStyle(color: textColor);
      String label;
      if (swatch[key].value == swatch.value) {
        label = name;
        style = style.copyWith(fontWeight: FontWeight.w800);
      } else {
        label = '$name[$key]';
      }
      items.add(new Container(
        color: swatch[key],
        padding: new EdgeInsets.all(8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(label, style: style),
            new Text('0x${swatch[key].value.toRadixString(16).toUpperCase()}',
                style: style),
          ],
        ),
      ));
    }
    return buildSwatch(
        context,
        new Material(
          color: Colors.white,
          child: new Center(
            child: new Container(
              key: key,
              width: 300.0,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: items,
              ),
            ),
          ),
        ));
  }
}

class ColorListPage extends Page {
  const ColorListPage(this.filename, this.background, this.colors);

  @override
  final String filename;

  final Color background;

  final Map<String, Color> colors;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = <Widget>[];
    for (String key in colors.keys) {
      Color textColor = colors[key];
      TextStyle style = new TextStyle(color: textColor);
      items.add(new Container(
        padding: new EdgeInsets.all(8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(key, style: style),
            new Text('0x${textColor.value.toRadixString(16).toUpperCase()}',
                style: style),
          ],
        ),
      ));
    }
    return buildSwatch(
        context,
        new Material(
          color: Colors.white,
          child: new Center(
            child: new Container(
              key: key,
              width: 300.0,
              color: background,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: items,
              ),
            ),
          ),
        ));
  }
}

class HomePage extends StatelessWidget {
  final List<Page> pages;

  HomePage(this.pages);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () async {
        for (var page in pages.reversed) {
          Navigator.of(context).pushNamed('/' + page.filename);
        }
      },
      child: new Material(
        color: Colors.white,
        child: new Center(
            child: new Text("Tap to advance to the color swatches.")),
      ),
    );
  }
}

Future<Null> main() async {
  const List<int> palette = const <int>[
    50,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900
  ];
  const List<int> accentPalette = const <int>[100, 200, 400, 700];
  const List<int> greyPalette = const <int>[
    50,
    100,
    200,
    300,
    350,
    400,
    500,
    600,
    700,
    800,
    850,
    900
  ];
  final List<Page> pages = <Page>[
    const SwatchPage('Colors.red', Colors.red, palette),
    const SwatchPage('Colors.pink', Colors.pink, palette),
    const SwatchPage('Colors.purple', Colors.purple, palette),
    const SwatchPage('Colors.deepPurple', Colors.deepPurple, palette),
    const SwatchPage('Colors.indigo', Colors.indigo, palette),
    const SwatchPage('Colors.blue', Colors.blue, palette),
    const SwatchPage('Colors.lightBlue', Colors.lightBlue, palette),
    const SwatchPage('Colors.cyan', Colors.cyan, palette),
    const SwatchPage('Colors.teal', Colors.teal, palette),
    const SwatchPage('Colors.green', Colors.green, palette),
    const SwatchPage('Colors.lightGreen', Colors.lightGreen, palette),
    const SwatchPage('Colors.lime', Colors.lime, palette),
    const SwatchPage('Colors.yellow', Colors.yellow, palette),
    const SwatchPage('Colors.amber', Colors.amber, palette),
    const SwatchPage('Colors.orange', Colors.orange, palette),
    const SwatchPage('Colors.deepOrange', Colors.deepOrange, palette),
    const SwatchPage('Colors.brown', Colors.brown, palette),
    const SwatchPage('Colors.blueGrey', Colors.blueGrey, palette),
    const SwatchPage('Colors.redAccent', Colors.redAccent, accentPalette),
    const SwatchPage('Colors.pinkAccent', Colors.pinkAccent, accentPalette),
    const SwatchPage('Colors.purpleAccent', Colors.purpleAccent, accentPalette),
    const SwatchPage(
        'Colors.deepPurpleAccent', Colors.deepPurpleAccent, accentPalette),
    const SwatchPage('Colors.indigoAccent', Colors.indigoAccent, accentPalette),
    const SwatchPage('Colors.blueAccent', Colors.blueAccent, accentPalette),
    const SwatchPage(
        'Colors.lightBlueAccent', Colors.lightBlueAccent, accentPalette),
    const SwatchPage('Colors.cyanAccent', Colors.cyanAccent, accentPalette),
    const SwatchPage('Colors.tealAccent', Colors.tealAccent, accentPalette),
    const SwatchPage('Colors.greenAccent', Colors.greenAccent, accentPalette),
    const SwatchPage(
        'Colors.lightGreenAccent', Colors.lightGreenAccent, accentPalette),
    const SwatchPage('Colors.limeAccent', Colors.limeAccent, accentPalette),
    const SwatchPage('Colors.yellowAccent', Colors.yellowAccent, accentPalette),
    const SwatchPage('Colors.amberAccent', Colors.amberAccent, accentPalette),
    const SwatchPage('Colors.orangeAccent', Colors.orangeAccent, accentPalette),
    const SwatchPage(
        'Colors.deepOrangeAccent', Colors.deepOrangeAccent, accentPalette),
    const SwatchPage('Colors.grey', Colors.grey, greyPalette),
    const ColorListPage('Colors.blacks', Colors.white, const <String, Color>{
      'black': Colors.black,
      'black12': Colors.black12,
      'black26': Colors.black26,
      'black38': Colors.black38,
      'black45': Colors.black45,
      'black54': Colors.black54,
      'black87': Colors.black87,
    }),
    const ColorListPage('Colors.whites', Colors.black, const <String, Color>{
      'white': Colors.white,
      'white10': Colors.white10,
      'white12': Colors.white12,
      'white30': Colors.white30,
      'white70': Colors.white70,
    }),
  ];
  print('This app will display a sequence of images. For each one, tap "s"');
  print('in the console to take a screenshot, then tap the screen to');
  print('advance. When all is done, a script will be dumped that shows the');
  print('commands to run to convert all the screenshots to images.');
  print('BASH: N=1 # set this to the number of the first screenshot file');
  Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{};
  for (Page page in pages) {
    routes['/' + page.filename] = page.build;
    print('COLOR: ${page.filename}');
  }
  runApp(new MaterialApp(onGenerateRoute: (RouteSettings settings) {
    if (settings.isInitialRoute &&
        settings.name == Navigator.defaultRouteName) {
      return new MaterialPageRoute<Null>(
        builder: (BuildContext context) {
          return new HomePage(pages);
        },
        settings: settings,
      );
    } else {
      return new MaterialPageRoute<Null>(
        builder: routes[settings.name],
        settings: settings,
      );
    }
  }));
}

// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

abstract class Page {
  /// The name of the page.  Used for constructing output filenames in commands.
  String get name;

  ///  The build function to use for this [Page].
  Widget build(BuildContext context);

  /// The index of the page currently displayed.
  static int pageIndex = 0;

  /// The list of pages that we can display.
  static List<Page> pages = [];

  /// Used to decide to print the cropping command or not.  We only
  /// print it the first time the page has been painted.
  bool printedCommand = false;

  GlobalKey get key => new GlobalObjectKey(this);

  Widget buildSwatch(BuildContext context, Widget child) {
    SchedulerBinding.instance.endOfFrame.then((_) {
      if (!printedCommand) {
        printedCommand = true;
        final Rect area = interestingArea;
        print('COMMAND: convert flutter_${(pageIndex + 1).toString().padLeft(
            2, '0')}.png -crop '
            '${area.width}x${area.height}+${area.left}+${area.top} -resize '
            '\'400x600>\' ${name}.png');
      }
    });
    return new GestureDetector(
        onTap: () async {
          Page.pageIndex++;
          Navigator.of(context).pop();
          if (Page.pageIndex < Page.pages.length) {
            Navigator.of(context).pushNamed(Page.pages[Page.pageIndex].name);
          } else {
            Navigator.of(context).pushNamed(Navigator.defaultRouteName);
          }
        },
        child: child);
  }

  Rect get interestingArea {
    final RenderBox box = key.currentContext.findRenderObject();
    final Rect area = ((box.localToGlobal(Offset.zero) * ui.window.devicePixelRatio) &
        (box.size * ui.window.devicePixelRatio));
    return area;
  }
}

class SwatchPage extends Page {
  SwatchPage(this.name, this.swatch, this.keys);

  final String name;
  final ColorSwatch<int> swatch;
  final List<int> keys;

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
      ),
    );
  }
}

class ColorListPage extends Page {
  ColorListPage(this.name, this.background, this.colors);

  @override
  final String name;
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
      ),
    );
  }
}

Future<Null> main() async {
  const List<int> palette = const [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
  const List<int> accentPalette = const [100, 200, 400, 700];
  const List<int> greyPalette = const [
    50, 100, 200, 300, 350, 400, 500, 600, 700, 800, 850, 900
  ];
  final List<Page> pages = <Page>[
    new SwatchPage('Colors.red', Colors.red, palette),
    new SwatchPage('Colors.pink', Colors.pink, palette),
    new SwatchPage('Colors.purple', Colors.purple, palette),
    new SwatchPage('Colors.deepPurple', Colors.deepPurple, palette),
    new SwatchPage('Colors.indigo', Colors.indigo, palette),
    new SwatchPage('Colors.blue', Colors.blue, palette),
    new SwatchPage('Colors.lightBlue', Colors.lightBlue, palette),
    new SwatchPage('Colors.cyan', Colors.cyan, palette),
    new SwatchPage('Colors.teal', Colors.teal, palette),
    new SwatchPage('Colors.green', Colors.green, palette),
    new SwatchPage('Colors.lightGreen', Colors.lightGreen, palette),
    new SwatchPage('Colors.lime', Colors.lime, palette),
    new SwatchPage('Colors.yellow', Colors.yellow, palette),
    new SwatchPage('Colors.amber', Colors.amber, palette),
    new SwatchPage('Colors.orange', Colors.orange, palette),
    new SwatchPage('Colors.deepOrange', Colors.deepOrange, palette),
    new SwatchPage('Colors.brown', Colors.brown, palette),
    new SwatchPage('Colors.blueGrey', Colors.blueGrey, palette),
    new SwatchPage('Colors.redAccent', Colors.redAccent, accentPalette),
    new SwatchPage('Colors.pinkAccent', Colors.pinkAccent, accentPalette),
    new SwatchPage('Colors.purpleAccent', Colors.purpleAccent, accentPalette),
    new SwatchPage('Colors.deepPurpleAccent', Colors.deepPurpleAccent, accentPalette),
    new SwatchPage('Colors.indigoAccent', Colors.indigoAccent, accentPalette),
    new SwatchPage('Colors.blueAccent', Colors.blueAccent, accentPalette),
    new SwatchPage('Colors.lightBlueAccent', Colors.lightBlueAccent, accentPalette),
    new SwatchPage('Colors.cyanAccent', Colors.cyanAccent, accentPalette),
    new SwatchPage('Colors.tealAccent', Colors.tealAccent, accentPalette),
    new SwatchPage('Colors.greenAccent', Colors.greenAccent, accentPalette),
    new SwatchPage('Colors.lightGreenAccent', Colors.lightGreenAccent, accentPalette),
    new SwatchPage('Colors.limeAccent', Colors.limeAccent, accentPalette),
    new SwatchPage('Colors.yellowAccent', Colors.yellowAccent, accentPalette),
    new SwatchPage('Colors.amberAccent', Colors.amberAccent, accentPalette),
    new SwatchPage('Colors.orangeAccent', Colors.orangeAccent, accentPalette),
    new SwatchPage('Colors.deepOrangeAccent', Colors.deepOrangeAccent, accentPalette),
    new SwatchPage('Colors.grey', Colors.grey, greyPalette),
    new ColorListPage('Colors.blacks', Colors.white, <String, Color>{
      'black': Colors.black,
      'black12': Colors.black12,
      'black26': Colors.black26,
      'black38': Colors.black38,
      'black45': Colors.black45,
      'black54': Colors.black54,
      'black87': Colors.black87,
    }),
    new ColorListPage('Colors.whites', Colors.black, <String, Color>{
      'white': Colors.white,
      'white10': Colors.white10,
      'white12': Colors.white12,
      'white30': Colors.white30,
      'white70': Colors.white70,
    }),
  ];

  print('This app will display a sequence of images. For each one, tap "s"');
  print('in the console to take a screenshot, then tap the screen to');
  print('advance. When all is done, the lines beginning with "COMMAND:" form a');
  print('script that has the commands to run to convert all the screenshots');
  print('to cropped images.');
  Map<String, WidgetBuilder> routes = {};
  for (Page page in pages) {
    routes[page.name] = page.build;
  }
  Page.pageIndex = 0;
  Page.pages = pages;
  runApp(new MaterialApp(
    onGenerateRoute: (RouteSettings settings) {
      if (settings.name == Navigator.defaultRouteName) {
        return new MaterialPageRoute(
          builder: (BuildContext context) => new GestureDetector(
                onTap: () {
                  Page.pageIndex = 0;
                  Navigator.of(context).pushNamed(pages[0].name);
                },
                child: new Scaffold(
                  body: new Center(
                    child: new Text("Tap to proceed", textScaleFactor: 2.0),
                  ),
                ),
              ),
        );
      }
      return new MaterialPageRoute<Null>(
        builder: routes[settings.name],
        settings: settings,
      );
    },
  ));
  new Timer(const Duration(seconds: 1), () {
    // Tells the generate script to capture a screen shot.
    print('DONE DRAWING');
  });
}

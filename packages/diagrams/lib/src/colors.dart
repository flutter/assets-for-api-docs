// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';

const double _kSwatchWidth = 400.0;
const double _kFontSize = 19.0;
const double _kPadding = 10.0;

abstract class ColorDiagram extends StatelessWidget implements DiagramMetadata {
  @override
  String get name;
}

class ColorSwatchDiagram extends ColorDiagram {
  ColorSwatchDiagram(this.name, this.swatch, this.keys);

  @override
  final String name;
  final ColorSwatch<int> swatch;
  final List<int> keys;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];
    for (int key in keys) {
      final Color textColor = ThemeData.estimateBrightnessForColor(swatch[key]) == Brightness.light ? Colors.black : Colors.white;
      TextStyle style = new TextStyle(color: textColor, fontSize: _kFontSize);
      String label;
      if (swatch[key].value == swatch.value) {
        label = name;
        style = style.copyWith(fontWeight: FontWeight.w800);
      } else {
        label = '$name[$key]';
      }
      items.add(new Container(
        color: swatch[key],
        padding: const EdgeInsets.all(_kPadding),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(label, style: style),
            new Text('0x${swatch[key].value.toRadixString(16).toUpperCase()}', style: style),
          ],
        ),
      ));
    }
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: const BoxConstraints(minWidth: _kSwatchWidth, maxWidth: _kSwatchWidth),
      child: new Material(
        color: Colors.white,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
    );
  }
}

class ColorListDiagram extends ColorDiagram {
  ColorListDiagram(this.name, this.background, this.colors);

  @override
  final String name;
  final Color background;
  final Map<String, Color> colors;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];
    for (String key in colors.keys) {
      final Color textColor = colors[key];
      final TextStyle style = new TextStyle(color: textColor, fontSize: _kFontSize);
      items.add(new Container(
        padding: const EdgeInsets.all(_kPadding),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text(key, style: style),
            new Text('0x${textColor.value.toRadixString(16).toUpperCase()}', style: style),
          ],
        ),
      ));
    }
    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: const BoxConstraints(minWidth: _kSwatchWidth, maxWidth: _kSwatchWidth),
      child: new Material(
        color: Colors.white,
        child: new Container(
          color: background,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: items,
          ),
        ),
      ),
    );
  }
}

class ColorsDiagramStep extends DiagramStep<ColorDiagram> {
  ColorsDiagramStep(DiagramController controller) : super(controller) {
    const List<int> palette = <int>[50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
    const List<int> accentPalette = <int>[100, 200, 400, 700];
    const List<int> greyPalette = <int>[50, 100, 200, 300, 350, 400, 500, 600, 700, 800, 850, 900];
    _diagrams.addAll(<ColorDiagram>[
      new ColorSwatchDiagram('Colors.red', Colors.red, palette),
      new ColorSwatchDiagram('Colors.pink', Colors.pink, palette),
      new ColorSwatchDiagram('Colors.purple', Colors.purple, palette),
      new ColorSwatchDiagram('Colors.deepPurple', Colors.deepPurple, palette),
      new ColorSwatchDiagram('Colors.indigo', Colors.indigo, palette),
      new ColorSwatchDiagram('Colors.blue', Colors.blue, palette),
      new ColorSwatchDiagram('Colors.lightBlue', Colors.lightBlue, palette),
      new ColorSwatchDiagram('Colors.cyan', Colors.cyan, palette),
      new ColorSwatchDiagram('Colors.teal', Colors.teal, palette),
      new ColorSwatchDiagram('Colors.green', Colors.green, palette),
      new ColorSwatchDiagram('Colors.lightGreen', Colors.lightGreen, palette),
      new ColorSwatchDiagram('Colors.lime', Colors.lime, palette),
      new ColorSwatchDiagram('Colors.yellow', Colors.yellow, palette),
      new ColorSwatchDiagram('Colors.amber', Colors.amber, palette),
      new ColorSwatchDiagram('Colors.orange', Colors.orange, palette),
      new ColorSwatchDiagram('Colors.deepOrange', Colors.deepOrange, palette),
      new ColorSwatchDiagram('Colors.brown', Colors.brown, palette),
      new ColorSwatchDiagram('Colors.blueGrey', Colors.blueGrey, palette),
      new ColorSwatchDiagram('Colors.redAccent', Colors.redAccent, accentPalette),
      new ColorSwatchDiagram('Colors.pinkAccent', Colors.pinkAccent, accentPalette),
      new ColorSwatchDiagram('Colors.purpleAccent', Colors.purpleAccent, accentPalette),
      new ColorSwatchDiagram('Colors.deepPurpleAccent', Colors.deepPurpleAccent, accentPalette),
      new ColorSwatchDiagram('Colors.indigoAccent', Colors.indigoAccent, accentPalette),
      new ColorSwatchDiagram('Colors.blueAccent', Colors.blueAccent, accentPalette),
      new ColorSwatchDiagram('Colors.lightBlueAccent', Colors.lightBlueAccent, accentPalette),
      new ColorSwatchDiagram('Colors.cyanAccent', Colors.cyanAccent, accentPalette),
      new ColorSwatchDiagram('Colors.tealAccent', Colors.tealAccent, accentPalette),
      new ColorSwatchDiagram('Colors.greenAccent', Colors.greenAccent, accentPalette),
      new ColorSwatchDiagram('Colors.lightGreenAccent', Colors.lightGreenAccent, accentPalette),
      new ColorSwatchDiagram('Colors.limeAccent', Colors.limeAccent, accentPalette),
      new ColorSwatchDiagram('Colors.yellowAccent', Colors.yellowAccent, accentPalette),
      new ColorSwatchDiagram('Colors.amberAccent', Colors.amberAccent, accentPalette),
      new ColorSwatchDiagram('Colors.orangeAccent', Colors.orangeAccent, accentPalette),
      new ColorSwatchDiagram('Colors.deepOrangeAccent', Colors.deepOrangeAccent, accentPalette),
      new ColorSwatchDiagram('Colors.grey', Colors.grey, greyPalette),
      new ColorListDiagram('Colors.blacks', Colors.white, const <String, Color>{
        'black': Colors.black,
        'black12': Colors.black12,
        'black26': Colors.black26,
        'black38': Colors.black38,
        'black45': Colors.black45,
        'black54': Colors.black54,
        'black87': Colors.black87,
      }),
      new ColorListDiagram('Colors.whites', Colors.black, const <String, Color>{
        'white': Colors.white,
        'white10': Colors.white10,
        'white12': Colors.white12,
        'white24': Colors.white24,
        'white30': Colors.white30,
        'white38': Colors.white38,
        'white54': Colors.white54,
        'white60': Colors.white60,
        'white70': Colors.white70,
      }),
    ]);
  }

  @override
  final String category = 'material';

  final List<ColorDiagram> _diagrams = <ColorDiagram>[];

  @override
  Future<List<ColorDiagram>> get diagrams async => _diagrams;

  @override
  Future<File> generateDiagram(ColorDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';

const double _kSwatchWidth = 450.0;
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
    for (final int key in keys) {
      final Color textColor = ThemeData.estimateBrightnessForColor(swatch[key]!) == Brightness.light ? Colors.black : Colors.white;
      TextStyle style = TextStyle(color: textColor, fontSize: _kFontSize);
      String label, shadeLabel;
      if (swatch[key]!.value == swatch.value) {
        label = name;
        shadeLabel = '';
        style = style.copyWith(fontWeight: FontWeight.w800);
      } else {
        label = '$name[$key]';
        shadeLabel = '$name.shade$key';
      }
      items.add(Container(
        color: swatch[key],
        padding: const EdgeInsets.all(_kPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: style),
                if (shadeLabel != '') Text(shadeLabel, style: style)
              ],
            ),
            Text('0x${swatch[key]!.value.toRadixString(16).toUpperCase()}', style: style),
          ],
        ),
      ));
    }
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: const BoxConstraints(minWidth: _kSwatchWidth, maxWidth: _kSwatchWidth),
      child: Material(
        color: Colors.white,
        child: Column(
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
    for (final String key in colors.keys) {
      final Color textColor = colors[key]!;
      final TextStyle style = TextStyle(color: textColor, fontSize: _kFontSize);
      items.add(Container(
        padding: const EdgeInsets.all(_kPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(key, style: style),
            Text('0x${textColor.value.toRadixString(16).toUpperCase()}', style: style),
          ],
        ),
      ));
    }
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: const BoxConstraints(minWidth: _kSwatchWidth, maxWidth: _kSwatchWidth),
      child: Material(
        color: Colors.white,
        child: Container(
          color: background,
          child: Column(
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
      ColorSwatchDiagram('Colors.red', Colors.red, palette),
      ColorSwatchDiagram('Colors.pink', Colors.pink, palette),
      ColorSwatchDiagram('Colors.purple', Colors.purple, palette),
      ColorSwatchDiagram('Colors.deepPurple', Colors.deepPurple, palette),
      ColorSwatchDiagram('Colors.indigo', Colors.indigo, palette),
      ColorSwatchDiagram('Colors.blue', Colors.blue, palette),
      ColorSwatchDiagram('Colors.lightBlue', Colors.lightBlue, palette),
      ColorSwatchDiagram('Colors.cyan', Colors.cyan, palette),
      ColorSwatchDiagram('Colors.teal', Colors.teal, palette),
      ColorSwatchDiagram('Colors.green', Colors.green, palette),
      ColorSwatchDiagram('Colors.lightGreen', Colors.lightGreen, palette),
      ColorSwatchDiagram('Colors.lime', Colors.lime, palette),
      ColorSwatchDiagram('Colors.yellow', Colors.yellow, palette),
      ColorSwatchDiagram('Colors.amber', Colors.amber, palette),
      ColorSwatchDiagram('Colors.orange', Colors.orange, palette),
      ColorSwatchDiagram('Colors.deepOrange', Colors.deepOrange, palette),
      ColorSwatchDiagram('Colors.brown', Colors.brown, palette),
      ColorSwatchDiagram('Colors.blueGrey', Colors.blueGrey, palette),
      ColorSwatchDiagram('Colors.redAccent', Colors.redAccent, accentPalette),
      ColorSwatchDiagram('Colors.pinkAccent', Colors.pinkAccent, accentPalette),
      ColorSwatchDiagram('Colors.purpleAccent', Colors.purpleAccent, accentPalette),
      ColorSwatchDiagram('Colors.deepPurpleAccent', Colors.deepPurpleAccent, accentPalette),
      ColorSwatchDiagram('Colors.indigoAccent', Colors.indigoAccent, accentPalette),
      ColorSwatchDiagram('Colors.blueAccent', Colors.blueAccent, accentPalette),
      ColorSwatchDiagram('Colors.lightBlueAccent', Colors.lightBlueAccent, accentPalette),
      ColorSwatchDiagram('Colors.cyanAccent', Colors.cyanAccent, accentPalette),
      ColorSwatchDiagram('Colors.tealAccent', Colors.tealAccent, accentPalette),
      ColorSwatchDiagram('Colors.greenAccent', Colors.greenAccent, accentPalette),
      ColorSwatchDiagram('Colors.lightGreenAccent', Colors.lightGreenAccent, accentPalette),
      ColorSwatchDiagram('Colors.limeAccent', Colors.limeAccent, accentPalette),
      ColorSwatchDiagram('Colors.yellowAccent', Colors.yellowAccent, accentPalette),
      ColorSwatchDiagram('Colors.amberAccent', Colors.amberAccent, accentPalette),
      ColorSwatchDiagram('Colors.orangeAccent', Colors.orangeAccent, accentPalette),
      ColorSwatchDiagram('Colors.deepOrangeAccent', Colors.deepOrangeAccent, accentPalette),
      ColorSwatchDiagram('Colors.grey', Colors.grey, greyPalette),
      ColorListDiagram('Colors.blacks', Colors.white, const <String, Color>{
        'black': Colors.black,
        'black12': Colors.black12,
        'black26': Colors.black26,
        'black38': Colors.black38,
        'black45': Colors.black45,
        'black54': Colors.black54,
        'black87': Colors.black87,
      }),
      ColorListDiagram('Colors.whites', Colors.black, const <String, Color>{
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
    return await controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const double _kSwatchWidth = 460.0;
const double _kFontSize = 18.0;
const double _kPadding = 10.0;

abstract class ColorDiagram extends StatelessWidget with DiagramMetadata {
  const ColorDiagram({super.key});

  @override
  String get name;
}

class ColorSwatchDiagram extends ColorDiagram {
  const ColorSwatchDiagram(this.name, this.swatch, this.keys, {super.key});

  @override
  final String name;
  final ColorSwatch<int> swatch;
  final List<int> keys;

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = <Widget>[];
    for (final int key in keys) {
      final Color textColor =
          ThemeData.estimateBrightnessForColor(swatch[key]!) == Brightness.light
              ? Colors.black
              : Colors.white;
      TextStyle style = TextStyle(color: textColor, fontSize: _kFontSize);
      String label, shadeLabel;
      if (swatch[key]!.toARGB32() == swatch.toARGB32()) {
        label = name;
        shadeLabel = '';
        style = style.copyWith(fontWeight: FontWeight.w800);
      } else {
        label = '$name[$key]';
        shadeLabel = '$name.shade$key';
      }
      items.add(
        Container(
          color: swatch[key],
          padding: const EdgeInsets.all(_kPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: style),
                  if (shadeLabel != '') Text(shadeLabel, style: style),
                ],
              ),
              Text(
                '0x${swatch[key]!.toARGB32().toRadixString(16).toUpperCase()}',
                style: style,
              ),
            ],
          ),
        ),
      );
    }
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: const BoxConstraints(
        minWidth: _kSwatchWidth,
        maxWidth: _kSwatchWidth,
      ),
      child: Material(
        color: Colors.white,
        child: Column(mainAxisSize: MainAxisSize.min, children: items),
      ),
    );
  }
}

class ColorListDiagram extends ColorDiagram {
  const ColorListDiagram(this.name, this.background, this.colors, {super.key});

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
      items.add(
        Container(
          padding: const EdgeInsets.all(_kPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(key, style: style),
              Text(
                '0x${textColor.toARGB32().toRadixString(16).toUpperCase()}',
                style: style,
              ),
            ],
          ),
        ),
      );
    }
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: const BoxConstraints(
        minWidth: _kSwatchWidth,
        maxWidth: _kSwatchWidth,
      ),
      child: Material(
        color: Colors.white,
        child: Container(
          color: background,
          child: Column(mainAxisSize: MainAxisSize.min, children: items),
        ),
      ),
    );
  }
}

class ColorsDiagramStep extends DiagramStep {
  static const List<int> palette = <int>[
    50,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
  ];
  static const List<int> accentPalette = <int>[100, 200, 400, 700];
  static const List<int> greyPalette = <int>[
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
    900,
  ];

  @override
  final String category = 'material';

  final List<ColorDiagram> _diagrams = <ColorDiagram>[
    const ColorSwatchDiagram('Colors.red', Colors.red, palette),
    const ColorSwatchDiagram('Colors.pink', Colors.pink, palette),
    const ColorSwatchDiagram('Colors.purple', Colors.purple, palette),
    const ColorSwatchDiagram('Colors.deepPurple', Colors.deepPurple, palette),
    const ColorSwatchDiagram('Colors.indigo', Colors.indigo, palette),
    const ColorSwatchDiagram('Colors.blue', Colors.blue, palette),
    const ColorSwatchDiagram('Colors.lightBlue', Colors.lightBlue, palette),
    const ColorSwatchDiagram('Colors.cyan', Colors.cyan, palette),
    const ColorSwatchDiagram('Colors.teal', Colors.teal, palette),
    const ColorSwatchDiagram('Colors.green', Colors.green, palette),
    const ColorSwatchDiagram('Colors.lightGreen', Colors.lightGreen, palette),
    const ColorSwatchDiagram('Colors.lime', Colors.lime, palette),
    const ColorSwatchDiagram('Colors.yellow', Colors.yellow, palette),
    const ColorSwatchDiagram('Colors.amber', Colors.amber, palette),
    const ColorSwatchDiagram('Colors.orange', Colors.orange, palette),
    const ColorSwatchDiagram('Colors.deepOrange', Colors.deepOrange, palette),
    const ColorSwatchDiagram('Colors.brown', Colors.brown, palette),
    const ColorSwatchDiagram('Colors.blueGrey', Colors.blueGrey, palette),
    const ColorSwatchDiagram(
      'Colors.redAccent',
      Colors.redAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.pinkAccent',
      Colors.pinkAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.purpleAccent',
      Colors.purpleAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.deepPurpleAccent',
      Colors.deepPurpleAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.indigoAccent',
      Colors.indigoAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.blueAccent',
      Colors.blueAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.lightBlueAccent',
      Colors.lightBlueAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.cyanAccent',
      Colors.cyanAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.tealAccent',
      Colors.tealAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.greenAccent',
      Colors.greenAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.lightGreenAccent',
      Colors.lightGreenAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.limeAccent',
      Colors.limeAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.yellowAccent',
      Colors.yellowAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.amberAccent',
      Colors.amberAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.orangeAccent',
      Colors.orangeAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram(
      'Colors.deepOrangeAccent',
      Colors.deepOrangeAccent,
      accentPalette,
    ),
    const ColorSwatchDiagram('Colors.grey', Colors.grey, greyPalette),
    const ColorListDiagram('Colors.blacks', Colors.white, <String, Color>{
      'black': Colors.black,
      'black12': Colors.black12,
      'black26': Colors.black26,
      'black38': Colors.black38,
      'black45': Colors.black45,
      'black54': Colors.black54,
      'black87': Colors.black87,
    }),
    const ColorListDiagram('Colors.whites', Colors.black, <String, Color>{
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
  ];

  @override
  Future<List<ColorDiagram>> get diagrams async => _diagrams;
}

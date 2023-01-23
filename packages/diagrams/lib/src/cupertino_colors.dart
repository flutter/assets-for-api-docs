// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'diagram_step.dart';

const String _basic_colors = 'cupertino_basic_colors';
const String _active_colors = 'cupertino_active_colors';
const String _system_colors_1 = 'cupertino_system_colors_1';
const String _system_colors_2 = 'cupertino_system_colors_2';
const String _system_colors_3 = 'cupertino_system_colors_3';
const String _label_colors = 'cupertino_label_colors';
const String _background_colors = 'cupertino_background_colors';

List<Map<String, Color>> basicColors = <Map<String, Color>>[
  <String, Color>{'white': CupertinoColors.white},
  <String, Color>{'black': CupertinoColors.black},
  <String, Color>{'lightBackgroundGray': CupertinoColors.lightBackgroundGray},
  <String, Color>{
    'extraLightBackgroundGray': CupertinoColors.extraLightBackgroundGray
  },
  <String, Color>{'darkBackgroundGray': CupertinoColors.darkBackgroundGray},
  <String, Color>{'inactiveGray': CupertinoColors.inactiveGray},
  <String, Color>{'destructiveRed': CupertinoColors.destructiveRed},
];
List<Map<String, CupertinoDynamicColor>> activeColors =
    <Map<String, CupertinoDynamicColor>>[
  <String, CupertinoDynamicColor>{'activeBlue': CupertinoColors.activeBlue},
  <String, CupertinoDynamicColor>{'activeGreen': CupertinoColors.activeGreen},
  <String, CupertinoDynamicColor>{'activeOrange': CupertinoColors.activeOrange},
];
List<Map<String, CupertinoDynamicColor>> systemColors1 =
    <Map<String, CupertinoDynamicColor>>[
  <String, CupertinoDynamicColor>{'systemRed': CupertinoColors.systemRed},
  <String, CupertinoDynamicColor>{'systemOrange': CupertinoColors.systemOrange},
  <String, CupertinoDynamicColor>{'systemYellow': CupertinoColors.systemYellow},
  <String, CupertinoDynamicColor>{'systemGreen': CupertinoColors.systemGreen},
  <String, CupertinoDynamicColor>{'systemMint': CupertinoColors.systemMint},
  <String, CupertinoDynamicColor>{'systemTeal': CupertinoColors.systemTeal},
  <String, CupertinoDynamicColor>{'systemCyan': CupertinoColors.systemCyan},
  <String, CupertinoDynamicColor>{'systemBlue': CupertinoColors.systemBlue},
  <String, CupertinoDynamicColor>{'systemIndigo': CupertinoColors.systemIndigo},
  <String, CupertinoDynamicColor>{'systemPurple': CupertinoColors.systemPurple},
  <String, CupertinoDynamicColor>{'systemPink': CupertinoColors.systemPink},
  <String, CupertinoDynamicColor>{'systemBrown': CupertinoColors.systemBrown},
];
List<Map<String, CupertinoDynamicColor>> systemColors2 =
    <Map<String, CupertinoDynamicColor>>[
  <String, CupertinoDynamicColor>{'systemGrey': CupertinoColors.systemGrey},
  <String, CupertinoDynamicColor>{'systemGrey2': CupertinoColors.systemGrey2},
  <String, CupertinoDynamicColor>{'systemGrey3': CupertinoColors.systemGrey3},
  <String, CupertinoDynamicColor>{'systemGrey4': CupertinoColors.systemGrey4},
  <String, CupertinoDynamicColor>{'systemGrey5': CupertinoColors.systemGrey5},
  <String, CupertinoDynamicColor>{'systemGrey6': CupertinoColors.systemGrey6},
];
List<Map<String, CupertinoDynamicColor>> systemColors3 =
    <Map<String, CupertinoDynamicColor>>[
  <String, CupertinoDynamicColor>{'systemFill': CupertinoColors.systemFill},
  <String, CupertinoDynamicColor>{
    'secondarySystemFill': CupertinoColors.secondarySystemFill
  },
  <String, CupertinoDynamicColor>{
    'tertiarySystemFill': CupertinoColors.tertiarySystemFill
  },
  <String, CupertinoDynamicColor>{
    'quaternarySystemFill': CupertinoColors.quaternarySystemFill
  },
];
List<Map<String, CupertinoDynamicColor>> labelColors =
    <Map<String, CupertinoDynamicColor>>[
  <String, CupertinoDynamicColor>{'label': CupertinoColors.label},
  <String, CupertinoDynamicColor>{
    'secondaryLabel': CupertinoColors.secondaryLabel
  },
  <String, CupertinoDynamicColor>{
    'tertiaryLabel': CupertinoColors.tertiaryLabel
  },
  <String, CupertinoDynamicColor>{
    'quaternaryLabel': CupertinoColors.quaternaryLabel
  },
  <String, CupertinoDynamicColor>{
    'placeholderText': CupertinoColors.placeholderText
  },
  <String, CupertinoDynamicColor>{'separator': CupertinoColors.separator},
  <String, CupertinoDynamicColor>{
    'opaqueSeparator': CupertinoColors.opaqueSeparator
  },
  <String, CupertinoDynamicColor>{'link': CupertinoColors.link},
];
List<Map<String, CupertinoDynamicColor>> backgroundColors =
    <Map<String, CupertinoDynamicColor>>[
  <String, CupertinoDynamicColor>{
    'systemBackground': CupertinoColors.systemBackground
  },
  <String, CupertinoDynamicColor>{
    'secondarySystemBackground': CupertinoColors.secondarySystemBackground
  },
  <String, CupertinoDynamicColor>{
    'tertiarySystemBackground': CupertinoColors.tertiarySystemBackground
  },
  <String, CupertinoDynamicColor>{
    'systemGroupedBackground': CupertinoColors.systemGroupedBackground
  },
  <String, CupertinoDynamicColor>{
    'secondarySystemGroupedBackground':
        CupertinoColors.secondarySystemGroupedBackground
  },
  <String, CupertinoDynamicColor>{
    'tertiarySystemGroupedBackground':
        CupertinoColors.tertiarySystemGroupedBackground
  },
];

class CupertinoColorsDiagram extends StatelessWidget with DiagramMetadata {
  const CupertinoColorsDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = CupertinoTheme.of(context)
        .textTheme
        .tabLabelTextStyle
        .copyWith(fontSize: 14.0);

    Widget returnWidget;
    switch (name) {
      case _basic_colors:
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: const BoxConstraints(maxWidth: 350.0),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Text('Name', style: textStyle, textAlign: TextAlign.center),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text('Color',
                        style: textStyle, textAlign: TextAlign.center),
                  ),
                ],
              ),
              for (Map<String, Color> basicColor in basicColors)
                TableRow(
                  children: <Widget>[
                    Text(
                      basicColor.keys.first,
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                    ColorWidget(color: basicColor.values.first),
                  ],
                ),
            ],
          ),
        );
      case _active_colors:
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: const BoxConstraints(maxWidth: 550.0),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Text('Name', style: textStyle, textAlign: TextAlign.center),
                  Text('Color', style: textStyle, textAlign: TextAlign.center),
                  Text('Dark color',
                      style: textStyle, textAlign: TextAlign.center),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Text('High\nconstrast color',
                        style: textStyle, textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Text('Dark high\ncontrast color',
                        style: textStyle, textAlign: TextAlign.center),
                  ),
                ],
              ),
              for (Map<String, CupertinoDynamicColor> activeColor
                  in activeColors)
                TableRow(
                  children: <Widget>[
                    Text(
                      activeColor.keys.first,
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                    ColorWidget(color: activeColor.values.first.color),
                    ColorWidget(color: activeColor.values.first.darkColor),
                    ColorWidget(
                        color: activeColor.values.first.highContrastColor),
                    ColorWidget(
                        color: activeColor.values.first.darkHighContrastColor),
                  ],
                ),
            ],
          ),
        );
      case _system_colors_1:
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: const BoxConstraints(maxWidth: 550.0),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Text('Name', style: textStyle, textAlign: TextAlign.center),
                  Text('Color', style: textStyle, textAlign: TextAlign.center),
                  Text('Dark color',
                      style: textStyle, textAlign: TextAlign.center),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Text('High\nconstrast color',
                        style: textStyle, textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Text('Dark high\ncontrast color',
                        style: textStyle, textAlign: TextAlign.center),
                  ),
                ],
              ),
              for (Map<String, CupertinoDynamicColor> systemColor
                  in systemColors1)
                TableRow(
                  children: <Widget>[
                    Text(
                      systemColor.keys.first,
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                    ColorWidget(color: systemColor.values.first.color),
                    ColorWidget(color: systemColor.values.first.darkColor),
                    ColorWidget(
                        color: systemColor.values.first.highContrastColor),
                    ColorWidget(
                        color: systemColor.values.first.darkHighContrastColor),
                  ],
                ),
            ],
          ),
        );
      case _system_colors_2:
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: const BoxConstraints(maxWidth: 550.0),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              for (Map<String, CupertinoDynamicColor> systemColor
                  in systemColors2)
                TableRow(
                  children: <Widget>[
                    Text(
                      systemColor.keys.first,
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                    ColorWidget(color: systemColor.values.first.color),
                    ColorWidget(color: systemColor.values.first.darkColor),
                    ColorWidget(
                        color: systemColor.values.first.highContrastColor),
                    ColorWidget(
                        color: systemColor.values.first.darkHighContrastColor),
                  ],
                ),
            ],
          ),
        );
      case _system_colors_3:
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: const BoxConstraints(maxWidth: 550.0),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              for (Map<String, CupertinoDynamicColor> systemColor
                  in systemColors3)
                TableRow(
                  children: <Widget>[
                    Text(
                      systemColor.keys.first,
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                    ColorWidget(color: systemColor.values.first.color),
                    ColorWidget(color: systemColor.values.first.darkColor),
                    ColorWidget(
                        color: systemColor.values.first.highContrastColor),
                    ColorWidget(
                        color: systemColor.values.first.darkHighContrastColor),
                  ],
                ),
            ],
          ),
        );
      case _label_colors:
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: const BoxConstraints(maxWidth: 590.0),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Text('Name', style: textStyle, textAlign: TextAlign.center),
                  Text('Color', style: textStyle, textAlign: TextAlign.center),
                  Text('Dark color',
                      style: textStyle, textAlign: TextAlign.center),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Text('High\nconstrast color',
                        style: textStyle, textAlign: TextAlign.center),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Text('Dark high\ncontrast color',
                        style: textStyle, textAlign: TextAlign.center),
                  ),
                ],
              ),
              for (Map<String, CupertinoDynamicColor> labelColor in labelColors)
                TableRow(
                  children: <Widget>[
                    Text(
                      labelColor.keys.first,
                      style: textStyle,
                      textAlign: TextAlign.center,
                    ),
                    ColorWidget(color: labelColor.values.first.color),
                    ColorWidget(color: labelColor.values.first.darkColor),
                    ColorWidget(
                        color: labelColor.values.first.highContrastColor),
                    ColorWidget(
                        color: labelColor.values.first.darkHighContrastColor),
                  ],
                ),
            ],
          ),
        );
      case _background_colors:
        return Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
            1: FixedColumnWidth(120),
            2: FixedColumnWidth(120),
            3: FixedColumnWidth(120),
            4: FixedColumnWidth(120),
          },
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Text('Name', style: textStyle, textAlign: TextAlign.center),
                Text('Color', style: textStyle, textAlign: TextAlign.center),
                Text('Dark color',
                    style: textStyle, textAlign: TextAlign.center),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Text('High\nconstrast color',
                      style: textStyle, textAlign: TextAlign.center),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Text('Dark high\ncontrast color',
                      style: textStyle, textAlign: TextAlign.center),
                ),
              ],
            ),
            for (Map<String, CupertinoDynamicColor> backgroundColor
                in backgroundColors)
              TableRow(
                children: <Widget>[
                  Text(
                    backgroundColor.keys.first,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                  ColorWidget(color: backgroundColor.values.first.color),
                  ColorWidget(color: backgroundColor.values.first.darkColor),
                  ColorWidget(
                      color: backgroundColor.values.first.highContrastColor),
                  ColorWidget(
                      color:
                          backgroundColor.values.first.darkHighContrastColor),
                ],
              ),
          ],
        );
      default:
        returnWidget = const Text('Error');
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(200.0, 200.0)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: CupertinoColors.white,
        child: Center(child: returnWidget),
      ),
    );
  }
}

class CupertinoColorsDiagramStep extends DiagramStep {
  @override
  final String category = 'cupertino';

  @override
  Future<List<CupertinoColorsDiagram>> get diagrams async =>
      <CupertinoColorsDiagram>[
        const CupertinoColorsDiagram(_basic_colors),
        const CupertinoColorsDiagram(_active_colors),
        const CupertinoColorsDiagram(_system_colors_1),
        const CupertinoColorsDiagram(_system_colors_2),
        const CupertinoColorsDiagram(_system_colors_3),
        const CupertinoColorsDiagram(_label_colors),
        const CupertinoColorsDiagram(_background_colors),
      ];
}

class ColorWidget extends StatelessWidget {
  const ColorWidget({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: color.red > 200 && color.green > 200 && color.blue > 200
            ? CupertinoColors.black
            : CupertinoColors.white,
        fontSize: 16.0,
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14.0),
          ),
          padding: const EdgeInsets.all(14.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          height: 90.0,
          width: 90.0,
          child: Row(
            children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: const <Widget>[
                  Text('R'),
                  Text('G'),
                  Text('B'),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('${color.red}'),
                  Text('${color.green}'),
                  Text('${color.blue}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'diagram_step.dart';

class LinkedLabelCheckbox extends StatelessWidget {
  const LinkedLabelCheckbox({
    Key? key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Expanded(
            child: RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    print('Link has been tapped.');
                  },
              ),
            ),
          ),
          Checkbox(
            value: value,
            onChanged: (bool? newValue) {
              onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Expanded(child: Text(label)),
            Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue!);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CheckboxListTileDiagram extends StatefulWidget implements DiagramMetadata {
  const CheckboxListTileDiagram(this.name, {Key? key}) : super(key: key);

  @override
  final String name;

  @override
  State<CheckboxListTileDiagram> createState() => _CheckboxListTileDiagramState();
}

class _CheckboxListTileDiagramState extends State<CheckboxListTileDiagram> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    switch (widget.name) {
      case 'checkbox_list_tile':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 100.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: CheckboxListTile(
              title: const Text('Animate Slowly'),
              value: timeDilation != 1.0,
              onChanged: (bool? value) {
                setState(() { timeDilation = (value ?? false) ? 20.0 : 1.0; });
              },
              secondary: const Icon(Icons.hourglass_empty),
            ),
          ),
        );
      case 'checkbox_list_tile_semantics':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 100.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: LinkedLabelCheckbox(
              label: 'Linked, tappable label text',
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              value: _isSelected,
              onChanged: (bool? newValue) {
                setState(() {
                  _isSelected = newValue!;
                });
              }),
            ),
          );
        case 'checkbox_list_tile_custom':
          return ConstrainedBox(
            key: UniqueKey(),
            constraints: BoxConstraints.tight(const Size(400.0, 100.0)),
            child: Container(
              alignment: FractionalOffset.center,
              padding: const EdgeInsets.all(20.0),
              color: Colors.white,
              child: LabeledCheckbox(
                  label: 'This is the label text',
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  value: _isSelected,
                  onChanged: (bool newValue) {
                    setState(() {
                      _isSelected = newValue;
                    });
                  },
                ),
              ),
            );
        default:
          return const Text('Error');
    }
  }
}

class CheckboxListTileDiagramStep extends DiagramStep<CheckboxListTileDiagram> {
  CheckboxListTileDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<CheckboxListTileDiagram>> get diagrams async => <CheckboxListTileDiagram>[
    const CheckboxListTileDiagram('checkbox_list_tile'),
    const CheckboxListTileDiagram('checkbox_list_tile_semantics'),
    const CheckboxListTileDiagram('checkbox_list_tile_custom'),
  ];

  @override
  Future<File> generateDiagram(CheckboxListTileDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

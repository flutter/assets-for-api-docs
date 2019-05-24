// Copyright 2019 The Chromium Authors. All rights reserved.
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
    this.label,
    this.padding,
    this.value,
    this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

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
                style: TextStyle(
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
            onChanged: (bool newValue) {
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
    this.label,
    this.padding,
    this.value,
    this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onChanged;

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
              onChanged: (bool newValue) {
                onChanged(newValue);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CheckboxListTileDiagram extends StatefulWidget implements DiagramMetadata {
  const CheckboxListTileDiagram(this.name);

  @override
  final String name;

  @override
  _CheckboxListTileDiagramState createState() => _CheckboxListTileDiagramState();
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
              onChanged: (bool value) {
                setState(() { timeDilation = value ? 20.0 : 1.0; });
              },
              secondary: const Icon(Icons.hourglass_empty),
            ),
          ),
        );
        break;
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
              onChanged: (bool newValue) {
                setState(() {
                  _isSelected = newValue;
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
          break;
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
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

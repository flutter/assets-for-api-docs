// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class LinkedLabelSwitch extends StatelessWidget {
  const LinkedLabelSwitch({
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool value;
  final ValueChanged<bool> onChanged;

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
                    print('Label has been tapped.');
                  },
              ),
            ),
          ),
          Switch(
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

class LabeledSwitch extends StatelessWidget {
  const LabeledSwitch({
    required this.label,
    required this.padding,
    this.groupValue = false,
    required this.value,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  final String label;
  final EdgeInsets padding;
  final bool groupValue;
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
            Switch(
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

class SwitchListTileDiagram extends StatefulWidget implements DiagramMetadata {
  const SwitchListTileDiagram(this.name, {Key? key}) : super(key: key);

  @override
  final String name;

  @override
  State<SwitchListTileDiagram> createState() => _SwitchListTileDiagramState();
}

class _SwitchListTileDiagramState extends State<SwitchListTileDiagram> {
  bool _lights = false;
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    switch(widget.name) {
      case 'switch_list_tile':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 100.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            color: Colors.white,
            child: SwitchListTile(
              title: const Text('Lights'),
              value: _lights,
              onChanged: (bool value) { setState(() { _lights = value; }); },
              secondary: const Icon(Icons.lightbulb_outline),
            ),
          ),
        );
      case 'switch_list_tile_semantics':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 100.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: LinkedLabelSwitch(
              label: 'Linked, tappable label text',
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              value: _isSelected,
              onChanged: (bool newValue) {
                setState(() {
                  _isSelected = newValue;
                });
              },
            ),
          ),
        );
      case 'switch_list_tile_custom':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 100.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: LabeledSwitch(
              label: 'This is the label text',
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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

class SwitchListTileDiagramStep extends DiagramStep<SwitchListTileDiagram> {
  SwitchListTileDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<SwitchListTileDiagram>> get diagrams async => <SwitchListTileDiagram>[
    const SwitchListTileDiagram('switch_list_tile'),
    const SwitchListTileDiagram('switch_list_tile_semantics'),
    const SwitchListTileDiagram('switch_list_tile_custom'),
  ];

  @override
  Future<File> generateDiagram(SwitchListTileDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

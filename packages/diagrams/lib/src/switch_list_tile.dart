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
    this.label,
    this.padding,
    this.groupValue,
    this.value,
    this.onChanged,
  });

  final String label;
  final EdgeInsets padding;
  final bool groupValue;
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
  const SwitchListTileDiagram(this.name);

  @override
  final String name;

  @override
  _SwitchListTileDiagramState createState() => _SwitchListTileDiagramState();
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
        break;
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
        break;
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
        break;
      default:
        return const Text('Error');
        break;
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
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

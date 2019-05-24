// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

enum SingingCharacter { lafayette, jefferson }

class LinkedLabelRadio extends StatelessWidget {
  const LinkedLabelRadio({
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
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Radio<bool>(
              groupValue: groupValue,
              value: value,
              onChanged: (bool newValue) {
                onChanged(newValue);
              }),
          RichText(
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
        ],
      ),
    );
  }
}

class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
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
        if (value != groupValue)
          onChanged(value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Radio<bool>(
              groupValue: groupValue,
              value: value,
              onChanged: (bool newValue) {
                onChanged(newValue);
              },
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class RadioListTileDiagram extends StatefulWidget implements DiagramMetadata {
  const RadioListTileDiagram(this.name);

  @override
  final String name;

  @override
  _RadioListTileDiagramState createState() => _RadioListTileDiagramState();
}

class _RadioListTileDiagramState extends State<RadioListTileDiagram> {
  SingingCharacter _character = SingingCharacter.lafayette;
  bool _isRadioSelected = false;

  @override
  Widget build(BuildContext context) {
    switch (widget.name) {
      case 'radio_list_tile':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 140.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                RadioListTile<SingingCharacter>(
                  title: const Text('Lafayette'),
                  value: SingingCharacter.lafayette,
                  groupValue: _character,
                  onChanged: (SingingCharacter value) { setState(() { _character = value; }); },
                ),
                RadioListTile<SingingCharacter>(
                  title: const Text('Thomas Jefferson'),
                  value: SingingCharacter.jefferson,
                  groupValue: _character,
                  onChanged: (SingingCharacter value) { setState(() { _character = value; }); },
                ),
              ],
            ),
          ),
        );
      break;
      case 'radio_list_tile_semantics':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 140.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: Column(
              children: <Widget>[
                LinkedLabelRadio(
                  label: 'First tappable label text',
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  value: true,
                  groupValue: _isRadioSelected,
                  onChanged: (bool newValue) {
                    setState(() {
                      _isRadioSelected = newValue;
                    });
                  },
                ),
                LinkedLabelRadio(
                  label: 'Second tappable label text',
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  value: false,
                  groupValue: _isRadioSelected,
                  onChanged: (bool newValue) {
                    setState(() {
                      _isRadioSelected = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      break;
        case 'radio_list_tile_custom':
          return ConstrainedBox(
            key: UniqueKey(),
            constraints: BoxConstraints.tight(const Size(400.0, 140.0)),
            child: Container(
              alignment: FractionalOffset.center,
              padding: const EdgeInsets.all(5.0),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  LabeledRadio(
                    label: 'This is the first label text',
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    value: true,
                    groupValue: _isRadioSelected,
                    onChanged: (bool newValue) {
                      setState(() {
                        _isRadioSelected = newValue;
                      });
                    },
                  ),
                  LabeledRadio(
                    label: 'This is the second label text',
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    value: false,
                    groupValue: _isRadioSelected,
                    onChanged: (bool newValue) {
                      setState(() {
                        _isRadioSelected = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        break;
      default:
        return const Text('Error');
    }
  }
}

class RadioListTileDiagramStep extends DiagramStep<RadioListTileDiagram> {
  RadioListTileDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<RadioListTileDiagram>> get diagrams async => <RadioListTileDiagram>[
    const RadioListTileDiagram('radio_list_tile'),
    const RadioListTileDiagram('radio_list_tile_semantics'),
    const RadioListTileDiagram('radio_list_tile_custom'),
  ];

  @override
  Future<File> generateDiagram(RadioListTileDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

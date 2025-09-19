// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

enum SingingCharacter { lafayette, jefferson }

class LinkedLabelRadio extends StatelessWidget {
  const LinkedLabelRadio({
    required this.label,
    required this.padding,
    required this.value,
    super.key,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Radio<bool>(value: value),
          RichText(
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
        ],
      ),
    );
  }
}

class LabeledRadio extends StatelessWidget {
  const LabeledRadio({
    required this.label,
    required this.padding,
    required this.value,
    super.key,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        RadioGroup.maybeOf<bool>(context)?.onChanged(value);
      },
      child: Padding(
        padding: padding,
        child: Row(
          children: <Widget>[
            Radio<bool>(value: value),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class RadioListTileDiagram extends StatefulWidget with DiagramMetadata {
  const RadioListTileDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  State<RadioListTileDiagram> createState() => _RadioListTileDiagramState();
}

class _RadioListTileDiagramState extends State<RadioListTileDiagram> {
  SingingCharacter? _character = SingingCharacter.lafayette;
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
            child: RadioGroup<SingingCharacter>(
              groupValue: _character,
              onChanged: (SingingCharacter? value) {
                setState(() {
                  _character = value;
                });
              },
              child: const Column(
                children: <Widget>[
                  RadioListTile<SingingCharacter>(
                    title: Text('Lafayette'),
                    value: SingingCharacter.lafayette,
                  ),
                  RadioListTile<SingingCharacter>(
                    title: Text('Thomas Jefferson'),
                    value: SingingCharacter.jefferson,
                  ),
                ],
              ),
            ),
          ),
        );
      case 'radio_list_tile_semantics':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 140.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: RadioGroup<bool>(
              groupValue: _isRadioSelected,
              onChanged: (bool? newValue) {
                setState(() {
                  _isRadioSelected = newValue!;
                });
              },
              child: const Column(
                children: <Widget>[
                  LinkedLabelRadio(
                    label: 'First tappable label text',
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    value: true,
                  ),
                  LinkedLabelRadio(
                    label: 'Second tappable label text',
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    value: false,
                  ),
                ],
              ),
            ),
          ),
        );
      case 'radio_list_tile_custom':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 140.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: RadioGroup<bool>(
              groupValue: _isRadioSelected,
              onChanged: (bool? newValue) {
                setState(() {
                  _isRadioSelected = newValue!;
                });
              },
              child: const Column(
                children: <Widget>[
                  LabeledRadio(
                    label: 'This is the first label text',
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    value: true,
                  ),
                  LabeledRadio(
                    label: 'This is the second label text',
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    value: false,
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return const Text('Error');
    }
  }
}

class RadioListTileDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<RadioListTileDiagram>> get diagrams async =>
      <RadioListTileDiagram>[
        const RadioListTileDiagram('radio_list_tile'),
        const RadioListTileDiagram('radio_list_tile_semantics'),
        const RadioListTileDiagram('radio_list_tile_custom'),
      ];
}

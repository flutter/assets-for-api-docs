// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _textFormField = 'text_form_field';
const String _textFormFieldError = 'text_form_field_error';

class TextFormFieldDiagram extends StatelessWidget with DiagramMetadata {
  const TextFormFieldDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    late Widget returnWidget;

    switch (name) {
      case _textFormField:
        returnWidget = TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            hintText: 'What do people call you?',
            labelText: 'Name *',
          ),
          onSaved: (String? value) {},
          validator: (String? value) {
            return (value ?? '').contains('@')
                ? 'Do not use the @ char.'
                : null;
          },
        );
        break;
      case _textFormFieldError:
        returnWidget = TextFormField(
          autovalidateMode: AutovalidateMode.always,
          initialValue: 'bad@input',
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            hintText: 'What do people call you?',
            labelText: 'Name *',
          ),
          onSaved: (String? value) {},
          validator: (String? value) {
            return (value ?? '').contains('@')
                ? 'Do not use the @ char.'
                : null;
          },
        );
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 110.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: returnWidget,
      ),
    );
  }
}

class TextFormFieldDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<TextFormFieldDiagram>> get diagrams async =>
      <TextFormFieldDiagram>[
        const TextFormFieldDiagram(_textFormField),
        const TextFormFieldDiagram(_textFormFieldError),
      ];
}

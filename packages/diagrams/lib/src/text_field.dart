// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

class TextFieldDiagram extends StatelessWidget with DiagramMetadata {
  const TextFieldDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 144.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: const TextField(
          obscureText: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Password',
          ),
        ),
      ),
    );
  }
}

class TextFieldDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<TextFieldDiagram>> get diagrams async => <TextFieldDiagram>[
    const TextFieldDiagram('text_field'),
  ];
}

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _inputDecoration = 'input_decoration';
const String _inputDecorationError = 'input_decoration_error';
const String _inputDecorationPrefixSuffix = 'input_decoration_prefix_suffix';
const String _inputDecorationCollapsed = 'input_decoration_collapsed';

class InputDecorationDiagram extends StatelessWidget implements DiagramMetadata {
  const InputDecorationDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _inputDecoration:
        returnWidget = ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(260, 120)),
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.send),
                  hintText: 'Hint Text',
                  helperText: 'Helper Text',
                  counterText: '0 characters',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        );
        break;
      case _inputDecorationError:
        returnWidget = ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(260, 120)),
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: const Center(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Hint Text',
                  errorText: 'Error Text',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        );
        break;
      case _inputDecorationPrefixSuffix:
        returnWidget = ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(260, 120)),
          child: Container(
            color: Colors.white,
            child: Center(
              child: TextFormField(
                initialValue: 'abc',
                decoration: const InputDecoration(
                  prefix: Text('Prefix'),
                  suffix: Text('Suffix'),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        );
        break;
      case _inputDecorationCollapsed:
        returnWidget = ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(260, 120)),
          child: Container(
            color: Colors.white,
            child: const Center(
              child: TextField(
                decoration: InputDecoration.collapsed(
                  hintText: 'Hint Text',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
        );
        break;
    }

    return returnWidget;
  }
}

class InputDecorationDiagramStep extends DiagramStep<InputDecorationDiagram> {
  InputDecorationDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<InputDecorationDiagram>> get diagrams async =>
      <InputDecorationDiagram>[
        const InputDecorationDiagram(_inputDecoration),
        const InputDecorationDiagram(_inputDecorationError),
        const InputDecorationDiagram(_inputDecorationPrefixSuffix),
        const InputDecorationDiagram(_inputDecorationCollapsed),
      ];

  @override
  Future<File> generateDiagram(InputDecorationDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

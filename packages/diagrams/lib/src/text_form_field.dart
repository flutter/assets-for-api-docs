// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';

class TextFormFieldDiagram extends StatelessWidget implements DiagramMetadata {
  const TextFormFieldDiagram();

  @override
  String get name => 'text_form_field';

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: new BoxConstraints.tight(const Size(400.0, 154.0)),
      child: new Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: TextFormField(
          maxLength: 10,
          decoration: InputDecoration(
            //icon: 'asdf',
            labelText: 'Label',
            helperText: 'Helper',
            hintText: 'Hint',
            errorText: 'Error',
            prefixText: 'Prefix',
            suffixText: 'Suffix',
            counterText: 'Counter',
            semanticCounterText: 'Semantic Counter', // TODO what is this?
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}

class TextFormFieldDiagramStep extends DiagramStep {
  TextFormFieldDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[const TextFormFieldDiagram()];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final TextFormFieldDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}



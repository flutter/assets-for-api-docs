// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';

class TextFormFieldFocusedDiagram extends StatelessWidget implements DiagramMetadata {
  @override
  String get name => 'text_form_field_focused';

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: new BoxConstraints.tight(const Size(400.0, 154.0)),
      child: new Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: TextFormField(
          autofocus: true,
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

class TextFormFieldFocusedDiagramStep extends DiagramStep {
  TextFormFieldFocusedDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[TextFormFieldFocusedDiagram()];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final TextFormFieldFocusedDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;

    // Wait 1 second to let the input animate to focused.
    final Completer<void> completer = Completer<void>();
    Timer(Duration(seconds: 1), completer.complete);
    await completer.future;

    return await controller.drawDiagramToFile(
      new File('${diagram.name}.png'),
      timestamp: const Duration(milliseconds: 1000),
    );
  }
}

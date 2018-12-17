// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';
import 'utils.dart';

class TextFormFieldFocusedDiagram extends StatelessWidget implements DiagramMetadata {
  @override
  String get name => 'text_form_field_focused';

  @override
  Widget build(BuildContext context) {
    final GlobalKey textFormFieldKey = new GlobalKey();
    final GlobalKey canvasKey = new GlobalKey();
    final GlobalKey heroKey = new GlobalKey();

    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(
        540.0,
        260.0,
      )),
      child: new Theme(
        data: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        child: new Material(
          color: const Color(0xFFFFFFFF),
          child: new MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.all(0.0),
            ),
            child: new Stack(
              children: <Widget>[
                new Center(
                  child: new Container(
                    key: heroKey,
                    width: 300.0,
                    height: kToolbarHeight * 2.0 + 50.0,
                    child: TextFormField(
                      key: textFormFieldKey,
                      autofocus: true,
                      maxLength: 10,
                      decoration: const InputDecoration(
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
                ),
                new Positioned.fill(
                  child: new LabelPainterWidget(
                    key: canvasKey,
                    labels: <Label>[
                      Label(
                        textFormFieldKey,
                        'labelText,\nlabelStyle',
                        const FractionalOffset(0.025, 0.03),
                      ),
                      Label(
                        textFormFieldKey,
                        'prefix,\nprefixText,\nprefixStyle,\nprefixIcon',
                        const FractionalOffset(0.025, 0.15),
                      ),
                      Label(
                        textFormFieldKey,
                        'hintText,\nhintStyle,\nhintMaxLines',
                        const FractionalOffset(0.3, 0.2),
                      ),
                      Label(
                        textFormFieldKey,
                        'errorText,\nerrorStyle,\nerrorMaxlines,\nerrorBorder,\nfocusedErrorBorder',
                        const FractionalOffset(0.18, 0.55),
                      ),
                      Label(
                        textFormFieldKey,
                        'counterText,\ncounterStyle',
                        const FractionalOffset(0.85, 0.55),
                      ),
                      Label(
                        textFormFieldKey,
                        'suffix,\nsuffixText,\nsuffixStyle,\nsuffixIcon',
                        const FractionalOffset(0.8, 0.2),
                      ),
                    ],
                    heroKey: heroKey,
                  ),
                ),
              ],
            ),
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
    Timer(const Duration(seconds: 1), completer.complete);
    await completer.future;

    return await controller.drawDiagramToFile(
      File('${diagram.name}.png'),
      timestamp: const Duration(milliseconds: 1000),
    );
  }
}

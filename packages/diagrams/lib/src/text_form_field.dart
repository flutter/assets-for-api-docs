// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';
import 'utils.dart';

class TextFormFieldDiagram extends StatelessWidget implements DiagramMetadata {
  @override
  String get name => 'text_form_field';

  @override
  Widget build(BuildContext context) {
    final GlobalKey textFormFieldKey = new GlobalKey();
    final GlobalKey canvasKey = new GlobalKey();
    final GlobalKey heroKey = new GlobalKey();

    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(
        540.0,
        360.0,
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
                    height: 80.0,
                    child: Center(
                      child: TextFormField(
                        key: textFormFieldKey,
                        maxLength: 10,
                        decoration: const InputDecoration(
                          //icon: 'asdf',
                          labelText: 'Label',
                          helperText: 'Helper',
                          errorText: 'Error',
                          counterText: 'Counter',
                          semanticCounterText: 'Semantic Counter', // TODO what is this?
                          border: OutlineInputBorder(),
                        ),
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
                        const FractionalOffset(0.025, 0.37),
                      ),
                      Label(
                        textFormFieldKey,
                        'errorText,\nerrorStyle,\nerrorMaxlines,\nerrorBorder,\nfocusedErrorBorder',
                        const FractionalOffset(0.08, 1.05),
                      ),
                      Label(
                        textFormFieldKey,
                        'counterText,\ncounterStyle',
                        const FractionalOffset(0.9, 1.05),
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

class TextFormFieldDiagramStep extends DiagramStep {
  TextFormFieldDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[TextFormFieldDiagram()];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final TextFormFieldDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

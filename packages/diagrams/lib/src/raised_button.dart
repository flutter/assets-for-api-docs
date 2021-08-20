// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class RaisedButtonDiagram extends StatelessWidget implements DiagramMetadata {
  const RaisedButtonDiagram(this.name, {Key? key}) : super(key: key);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400.0, 250.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const RaisedButton( // ignore: deprecated_member_use
                onPressed: null,
                child: Text(
                  'Disabled Button',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 30),
              RaisedButton( // ignore: deprecated_member_use
                onPressed: () {},
                child: const Text(
                  'Enabled Button',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(height: 30),
              RaisedButton( // ignore: deprecated_member_use
                onPressed: () {},
                textColor: Colors.white,
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xFF0D47A1),
                        Color(0xFF1976D2),
                        Color(0xFF42A5F5),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: const Text(
                    'Gradient Button',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RaisedButtonDiagramStep extends DiagramStep<RaisedButtonDiagram> {
  RaisedButtonDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<RaisedButtonDiagram>> get diagrams async => <RaisedButtonDiagram>[
        const RaisedButtonDiagram('raised_button'),
      ];

  @override
  Future<File> generateDiagram(RaisedButtonDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

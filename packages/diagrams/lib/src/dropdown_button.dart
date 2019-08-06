// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

const String _basic = 'dropdown_button';

class DropdownButtonDiagram extends StatelessWidget implements DiagramMetadata {
  const DropdownButtonDiagram(this.name, this.buttonKey);

  @override
  final String name;
  final GlobalKey buttonKey;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(150, 100)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Scaffold(
          body: Center(
            child: DropdownButton<String>(
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(
                color: Colors.deepPurple
              ),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              value: 'One',
              onChanged: (String newValue) {},
              items: <String>['One', 'Two', 'Free', 'Four']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownButtonDiagramStep extends DiagramStep<DropdownButtonDiagram> {
  DropdownButtonDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DropdownButtonDiagram>> get diagrams async => <DropdownButtonDiagram>[
        DropdownButtonDiagram(_basic, GlobalKey()),
      ];

  @override
  Future<File> generateDiagram(DropdownButtonDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

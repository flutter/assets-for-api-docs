// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'diagram_step.dart';

const String _basic = 'dropdown_button';

class DropdownButtonDiagram extends StatelessWidget with DiagramMetadata {
  const DropdownButtonDiagram(this.name, this.buttonKey, {super.key});

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
              icon: const Icon(Icons.arrow_downward),
              elevation: 16,
              style: const TextStyle(color: Colors.deepPurple),
              underline: Container(height: 2, color: Colors.deepPurpleAccent),
              value: 'One',
              onChanged: (String? newValue) {},
              items: <String>['One', 'Two', 'Free', 'Four']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class DropdownButtonDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<DropdownButtonDiagram>> get diagrams async =>
      <DropdownButtonDiagram>[DropdownButtonDiagram(_basic, GlobalKey())];
}

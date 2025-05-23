// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

class PaddingDiagram extends StatelessWidget with DiagramMetadata {
  const PaddingDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(200, 120)),
      child: Container(
        alignment: FractionalOffset.center,
        color: Colors.grey.shade300,
        child: const Card(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Hello World!'),
          ),
        ),
      ),
    );
  }
}

class PaddingDiagramStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<PaddingDiagram>> get diagrams async => <PaddingDiagram>[
    const PaddingDiagram('padding'),
  ];
}

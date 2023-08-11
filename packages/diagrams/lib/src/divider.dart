// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

class DividerDiagram extends StatelessWidget with DiagramMetadata {
  const DividerDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(120, 240)),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.amber,
                  child: const Center(
                    child: Text('Above'),
                  ),
                ),
              ),
              const Divider(
                color: Colors.black,
                height: 20,
                thickness: 5,
                indent: 20,
                endIndent: 0,
              ),
              Expanded(
                child: Container(
                  color: Colors.blue,
                  child: const Center(
                    child: Text('Below'),
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

class DividerDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<DividerDiagram>> get diagrams async => <DividerDiagram>[
        const DividerDiagram('divider'),
      ];
}

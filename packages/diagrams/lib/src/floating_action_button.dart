// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _basic = 'floating_action_button';
const String _labeled = 'floating_action_button_label';

class FloatingActionButtonDiagram extends StatelessWidget with DiagramMetadata {
  const FloatingActionButtonDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    late Widget returnWidget;

    switch (name) {
      case _basic:
        returnWidget = Scaffold(
          appBar: AppBar(title: const Text('Floating Action Button')),
          body: const Center(child: Text('Press the button below!')),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.green,
            child: const Icon(Icons.navigation),
          ),
        );
        break;
      case _labeled:
        returnWidget = Scaffold(
          appBar: AppBar(title: const Text('Floating Action Button Label')),
          body: const Center(
            child: Text('Press the button with a label below!'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            label: const Text('Approve'),
            icon: const Icon(Icons.thumb_up),
            backgroundColor: Colors.pink,
          ),
        );
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 533.33)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Center(child: returnWidget),
      ),
    );
  }
}

class FloatingActionButtonDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<FloatingActionButtonDiagram>> get diagrams async =>
      <FloatingActionButtonDiagram>[
        const FloatingActionButtonDiagram(_basic),
        const FloatingActionButtonDiagram(_labeled),
      ];
}

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _basic = 'floating_action_button';
const String _labeled = 'floating_action_button_label';

class FloatingActionButtonDiagram extends StatelessWidget implements DiagramMetadata {
  const FloatingActionButtonDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _basic:
        returnWidget = Scaffold(
          appBar: AppBar(
            title: const Text('Floating Action Button'),
          ),
          body: const Center(
              child: Text('Press the button below!')
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.navigation),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case _labeled:
        returnWidget = Scaffold(
          appBar: AppBar(
            title: const Text('Floating Action Button Label'),
          ),
          body: const Center(
            child: Text('Press the button with a label below!'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {},
            label: const Text('Approve'),
            icon: Icon(Icons.thumb_up),
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

class FloatingActionButtonDiagramStep extends DiagramStep<FloatingActionButtonDiagram> {
  FloatingActionButtonDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<FloatingActionButtonDiagram>> get diagrams async => <FloatingActionButtonDiagram>[
        const FloatingActionButtonDiagram(_basic),
        const FloatingActionButtonDiagram(_labeled),
      ];

  @override
  Future<File> generateDiagram(FloatingActionButtonDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _boxDecoration = 'box_decoration';

class BoxDecorationDiagram extends StatelessWidget implements DiagramMetadata {
  const BoxDecorationDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300, 200)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff7c94b6),
            image: const DecorationImage(
              image: NetworkImage('https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: Colors.black,
              width: 8,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class BoxDecorationDiagramStep extends DiagramStep<BoxDecorationDiagram> {
  BoxDecorationDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'painting';

  @override
  Future<List<BoxDecorationDiagram>> get diagrams async =>
      <BoxDecorationDiagram>[
        const BoxDecorationDiagram(_boxDecoration),
      ];

  @override
  Future<File> generateDiagram(BoxDecorationDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    await Future<void>.delayed(const Duration(seconds: 1));

    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

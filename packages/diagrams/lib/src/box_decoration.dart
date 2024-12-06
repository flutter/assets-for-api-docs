// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _boxDecoration = 'box_decoration';

const ImageProvider owlImage = NetworkImage(
  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
);

class BoxDecorationDiagram extends StatelessWidget with DiagramMetadata {
  const BoxDecorationDiagram(this.name, {super.key});

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
            image: const DecorationImage(image: owlImage, fit: BoxFit.cover),
            border: Border.all(width: 8),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Future<void> setUp(GlobalKey key) async {
    await precacheImage(owlImage, key.currentContext!);
  }
}

class BoxDecorationDiagramStep extends DiagramStep {
  @override
  final String category = 'painting';

  @override
  Future<List<BoxDecorationDiagram>> get diagrams async =>
      <BoxDecorationDiagram>[const BoxDecorationDiagram(_boxDecoration)];
}

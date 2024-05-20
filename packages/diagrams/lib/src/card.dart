// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

class CardDiagram extends StatelessWidget with DiagramMetadata {
  const CardDiagram({super.key});

  @override
  String get name => 'card';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400.0, 154.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Card(
          key: key,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.album),
                title: Text('The Enchanted Nightingale'),
                subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
              ),
              ButtonBar(
                // ignore: deprecated_member_use
                children: <Widget>[
                  TextButton(
                    child: const Text('BUY TICKETS'),
                    onPressed: () {},
                  ),
                  TextButton(
                    child: const Text('LISTEN'),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<CardDiagram>> get diagrams async =>
      <CardDiagram>[const CardDiagram()];
}

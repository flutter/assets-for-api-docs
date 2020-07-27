// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:diagram_capture/diagram_capture.dart';

import 'diagram_step.dart';

class CardDiagram extends StatelessWidget implements DiagramMetadata {
  const CardDiagram();

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
                children: <Widget>[
                  FlatButton(
                    child: const Text('BUY TICKETS'),
                    onPressed: () {},
                  ),
                  FlatButton(
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

class CardDiagramStep extends DiagramStep<CardDiagram> {
  CardDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<CardDiagram>> get diagrams async => <CardDiagram>[const CardDiagram()];

  @override
  Future<File> generateDiagram(CardDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

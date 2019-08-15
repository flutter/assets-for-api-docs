// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _futureBuilder = 'future_builder';
const String _futureBuilderError = 'future_builder_error';
const Duration _futureDuration = Duration(seconds: 1);
const Duration _pauseDuration = Duration(seconds: 1);
final Duration _totalDuration = _futureDuration + _pauseDuration;

class FutureBuilderDiagram extends StatefulWidget implements DiagramMetadata {
  const FutureBuilderDiagram(this.name);

  @override
  final String name;

  @override
  _FutureBuilderDiagramState createState() => _FutureBuilderDiagramState();
}

class _FutureBuilderDiagramState extends State<FutureBuilderDiagram> {
  Future<String> _calculation;

  @override
  void initState() {
    if (widget.name == _futureBuilder) {
      _calculation = Future<String>.delayed(
        _futureDuration,
        () => 'Data Loaded',
      );
    } else if (widget.name == _futureBuilderError) {
      _calculation = () async {
        await Future<void>.delayed(_futureDuration);
        throw 'Loading failed';
      }();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(200, 120)),
      child: Container(
        alignment: FractionalOffset.center,
        color: Colors.white,
        child: FutureBuilder<String>(
          future: _calculation,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text('Press button to start.');
              case ConnectionState.active:
              case ConnectionState.waiting:
                return const Text('Awaiting result...');
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                return Text('Result: ${snapshot.data}');
            }

            return null;
          },
        ),
      ),
    );
  }
}

class FutureBuilderDiagramStep extends DiagramStep<FutureBuilderDiagram> {
  FutureBuilderDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<FutureBuilderDiagram>> get diagrams async =>
      <FutureBuilderDiagram>[
        const FutureBuilderDiagram(_futureBuilder),
        const FutureBuilderDiagram(_futureBuilderError),
      ];

  @override
  Future<File> generateDiagram(FutureBuilderDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    return await controller.drawAnimatedDiagramToFiles(
      end: _totalDuration,
      frameRate: 60,
      name: diagram.name,
      category: category,
    );
  }
}

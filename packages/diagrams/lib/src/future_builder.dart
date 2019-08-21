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
const Duration _futureDuration = Duration(seconds: 2);
const Duration _pauseDuration = Duration(seconds: 1);
final Duration _totalDuration = _futureDuration + _pauseDuration;

class FutureBuilderDiagram extends StatefulWidget implements DiagramMetadata {
  const FutureBuilderDiagram(this.name, {this.size = 60});

  @override
  final String name;
  final double size;

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
      constraints: BoxConstraints.tight(const Size(200, 150)),
      child: Container(
        alignment: FractionalOffset.center,
        color: Colors.white,
        child: FutureBuilder<String>(
          future: _calculation,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            List<Widget> children;

            if (snapshot.hasData) {
              children = <Widget>[
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: widget.size,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Result: ${snapshot.data}'),
                )
              ];
            } else if (snapshot.hasError) {
              children = <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: widget.size,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error: ${snapshot.error}'),
                )
              ];
            } else {
              children = <Widget>[
                SizedBox(
                  child: const CircularProgressIndicator(),
                  width: widget.size,
                  height: widget.size,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                )
              ];
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            );
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

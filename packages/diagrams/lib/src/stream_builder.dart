// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _streamBuilder = 'stream_builder';
const String _streamBuilderError = 'stream_builder_error';
const Duration _pauseDuration = Duration(seconds: 1);
final Duration _totalDuration = _pauseDuration * 4;

class StreamBuilderDiagram extends StatefulWidget implements DiagramMetadata {
  const StreamBuilderDiagram(this.name, {this.size = 60});

  @override
  final String name;
  final double size;

  @override
  _StreamBuilderDiagramState createState() => _StreamBuilderDiagramState();
}

class _StreamBuilderDiagramState extends State<StreamBuilderDiagram> {
  Stream<int> _calculation;

  @override
  void initState() {
    if (widget.name == _streamBuilder) {
      _calculation = (() async* {
        await Future<void>.delayed(_pauseDuration);
        await Future<void>.delayed(_pauseDuration);
        yield 1;
        await Future<void>.delayed(_pauseDuration);
        await Future<void>.delayed(_pauseDuration);
      })();
    } else if (widget.name == _streamBuilderError) {
      _calculation = (() async* {
        await Future<void>.delayed(_pauseDuration);
        await Future<void>.delayed(_pauseDuration);
        throw 'Bid Failed';
      })();
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
        child: StreamBuilder<int>(
          stream: _calculation,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            List<Widget> children;

            if (snapshot.hasError) {
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
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  children = <Widget>[
                    Icon(
                      Icons.info,
                      color: Colors.blue,
                      size: widget.size,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Select a lot'),
                    )
                  ];
                  break;
                case ConnectionState.waiting:
                  children = <Widget>[
                    SizedBox(
                      child: const CircularProgressIndicator(),
                      width: widget.size,
                      height: widget.size,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text('Awaiting bids...'),
                    )
                  ];
                  break;
                case ConnectionState.active:
                  children = <Widget>[
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: widget.size,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('\$${snapshot.data}'),
                    )
                  ];
                  break;
                case ConnectionState.done:
                  children = <Widget>[
                    Icon(
                      Icons.info,
                      color: Colors.blue,
                      size: widget.size,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text('\$${snapshot.data} (closed)'),
                    )
                  ];
                  break;
              }
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

class StreamBuilderDiagramStep extends DiagramStep<StreamBuilderDiagram> {
  StreamBuilderDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<StreamBuilderDiagram>> get diagrams async =>
      <StreamBuilderDiagram>[
        const StreamBuilderDiagram(_streamBuilder),
        const StreamBuilderDiagram(_streamBuilderError),
      ];

  @override
  Future<File> generateDiagram(StreamBuilderDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;

    return await controller.drawAnimatedDiagramToFiles(
      end: _totalDuration,
      frameRate: 60,
      name: diagram.name,
      category: category,
    );
  }
}

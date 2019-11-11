// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _scrollViewFixedHeight = 'single_child_scroll_view_fixed';
const String _scrollViewExpanded = 'single_child_scroll_view_expanded';

class SingleChildScrollViewDiagram extends StatefulWidget implements DiagramMetadata {
  const SingleChildScrollViewDiagram({Key key, this.name}) : super(key: key);

  @override
  final String name;

  @override
  State<StatefulWidget> createState() => SingleChildScrollViewDiagramState();
}

class SingleChildScrollViewDiagramState extends State<SingleChildScrollViewDiagram> {
  @override
  Widget build(BuildContext context) {
    Widget returnWidget;
    switch (widget.name) {
      case _scrollViewFixedHeight:
        returnWidget = Scaffold(
          appBar: AppBar(
            title: const Text('Expanding content'),
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        // A fixed-height child.
                        color: Colors.yellow,
                        height: 120.0,
                        child: const Center(child: Text('Fixed-height content')),
                      ),
                      Container(
                        // Another fixed-height child.
                        color: Colors.green,
                        height: 120.0,
                        child: const Center(child: Text('Fixed-height content')),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
        break;
      case _scrollViewExpanded:
        returnWidget = Scaffold(
          appBar: AppBar(
            title: const Text('Center fixed-height content'),
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints viewportConstraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: <Widget>[
                        Container(
                          // A fixed-height child.
                          color: Colors.amber,
                          height: 120.0,
                          child: const Center(child: Text('Fixed-height content')),
                        ),
                        Expanded(
                          // A flexible child that will grow to fit the viewport but
                          // still be at least as big as necessary to fit its contents.
                          child: Container(
                            color: Colors.blue,
                            height: 120.0,
                            child: const Center(child:Text('Expanded content')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
        break;
    }
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 533.33)),
      child: returnWidget,
    );
  }
}

class SingleChildScrollViewDiagramStep extends DiagramStep<SingleChildScrollViewDiagram> {
  SingleChildScrollViewDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<SingleChildScrollViewDiagram>> get diagrams async => <SingleChildScrollViewDiagram>[
        const SingleChildScrollViewDiagram(name: _scrollViewFixedHeight),
        const SingleChildScrollViewDiagram(name: _scrollViewExpanded),
      ];

  @override
  Future<File> generateDiagram(SingleChildScrollViewDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

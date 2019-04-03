// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class _VideoDescription extends StatelessWidget {
  const _VideoDescription({
    Key key,
    this.title,
    this.user,
    this.viewCount,
  }) : super(key: key);

  final String title;
  final String user;
  final int viewCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Text(
            user,
            style: const TextStyle(fontSize: 10.0),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
          Text(
            '$viewCount views',
            style: const TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }
}

/// A sample list item that looks similar to a YouTube related video item.
///
/// Since users are misusing ListTile material widget, this example was created
/// to help provide inspiration for alternative ways to create list items.
class CustomListItem extends StatelessWidget {
  const CustomListItem({
    this.thumbnail,
    this.user,
    this.viewCount,
    this.title,
  });

  final Widget thumbnail;
  final String user;
  final int viewCount;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: thumbnail,
            flex: 2,
          ),
          Expanded(
            child: _VideoDescription(
              title: title,
              user: user,
              viewCount: viewCount,
            ),
            flex: 3,
          ),
          const Icon(
            Icons.more_vert,
            size: 16.0,
          ),
        ],
      ),
    );
  }
}

class CustomListItemDiagram extends StatelessWidget implements DiagramMetadata {
  const CustomListItemDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400.0, 250.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(8.0),
          itemExtent: 106.0,
          children: const <CustomListItem>[
            CustomListItem(
              user: 'Flutter',
              viewCount: 999000,
              thumbnail: Icon(
                Icons.videocam,
                size: 80,
                color: Colors.blueGrey,
              ),
              title: 'The Flutter YouTube Channel',
            ),
            CustomListItem(
              user: 'Dash',
              viewCount: 884000,
              thumbnail:
                Icon(
                  Icons.flight_takeoff,
                  size: 80,
                  color: Colors.blueGrey,
                ),
              title: 'Announcing Flutter 1.0',
            ),
          ],
        ),
      ),
    );
  }
}

class CustomListItemDiagramStep extends DiagramStep {
  CustomListItemDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
        const CustomListItemDiagram('custom_list_item'),
      ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    final CustomListItemDiagram typedDiagram = diagram;
    controller.builder = (BuildContext context) => typedDiagram;
    return await controller.drawDiagramToFile(
      new File('${diagram.name}.png'),
    );
  }
}

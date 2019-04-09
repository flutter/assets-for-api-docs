// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

/// Since users are misusing ListTile material widget, this example was created
/// to help provide inspiration for alternative ways to create list items.

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
class CustomListItem extends StatelessWidget {
  const CustomListItem({
    this.thumbnail,
    this.title,
    this.user,
    this.viewCount,
  });

  final Widget thumbnail;
  final String title;
  final String user;
  final int viewCount;

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

class _ArticleDescription extends StatelessWidget {
  _ArticleDescription({
    Key key,
    this.title,
    this.subtitle,
    this.author,
    this.publishDate,
    this.readDuration,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String author;
  final String publishDate;
  final String readDuration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$title',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Padding(padding: EdgeInsets.only(bottom: 2.0)),
              Text(
                '$subtitle',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          flex: 2,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                '$author',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$publishDate · $readDuration ★',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          flex: 1,
        ),
      ],
    );
  }
}

/// A sample article list item with multi-line [title] and [subtitle]s.
class CustomListItemTwo extends StatelessWidget {
  const CustomListItemTwo({
    Key key,
    this.thumbnail,
    this.title,
    this.subtitle,
    this.author,
    this.publishDate,
    this.readDuration,
  }) : super(key: key);

  final Widget thumbnail;
  final String title;
  final String subtitle;
  final String author;
  final String publishDate;
  final String readDuration;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.0,
              child: thumbnail,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0.0, 2.0, 0.0),
                child: _ArticleDescription(
                  title: title,
                  subtitle: subtitle,
                  author: author,
                  publishDate: publishDate,
                  readDuration: readDuration,
                ),
              ),
            )
          ],
        ),
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
    switch (name) {
      case 'custom_list_item_a':
        return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 235.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              itemExtent: 106.0,
              children: <CustomListItem>[
                CustomListItem(
                  user: 'Flutter',
                  viewCount: 999000,
                  thumbnail: Container(
                    decoration: const BoxDecoration(color: Colors.blue),
                  ),
                  title: 'The Flutter YouTube Channel',
                ),
                CustomListItem(
                  user: 'Dash',
                  viewCount: 884000,
                  thumbnail: Container(
                    decoration: const BoxDecoration(color: Colors.yellow),
                  ),
                  title: 'Announcing Flutter 1.0',
                ),
              ],
            ),
          ),
        );
        break;
      case 'custom_list_item_b':
       return ConstrainedBox(
          key: UniqueKey(),
          constraints: BoxConstraints.tight(const Size(400.0, 265.0)),
          child: Container(
            alignment: FractionalOffset.center,
            padding: const EdgeInsets.all(5.0),
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: <Widget>[
                CustomListItemTwo(
                  thumbnail: Container(
                    decoration: const BoxDecoration(color: Colors.pink),
                  ),
                  title: 'Flutter 1.0 Launch',
                  subtitle:
                    'Flutter continues to improve and expand its horizons.'
                    'This text should max out at two lines and clip',
                  author: 'Dash',
                  publishDate: 'Dec 28',
                  readDuration: '5 mins',
                ),
                CustomListItemTwo(
                  thumbnail: Container(
                    decoration: const BoxDecoration(color: Colors.blue),
                  ),
                  title: 'Flutter 1.2 Release - Continual updates to the framework',
                  subtitle: 'Flutter once again improves and makes updates.',
                  author: 'Flutter',
                  publishDate: 'Feb 26',
                  readDuration: '12 mins',
                ),
              ],
            ),
          ),
       );
        break;
      default:
        return const Text('Error');
        break;
    }
  }
}

class CustomListItemDiagramStep extends DiagramStep {
  CustomListItemDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
    const CustomListItemDiagram('custom_list_item_a'),
    const CustomListItemDiagram('custom_list_item_b'),
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

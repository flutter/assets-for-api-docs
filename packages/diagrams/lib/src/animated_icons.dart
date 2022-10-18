// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String add_event = 'add_event';
const String arrow_menu = 'arrow_menu';
const String close_menu = 'close_menu';
const String ellipsis_search = 'ellipsis_search';
const String event_add = 'event_add';
const String home_menu = 'home_menu';
const String list_view = 'list_view';
const String menu_arrow = 'menu_arrow';
const String menu_close = 'menu_close';
const String menu_home = 'menu_home';
const String pause_play = 'pause_play';
const String play_pause = 'play_pause';
const String search_ellipsis = 'search_ellipsis';
const String view_list = 'view_list';

const Duration _kAnimationDuration = Duration(seconds: 1);

/// A base class for AnimatedIcons diagrams.
class AnimatedIconsDiagram extends StatefulWidget
    with DiagramMetadata {
  const AnimatedIconsDiagram({
    super.key,
    required this.iconName,
    required this.iconData,
  });

  final String iconName;

  final AnimatedIconData iconData;

  @override
  String get name => iconName;

  @override
  Duration? get duration => _kAnimationDuration;

  @override
  AnimatedIconsDiagramState createState() => AnimatedIconsDiagramState();
}

class AnimatedIconsDiagramState extends State<AnimatedIconsDiagram>
    with TickerProviderStateMixin<AnimatedIconsDiagram> {
  late Animation<double> animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _kAnimationDuration,
      vsync: this,
    )..repeat();
    animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xffffffff),
      child: AnimatedBuilder(
        animation: _controller,
        builder:(BuildContext context, Widget? child) {
          return AnimatedIcon(
            size: 72.0,
            progress: animation,
            icon: widget.iconData,
          );
        },
      ),
    );
  }
}


class AnimatedIconsStep extends DiagramStep {
  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => <DiagramMetadata>[
        const AnimatedIconsDiagram(
          iconName: add_event,
          iconData: AnimatedIcons.add_event,
        ),
        const AnimatedIconsDiagram(
          iconName: arrow_menu,
          iconData: AnimatedIcons.arrow_menu,
        ),
        const AnimatedIconsDiagram(
          iconName: close_menu,
          iconData: AnimatedIcons.close_menu,
        ),
        const AnimatedIconsDiagram(
          iconName: ellipsis_search,
          iconData: AnimatedIcons.ellipsis_search,
        ),
        const AnimatedIconsDiagram(
          iconName: event_add,
          iconData: AnimatedIcons.event_add,
        ),
        const AnimatedIconsDiagram(
          iconName: home_menu,
          iconData: AnimatedIcons.home_menu,
        ),
        const AnimatedIconsDiagram(
          iconName: list_view,
          iconData: AnimatedIcons.list_view,
        ),
        const AnimatedIconsDiagram(
          iconName: menu_arrow,
          iconData: AnimatedIcons.menu_arrow,
        ),
        const AnimatedIconsDiagram(
          iconName: menu_close,
          iconData: AnimatedIcons.menu_close,
        ),
        const AnimatedIconsDiagram(
          iconName: menu_home,
          iconData: AnimatedIcons.menu_home,
        ),
        const AnimatedIconsDiagram(
          iconName: pause_play,
          iconData: AnimatedIcons.pause_play,
        ),
        const AnimatedIconsDiagram(
          iconName: play_pause,
          iconData: AnimatedIcons.play_pause,
        ),
        const AnimatedIconsDiagram(
          iconName: search_ellipsis,
          iconData: AnimatedIcons.search_ellipsis,
        ),
        const AnimatedIconsDiagram(
          iconName: view_list,
          iconData: AnimatedIcons.view_list,
        ),
      ];
}

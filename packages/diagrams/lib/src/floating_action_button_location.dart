// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _namePrefix = 'floating_action_button_location';

const String _centerDocked = '_center_docked';
const String _centerFloat = '_center_float';
const String _centerTop = '_center_top';

const String _endDocked = '_end_docked';
const String _endFloat = '_end_float';
const String _endTop = '_end_top';

const String _miniCenterDocked = '_mini_center_docked';
const String _miniCenterFloat = '_mini_center_float';
const String _miniCenterTop = '_mini_center_top';

const String _miniEndDocked = '_mini_end_docked';
const String _miniEndFloat = '_mini_end_float';
const String _miniEndTop = '_mini_end_top';

const String _miniStartDocked = '_mini_start_docked';
const String _miniStartFloat = '_mini_start_float';
const String _miniStartTop = '_mini_start_top';

const String _startDocked = '_start_docked';
const String _startFloat = '_start_float';
const String _startTop = '_start_top';

class FloatingActionButtonLocationDiagram extends StatelessWidget implements DiagramMetadata {
  const FloatingActionButtonLocationDiagram(this.nameSuffix, {Key? key}) : super(key: key);

  final String nameSuffix;

  @override
  String get name => _namePrefix + nameSuffix;

  String get appBarTitle {
    switch (nameSuffix) {
      case _centerDocked:
        return 'FAB center docked';
      case _centerFloat:
        return 'FAB center float';
      case _centerTop:
        return 'FAB center top';
      case _endDocked:
        return 'FAB end docked';
      case _endFloat:
        return 'FAB end float';
      case _endTop:
        return 'FAB end top';
      case _miniCenterDocked:
        return 'FAB mini center docked';
      case _miniCenterFloat:
        return 'FAB mini center float';
      case _miniCenterTop:
        return 'FAB mini center top';
      case _miniEndDocked:
        return 'FAB mini end docked';
      case _miniEndFloat:
        return 'FAB mini end float';
      case _miniEndTop:
        return 'FAB mini end top';
      case _miniStartDocked:
        return 'FAB mini start docked';
      case _miniStartFloat:
        return 'FAB mini start float';
      case _miniStartTop:
        return 'FAB mini start top';
      case _startDocked:
        return 'FAB start docked';
      case _startFloat:
        return 'FAB start float';
      default:
        return 'FAB start top';
    }
  }

  FloatingActionButtonLocation get fabLocation {
    switch (nameSuffix) {
      case _centerDocked:
        return FloatingActionButtonLocation.centerDocked;
      case _centerFloat:
        return FloatingActionButtonLocation.centerFloat;
      case _centerTop:
        return FloatingActionButtonLocation.centerTop;
      case _endDocked:
        return FloatingActionButtonLocation.endDocked;
      case _endFloat:
        return FloatingActionButtonLocation.endFloat;
      case _endTop:
        return FloatingActionButtonLocation.endTop;
      case _miniCenterDocked:
        return FloatingActionButtonLocation.miniCenterDocked;
      case _miniCenterFloat:
        return FloatingActionButtonLocation.miniCenterFloat;
      case _miniCenterTop:
        return FloatingActionButtonLocation.miniCenterTop;
      case _miniEndDocked:
        return FloatingActionButtonLocation.miniEndDocked;
      case _miniEndFloat:
        return FloatingActionButtonLocation.miniEndFloat;
      case _miniEndTop:
        return FloatingActionButtonLocation.miniEndTop;
      case _miniStartDocked:
        return FloatingActionButtonLocation.miniStartDocked;
      case _miniStartFloat:
        return FloatingActionButtonLocation.miniStartFloat;
      case _miniStartTop:
        return FloatingActionButtonLocation.miniStartTop;
      case _startDocked:
        return FloatingActionButtonLocation.startDocked;
      case _startFloat:
        return FloatingActionButtonLocation.startFloat;
      default:
        return FloatingActionButtonLocation.startTop;
    }
  }

  bool get isMini => nameSuffix.contains('mini');

  @override
  Widget build(BuildContext context) {
    final Widget returnWidget = Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: const Center(
          child: Text('Press the button below!')
      ),
      floatingActionButtonLocation: fabLocation,
      floatingActionButton: FloatingActionButton(
        mini: isMini,
        onPressed: () {},
        child: const Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_outlined),label: 'You'),
          BottomNavigationBarItem(icon: Icon(Icons.add_alarm_outlined),label: 'Alarm'),
        ],
      ),
    );

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(300.0, 533.33)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Center(child: returnWidget),
      ),
    );
  }
}

class FloatingActionButtonLocationDiagramStep extends DiagramStep<FloatingActionButtonLocationDiagram> {
  FloatingActionButtonLocationDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<FloatingActionButtonLocationDiagram>> get diagrams async => <FloatingActionButtonLocationDiagram>[
        const FloatingActionButtonLocationDiagram(_centerDocked),
        const FloatingActionButtonLocationDiagram(_centerFloat),
        const FloatingActionButtonLocationDiagram(_centerTop),
        const FloatingActionButtonLocationDiagram(_endDocked),
        const FloatingActionButtonLocationDiagram(_endFloat),
        const FloatingActionButtonLocationDiagram(_endTop),
        const FloatingActionButtonLocationDiagram(_miniCenterDocked),
        const FloatingActionButtonLocationDiagram(_miniCenterFloat),
        const FloatingActionButtonLocationDiagram(_miniCenterTop),
        const FloatingActionButtonLocationDiagram(_miniEndDocked),
        const FloatingActionButtonLocationDiagram(_miniEndFloat),
        const FloatingActionButtonLocationDiagram(_miniEndTop),
        const FloatingActionButtonLocationDiagram(_miniStartDocked),
        const FloatingActionButtonLocationDiagram(_miniStartFloat),
        const FloatingActionButtonLocationDiagram(_miniStartTop),
        const FloatingActionButtonLocationDiagram(_startDocked),
        const FloatingActionButtonLocationDiagram(_startFloat),
        const FloatingActionButtonLocationDiagram(_startTop),
      ];

  @override
  Future<File> generateDiagram(FloatingActionButtonLocationDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

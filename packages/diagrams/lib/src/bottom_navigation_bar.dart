// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'diagram_step.dart';

class BottomNavigationBarDiagram extends StatelessWidget with DiagramMetadata {
  const BottomNavigationBarDiagram(this.name, {super.key});

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(350, 600)),
      child: Container(
        alignment: FractionalOffset.center,
        //padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('BottomNavigationBar Sample'),
          ),
          body: const Center(
            child: Text(
              'Index 0: Home',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business),
                label: 'Business',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'School',
              ),
            ],
            selectedItemColor: Colors.amber[800],
          ),
        ),
      ),
    );
  }
}

class BottomNavigationBarDiagramStep extends DiagramStep {
  @override
  final String category = 'material';

  @override
  Future<List<BottomNavigationBarDiagram>> get diagrams async =>
      <BottomNavigationBarDiagram>[
        const BottomNavigationBarDiagram('bottom_navigation_bar'),
      ];
}

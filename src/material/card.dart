// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() {
  final GlobalKey key = new GlobalKey();
  runApp(
    new MaterialApp(
      home: new Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(40.0),
        color: Colors.white,
        child: new Card(
          key: key,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: const Icon(Icons.album),
                title: const Text('The Enchanted Nightingale'),
                subtitle: const Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
              ),
              new ButtonTheme.bar(
                // make buttons use the appropriate styles for cards
                child: new ButtonBar(
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('BUY TICKETS'),
                      onPressed: () {},
                    ),
                    new FlatButton(
                      child: const Text('LISTEN'),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  new Timer(const Duration(seconds: 1), () {
    print('The following commands extract out the six images from a screenshot file.');
    print('You can obtain a screenshot by pressing "s" in the "flutter run" console.');
    final RenderBox box = key.currentContext.findRenderObject();
    final Rect area = ((box.localToGlobal(Offset.zero) * ui.window.devicePixelRatio) &
        (box.size * ui.window.devicePixelRatio)).inflate(40.0);
    print('COMMAND: convert flutter_01.png '
        '-crop ${area.width}x${area.height}+${area.left}+${area.top} '
        '-resize \'400x400>\' card.png');
    print('DONE DRAWING');
  });
}

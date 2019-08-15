// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

const String _bold = 'text_style_bold';
const String _italics = 'text_style_italics';
const String _opacityAndColor = 'text_style_opacity_and_color';
const String _size = 'text_style_size';
const String _wavyUnderline = 'text_style_wavy_red_underline';
const String _customFonts = 'text_style_custom_fonts';

class TextStyleDiagram extends StatelessWidget implements DiagramMetadata {
  const TextStyleDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _bold:
        returnWidget = const Text(
          'No, we need bold strokes. We need this plan.',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
        break;
      case _italics:
        returnWidget = const Text(
          'Welcome to the present, we\'re running a real nation.',
          style: TextStyle(fontStyle: FontStyle.italic),
        );
        break;
      case _opacityAndColor:
        returnWidget = RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: 'You don\'t have the votes.\n',
                style: TextStyle(color: Colors.black.withOpacity(0.6)),
              ),
              TextSpan(
                text: 'You don\'t have the votes!\n',
                style: TextStyle(color: Colors.black.withOpacity(0.8)),
              ),
              TextSpan(
                text: 'You\'re gonna need congressional approval and you don\'t have the votes!\n',
                style: TextStyle(color: Colors.black.withOpacity(1.0)),
              ),
            ],
          ),
        );
        break;
      case _size:
        returnWidget = Text(
          'These are wise words, enterprising men quote \'em.',
          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
        );
        break;
      case _wavyUnderline:
        returnWidget = RichText(
          text: TextSpan(
            text: 'Don\'t tax the South ',
            style: const TextStyle(color: Colors.black),
            children: <TextSpan>[
              TextSpan(
                text: 'cuz',
                style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.red,
                  decorationStyle: TextDecorationStyle.wavy,
                ),
              ),
              const TextSpan(
                text: ' we got it made in the shade.',
              ),
            ],
          ),
        );
        break;
      case _customFonts:
        returnWidget = const Text(
          'Look, when Britain taxed our tea, we got frisky.',
          style: TextStyle(fontFamily: 'Raleway'),
        );
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(300.0, 120.0)),
      child: Container(
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: Center(child: returnWidget),
      ),
    );
  }
}

class TextStyleDiagramStep extends DiagramStep<TextStyleDiagram> {
  TextStyleDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'painting';

  @override
  Future<List<TextStyleDiagram>> get diagrams async => <TextStyleDiagram>[
        const TextStyleDiagram(_bold),
        const TextStyleDiagram(_italics),
        const TextStyleDiagram(_opacityAndColor),
        const TextStyleDiagram(_size),
        const TextStyleDiagram(_wavyUnderline),
        const TextStyleDiagram(_customFonts),
      ];

  @override
  Future<File> generateDiagram(TextStyleDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

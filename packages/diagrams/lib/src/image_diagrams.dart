// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

class ImageDiagramStep extends DiagramStep<ImageWidgetDiagram> {
  ImageDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<ImageWidgetDiagram>> get diagrams async => <ImageWidgetDiagram>[
        const ImageWidgetDiagram(_image),
        const ImageWidgetDiagram(_imageMemory),
        const ImageWidgetDiagram(_imageNetwork),
        const ImageWidgetDiagram(_imageAsset),
        const ImageWidgetDiagram(_imageFile),
      ];

  @override
  Future<File> generateDiagram(ImageWidgetDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

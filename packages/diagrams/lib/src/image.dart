// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'animation_diagram.dart';
import 'diagram_step.dart';

class DiagramImage extends ImageProvider<DiagramImage> implements ui.Codec, ui.FrameInfo {
  DiagramImage(
    this.image, {
    this.duration = const Duration(seconds: 1),
    this.vsync,
    this.scale = 1.0,
  });

  @override
  final ui.Image image;

  @override
  final Duration duration;

  final TickerProvider vsync;
  final double scale;
  final StreamController<ImageChunkEvent> chunkEvents = StreamController<ImageChunkEvent>();

  static const int _totalBytes = 1024;

  @override
  Future<DiagramImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<DiagramImage>(this);
  }

  @override
  ImageStreamCompleter load(DiagramImage key) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(),
      chunkEvents: chunkEvents.stream,
      scale: scale,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>('Image provider', this);
      },
    );
  }

  Future<ui.Codec> _loadAsync() {
    final Completer<ui.Codec> result = Completer<ui.Codec>();
    final AnimationController controller = AnimationController(vsync: vsync, duration: duration);
    controller.addListener(() {
      if (controller.status == AnimationStatus.completed) {
        controller.dispose();
        result.complete(this);
      } else {
        final double percentComplete = controller.value / controller.upperBound;
        chunkEvents.add(ImageChunkEvent(
          cumulativeBytesLoaded: (percentComplete * _totalBytes).floor(),
          expectedTotalBytes: _totalBytes,
        ));
      }
    });
    controller.animateTo(controller.upperBound);
    return result.future;
  }

  @override
  void dispose() {}

  @override
  int get frameCount => 1;

  @override
  int get repetitionCount => 0;

  @override
  Future<ui.FrameInfo> getNextFrame() async {
    return this;
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType)
      return false;
    final DiagramImage typedOther = other;
    return image == typedOther.image
        && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(image, scale);
}

class ImageDiagramsStep extends DiagramStep<ImageDiagram> {
  ImageDiagramsStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<ImageDiagram>> get diagrams async => const <ImageDiagram>[
  ];

  @override
  Future<File> generateDiagram(ImageDiagram diagram) async {
    controller.builder = (BuildContext context) {
      return SizedBox(
        width: diagram.imageSize.width,
        height: diagram.imageSize.height,
        child: const FlutterLogo(),
      );
    };
    final ui.Image image = await controller.drawDiagramToImage();

    final ImageProvider imageProvider = DiagramImage(
      image,
      vsync: controller.vsync,
    );

    controller.builder = (BuildContext context) => diagram.build(context, imageProvider);

    return await controller.drawAnimatedDiagramToFiles(
      end: diagram.duration,
      frameRate: diagram.frameRate,
      name: diagram.name,
      category: category,
    );
  }
}

@immutable
abstract class ImageDiagram implements DiagramMetadata {
  const ImageDiagram();

  @override
  String get name => getName(runtimeType);

  Size get imageSize => const Size(300, 300);

  Duration get duration => const Duration(seconds: 2);

  double get frameRate => 60;

  Widget build(BuildContext context, ImageProvider image);
}


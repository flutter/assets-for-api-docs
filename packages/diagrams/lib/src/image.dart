// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
        chunkEvents.add(ImageChunkEvent((percentComplete * _totalBytes).floor(), _totalBytes));
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

class LoadingProgressImageDiagram extends StatelessWidget {
  const LoadingProgressImageDiagram({
    this.diagram,
    this.provider,
  });

  final DiagramMetadata diagram;
  final ImageProvider provider;

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: new BoxConstraints.tight(const Size(400, 400)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image(
            image: provider,
            imageLoadingBuilder: (BuildContext context, ImageChunkEvent event, Widget currentRawImage) {
              return Center(
                child: CircularProgressIndicator(
                  value: event.cumulativeBytesLoaded / event.expectedTotalBytes,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LoadingProgressImageDiagramStep extends DiagramStep {
  LoadingProgressImageDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<DiagramMetadata>> get diagrams async => const <DiagramMetadata>[
    _LoadingProgressDiagramMetadata(),
  ];

  @override
  Future<File> generateDiagram(DiagramMetadata diagram) async {
    controller.builder = (BuildContext context) {
      return const SizedBox(
        width: 300,
        height: 300,
        child: FlutterLogo(),
      );
    };
    final ui.Image image = await controller.drawDiagramToImage();

    final DiagramImage provider = DiagramImage(
      image,
      vsync: controller.vsync,
    );

    controller.builder = (BuildContext context) => LoadingProgressImageDiagram(
      diagram: diagram,
      provider: provider,
    );

    return await controller.drawAnimatedDiagramToFiles(
      end: const Duration(seconds: 2),
      frameRate: 60,
      name: diagram.name,
      category: category,
    );
  }
}

class _LoadingProgressDiagramMetadata implements DiagramMetadata {
  const _LoadingProgressDiagramMetadata();

  @override
  String get name => 'image_loadingProgress';
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

@immutable
class DiagramImage extends ImageProvider<DiagramImage>
    implements ui.Codec, ui.FrameInfo {
  DiagramImage(
    this.image, {
    required this.vsync,
    this.loadingDuration,
    this.scale = 1.0,
  });

  @override
  final ui.Image image;

  final Duration? loadingDuration;
  final TickerProvider vsync;
  final double scale;
  final StreamController<ImageChunkEvent> chunkEvents =
      StreamController<ImageChunkEvent>();

  static const int _totalBytes = 1024;

  @override
  Future<DiagramImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<DiagramImage>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
      DiagramImage key, DecoderBufferCallback decode) {
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
    if (loadingDuration == null) {
      return Future<ui.Codec>.value(this);
    }

    final Completer<ui.Codec> result = Completer<ui.Codec>();
    final AnimationController controller = AnimationController(
      vsync: vsync,
      duration: loadingDuration,
    );
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
  Duration get duration => const Duration(seconds: 1);

  @override
  Future<ui.FrameInfo> getNextFrame() async {
    return this;
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    // ignore: test_types_in_equals
    final DiagramImage typedOther = other as DiagramImage;
    return image == typedOther.image && scale == typedOther.scale;
  }

  @override
  int get hashCode => Object.hash(image, scale);
}

class FrameBuilderImageDiagram extends StatelessWidget {
  const FrameBuilderImageDiagram({super.key, required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      frameBuilder: (
        BuildContext context,
        Widget child,
        int? frame,
        bool wasSynchronouslyLoaded,
      ) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeOut,
          child: child,
        );
      },
    );
  }
}

class LoadingProgressImageDiagram extends StatelessWidget {
  const LoadingProgressImageDiagram({super.key, required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!,
          ),
        );
      },
    );
  }
}

class ImageDiagram extends StatefulWidget with DiagramMetadata {
  const ImageDiagram({
    super.key,
    required this.name,
    required this.image,
    required this.loadingDuration,
    required this.shownDuration,
    required this.builder,
  });

  @override
  final String name;

  final ui.Image image;

  final Duration loadingDuration;
  final Duration shownDuration;

  @override
  Duration get duration => loadingDuration + shownDuration;

  final Widget Function(BuildContext context, ImageProvider image) builder;

  @override
  State<ImageDiagram> createState() => _ImageDiagramState();
}

class _ImageDiagramState extends State<ImageDiagram>
    with TickerProviderStateMixin {
  late final DiagramImage provider = DiagramImage(
    widget.image,
    vsync: this,
    loadingDuration: widget.loadingDuration,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints.tight(const Size(400, 400)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(20),
          ),
          child: widget.builder(context, provider),
        ),
      ),
    );
  }
}

class ImageDiagramsStep extends DiagramStep {
  @override
  final String category = 'widgets';

  static Future<ui.Image> renderFlutterLogo(int width, int height) {
    final BoxPainter boxPainter =
        const FlutterLogoDecoration().createBoxPainter();
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    boxPainter.paint(
      ui.Canvas(recorder),
      Offset.zero,
      ImageConfiguration(
        size: Size(
          width.toDouble(),
          height.toDouble(),
        ),
      ),
    );
    final ui.Picture picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  @override
  Future<List<DiagramMetadata>> get diagrams async {
    return <DiagramMetadata>[
      ImageDiagram(
        name: 'frame_builder_image',
        image: await renderFlutterLogo(300, 300),
        shownDuration: const Duration(seconds: 4),
        loadingDuration: const Duration(milliseconds: 500),
        builder: (BuildContext context, ImageProvider image) =>
            FrameBuilderImageDiagram(image: image),
      ),
      ImageDiagram(
        name: 'loading_progress_image',
        image: await renderFlutterLogo(300, 300),
        shownDuration: const Duration(seconds: 1),
        loadingDuration: const Duration(seconds: 2),
        builder: (BuildContext context, ImageProvider image) =>
            LoadingProgressImageDiagram(image: image),
      ),
    ];
  }
}

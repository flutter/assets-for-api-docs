// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Demonstrates the effect of `FilterQuality` by scaling the Flutter logo
// up and down at different quality levels.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'diagram_step.dart';

const int _originalWidth = 60;
const int _originalHeight = 60;
late final ui.Image _originalImage;

List<ui.Picture> _scaledSamples = <ui.Picture>[];

typedef _Painter = void Function(ui.Canvas canvas);

// We're trying to demonstrate the effect of `FilterQuality` on bitmap images,
// so we have to first rasterize the sample image (e.g. we can't use
// `Picture`).
Future<void> _generateSamples() async {
  _originalImage = await _paint((ui.Canvas canvas) {
    const FlutterLogoDecoration flutterLogoDecoration = FlutterLogoDecoration();
    final BoxPainter flutterLogoPainter =
        flutterLogoDecoration.createBoxPainter();
    flutterLogoPainter.paint(
        canvas,
        Offset.zero,
        const ImageConfiguration(
          size: Size(60, 60),
        ));
  }).toImage(_originalWidth, _originalHeight);

  _scaledSamples
      .add(await _paintScaledSample(1.0, 'original', FilterQuality.none));
  _scaledSamples
      .add(await _paintScaledSample(0.3, '0.3x @ none', FilterQuality.none));
  _scaledSamples
      .add(await _paintScaledSample(0.3, '0.3x @ low', FilterQuality.low));
  _scaledSamples.add(
      await _paintScaledSample(0.3, '0.3x @ medium', FilterQuality.medium));
  _scaledSamples
      .add(await _paintScaledSample(0.3, '0.3x @ high', FilterQuality.high));

  _scaledSamples
      .add(await _paintScaledSample(2.3, '2.3x @ none', FilterQuality.none));
  _scaledSamples
      .add(await _paintScaledSample(2.3, '2.3x @ low', FilterQuality.low));
  _scaledSamples.add(
      await _paintScaledSample(2.3, '2.3x @ medium', FilterQuality.medium));
  _scaledSamples
      .add(await _paintScaledSample(2.3, '2.3x @ high', FilterQuality.high));
}

ui.Picture _paint(_Painter painter) {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);
  painter(canvas);
  return recorder.endRecording();
}

Future<ui.Picture> _paintScaledSample(
    double scale, String label, FilterQuality quality) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder);

  final ui.ParagraphBuilder builder = ui.ParagraphBuilder(ui.ParagraphStyle());
  builder.pushStyle(ui.TextStyle(
    color: const Color(0xFF000000),
    fontSize: 18,
  ));
  builder.addText(label);
  final ui.Paragraph paragraph = builder.build();
  paragraph.layout(const ui.ParagraphConstraints(width: 1000));
  canvas.drawParagraph(paragraph, Offset.zero);
  canvas.translate(0, paragraph.height + 10);

  if (scale == 1.0) {
    // Don't scale. We want the original look of the image.
    canvas.drawImage(
        _originalImage, Offset.zero, Paint()..filterQuality = quality);
  } else {
    final ui.Picture pictureOfImage = _paint((ui.Canvas canvas) {
      canvas.scale(scale);
      canvas.drawImage(
          _originalImage, Offset.zero, Paint()..filterQuality = quality);
    });
    final ui.Image scaledImage = await pictureOfImage.toImage(
      (_originalWidth * scale).toInt(),
      (_originalHeight * scale).toInt(),
    );
    canvas.save();
    if (scale < 1.0) {
      // It's hard to see the difference between different quality levels when
      // scaling down the sample image, so we scale it back up with quality none
      // to see the final pixels.
      canvas.scale(1 / scale);
    }

    // The scaled image already applies the filter. Here we want to see the
    // pixels exactly like in the bitmap.
    canvas.drawImage(
        scaledImage, Offset.zero, Paint()..filterQuality = FilterQuality.none);
    canvas.restore();
  }

  return recorder.endRecording();
}

class FilterQualityDiagram extends StatelessWidget implements DiagramMetadata {
  const FilterQualityDiagram({super.key});

  @override
  String get name => 'filter_quality';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 740,
      height: 300,
      child: CustomPaint(
        painter: _FilterQualityPainter(),
      ),
    );
  }
}

class _FilterQualityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(10, 10);

    const int columnCount = 5;
    const double columnWidth = 150;
    const double rowHeight = 100;

    for (int i = 0; i < _scaledSamples.length; i++) {
      final ui.Picture sample = _scaledSamples[i];
      canvas.drawPicture(sample);
      if (i % columnCount == columnCount - 1) {
        canvas.translate(-(columnCount - 1) * columnWidth, rowHeight);
      } else {
        canvas.translate(columnWidth, 0);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class FilterQualityDiagramStep extends DiagramStep<FilterQualityDiagram> {
  FilterQualityDiagramStep(super.controller);

  @override
  final String category = 'dart-ui';

  @override
  Future<List<FilterQualityDiagram>> get diagrams async =>
      <FilterQualityDiagram>[const FilterQualityDiagram()];

  @override
  Future<File> generateDiagram(FilterQualityDiagram diagram) async {
    await _generateSamples();
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

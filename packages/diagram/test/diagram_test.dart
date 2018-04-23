// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import '../lib/diagram.dart';
import 'package:test/test.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;

Widget buildStaticDiagram(BuildContext context) {
  return new Container(
    constraints: new BoxConstraints.tight(new Size(100.0, 50.0)),
    child: new Text('Diagram'),
  );
}

File filenameGenerator(Duration timestamp, int index) {
  return new File('test_name_${timestamp.inMilliseconds}_$index.png');
}

class TestAnimatedDiagram extends StatefulWidget {
  TestAnimatedDiagram({Key key, this.size: 1.0}) : super(key: key);

  final double size;

  _TestAnimatedDiagramState createState() => new _TestAnimatedDiagramState();
}

class _TestAnimatedDiagramState extends State<TestAnimatedDiagram> {
  Widget build(BuildContext context) {
    return new AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: widget.size,
      height: widget.size,
      decoration: new ShapeDecoration(
        shape: const BeveledRectangleBorder(
          borderRadius: const BorderRadius.all(const Radius.circular(10.0)),
        ),
        color: Color(0xfeedbeef),
      ),
    );
  }
}

void main() {
  group('DiagramController', () {
    Directory outputDir;

    setUp(() async {
      outputDir = Directory.systemTemp.createTempSync();
    });

    tearDown(() {
      outputDir?.delete(recursive: true);
    });

    test('can create an image from a static widget', () async {
      DiagramController controller = new DiagramController(
        builder: buildStaticDiagram,
        outputDirectory: outputDir,
        frameFilenameGenerator: filenameGenerator,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      ui.Image captured = await controller.drawDiagramToImage();
      expect(captured.width, equals(100));
      expect(captured.height, equals(50));
      ByteData output = await captured.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(output.lengthInBytes, equals(20000));
    });

    test('can write an image from static widget to a file', () async {
      DiagramController controller = new DiagramController(
        builder: buildStaticDiagram,
        outputDirectory: outputDir,
        frameFilenameGenerator: filenameGenerator,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      File outputFile = new File('test.png');
      File actualOutputFile = await controller.drawDiagramToFile(outputFile);
      expect(actualOutputFile.existsSync(), isTrue);
      List<int> imageContents = actualOutputFile.readAsBytesSync();
      image.Image decodedImage = image.decodePng(imageContents);
      expect(decodedImage.width, equals(100));
      expect(decodedImage.height, equals(50));
      expect(decodedImage.length, equals(5000));
      expect(decodedImage[decodedImage.index(50, 10)], equals(0xdd000000)); // Check a pixel value
    });

    test('can create images from an animated widget', () async {
      UniqueKey key = new UniqueKey();
      DiagramController controller = new DiagramController(
        builder: (BuildContext context) => new TestAnimatedDiagram(key: key, size: 1.0),
        outputDirectory: outputDir,
        frameFilenameGenerator: filenameGenerator,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      controller.builder = (BuildContext context) => new TestAnimatedDiagram(key: key, size: 50.0);
      List<ui.Image> outputImages = await controller.drawAnimatedDiagramToImages(
        end: const Duration(milliseconds: 1200),
        frameDuration: const Duration(milliseconds: 200),
      );
      expect(outputImages.length, equals(7));
      List<int> expectedSizes = <int>[1, 11, 21, 31, 41, 50, 50];
      int count = 0;
      for (ui.Image capturedImage in outputImages) {
        expect(capturedImage.width, equals(expectedSizes[count]));
        expect(capturedImage.height, equals(expectedSizes[count]));
        ++count;
      }
    });

    test('can write images from an animated widget to files', () async {
      UniqueKey key = new UniqueKey();
      DiagramController controller = new DiagramController(
        builder: (BuildContext context) => new TestAnimatedDiagram(key: key, size: 1.0),
        outputDirectory: outputDir,
        frameFilenameGenerator: filenameGenerator,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      controller.builder = (BuildContext context) => new TestAnimatedDiagram(key: key, size: 50.0);
      List<File> outputFiles = await controller.drawAnimatedDiagramToFiles(
        end: const Duration(milliseconds: 1200),
        frameDuration: const Duration(milliseconds: 200),
      );
      expect(outputFiles.length, equals(7));
      expect(outputFiles[0].path.endsWith('test_name_0_0.png'), isTrue);
      expect(outputFiles[6].path.endsWith('test_name_1200_6.png'), isTrue);
      List<int> expectedSizes = <int>[1, 11, 21, 31, 41, 50, 50];
      int count = 0;
      for (File file in outputFiles) {
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), greaterThan(0));
        List<int> imageContents = file.readAsBytesSync();
        image.Image decodedImage = image.decodePng(imageContents);
        expect(decodedImage.width, equals(expectedSizes[count]));
        expect(decodedImage.height, equals(expectedSizes[count]));
        ++count;
      }
    });

    test('can create images larger than the logical screen size', () async {
      DiagramController controller = new DiagramController(
        builder: buildStaticDiagram,
        outputDirectory: outputDir,
        frameFilenameGenerator: filenameGenerator,
        pixelRatio: 3.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      File outputFile = new File('test.png');
      File actualOutputFile = await controller.drawDiagramToFile(outputFile);
      expect(actualOutputFile.existsSync(), isTrue);
      List<int> imageContents = actualOutputFile.readAsBytesSync();
      image.Image decodedImage = image.decodePng(imageContents);
      expect(decodedImage.width, equals(300));
      expect(decodedImage.height, equals(150));
      expect(decodedImage.length, equals(45000));
      expect(decodedImage[decodedImage.index(150, 30)], equals(0xdd000000)); // Check a pixel value
    });
  });
}

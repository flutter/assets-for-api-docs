// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:path/path.dart' as path;
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:image/image.dart' as image;

Widget buildStaticDiagram(BuildContext context) {
  return Container(
    constraints: BoxConstraints.tight(const Size(100.0, 50.0)),
    child: const Text('Diagram'),
  );
}

class TestAnimatedDiagram extends StatelessWidget {
  const TestAnimatedDiagram({Key? key, this.size = 1.0}) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: size,
      height: size,
      decoration: const ShapeDecoration(
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        color: Color(0xfeedbeef),
      ),
    );
  }
}

class TestTappableDiagram extends StatefulWidget {
  @override
  _TestTappableDiagramState createState() => _TestTappableDiagramState();
}

class _TestTappableDiagramState extends State<TestTappableDiagram> {
  bool on = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const SizedBox.shrink(),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color?>(on ? Colors.red : Colors.blue),
      ),
      onPressed: () {
        setState(() {
          on = !on;
        });
      },
    );
  }
}

void main() {
  group('DiagramController', () {
    late Directory outputDir;

    setUp(() async {
      outputDir = Directory.systemTemp.createTempSync('flutter_diagram_capture_test.');
    });

    tearDown(() {
      outputDir.delete(recursive: true);
    });

    test('can create an image from a static widget', () async {
      final DiagramController controller = DiagramController(
        builder: buildStaticDiagram,
        outputDirectory: outputDir,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      final ui.Image captured = await controller.drawDiagramToImage();
      expect(captured.width, equals(100));
      expect(captured.height, equals(50));
      final ByteData? output = await captured.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(output!.lengthInBytes, equals(20000));
    });

    test('allows a null builder', () async {
      final DiagramController controller = DiagramController(
        builder: null,
        outputDirectory: outputDir,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      final ui.Image captured = await controller.drawDiagramToImage();
      expect(captured.width, equals(100));
      expect(captured.height, equals(50));
      final ByteData? output = await captured.toByteData(format: ui.ImageByteFormat.rawRgba);
      expect(output!.lengthInBytes, equals(20000));
    });

    test('can write an image from static widget to a file', () async {
      final DiagramController controller = DiagramController(
        builder: buildStaticDiagram,
        outputDirectory: outputDir,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      final File outputFile = File('test1.png');
      final File actualOutputFile = await controller.drawDiagramToFile(outputFile);
      expect(actualOutputFile.existsSync(), isTrue);
      final List<int> imageContents = actualOutputFile.readAsBytesSync();
      final image.Image decodedImage = image.decodePng(imageContents)!;
      expect(decodedImage.width, equals(100));
      expect(decodedImage.height, equals(50));
      expect(decodedImage.length, equals(5000));
      expect(decodedImage[decodedImage.index(50, 10)], equals(0xdd000000)); // Check a pixel value
    });

    test('can create images from an animated widget', () async {
      final UniqueKey key = UniqueKey();
      final DiagramController controller = DiagramController(
        builder: (BuildContext context) => TestAnimatedDiagram(key: key, size: 1.0),
        outputDirectory: outputDir,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      controller.builder = (BuildContext context) => TestAnimatedDiagram(key: key, size: 50.0);
      final List<ui.Image> outputImages = await controller.drawAnimatedDiagramToImages(
        end: const Duration(milliseconds: 1200),
        frameDuration: const Duration(milliseconds: 200),
      );
      expect(outputImages.length, equals(7));
      final List<int> expectedSizes = <int>[1, 11, 21, 31, 41, 50, 50];
      for (int i = 0; i < outputImages.length; i++) {
        final ui.Image capturedImage = outputImages[i];
        expect(capturedImage.width, equals(expectedSizes[i]));
        expect(capturedImage.height, equals(expectedSizes[i]));
      }
    });

    test('can write images from an animated widget to files', () async {
      final UniqueKey key = UniqueKey();
      final DiagramController controller = DiagramController(
        builder: (BuildContext context) => TestAnimatedDiagram(key: key, size: 1.0),
        outputDirectory: outputDir,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      controller.builder = (BuildContext context) => TestAnimatedDiagram(key: key, size: 50.0);
      final File outputFile = await controller.drawAnimatedDiagramToFiles(
        end: const Duration(milliseconds: 1200),
        frameRate: 5.0,
        name: 'test_name',
      );
      expect(outputFile.path.endsWith('test_name.json'), isTrue);
      int count = 0;
      expect(outputFile.existsSync(), isTrue);
      expect(outputFile.lengthSync(), greaterThan(0));

      Map<String, dynamic> _loadMetadata(File metadataFile) {
        final Map<String, dynamic> metadata = json.decode(metadataFile.readAsStringSync()) as Map<String, dynamic>;
        final String baseDir = path.dirname(metadataFile.absolute.path);
        final List<File> frameFiles = metadata['frame_files']
            .map<File>((dynamic name) => File(path.normalize(path.join(baseDir, name as String)))).toList() as List<File>;
        metadata['frame_files'] = frameFiles;
        return metadata;
      }
      final Map<String, dynamic> metadata = _loadMetadata(outputFile);
      final List<File> frames = metadata['frame_files'] as List<File>;
      expect(frames.length, equals(7));
      expect(frames[0].path, endsWith('test_name_00000.png'));
      final List<int> expectedSizes = <int>[1, 11, 21, 31, 41, 50, 50];
      for (final File file in frames) {
        expect(file.existsSync(), isTrue);
        expect(file.lengthSync(), greaterThan(0));
        final List<int> imageContents = file.readAsBytesSync();
        final image.Image decodedImage = image.decodePng(imageContents)!;
        expect(decodedImage.width, equals(expectedSizes[count]));
        expect(decodedImage.height, equals(expectedSizes[count]));
        ++count;
      }
    });

    test('can create images larger than the logical screen size', () async {
      final DiagramController controller = DiagramController(
        builder: buildStaticDiagram,
        outputDirectory: outputDir,
        pixelRatio: 3.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      final File outputFile = File('test2.png');
      final File actualOutputFile = await controller.drawDiagramToFile(outputFile);
      expect(actualOutputFile.existsSync(), isTrue);
      final List<int> imageContents = actualOutputFile.readAsBytesSync();
      final image.Image decodedImage = image.decodePng(imageContents)!;
      expect(decodedImage.width, equals(300));
      expect(decodedImage.height, equals(150));
      expect(decodedImage.length, equals(45000));
      expect(decodedImage[decodedImage.index(150, 20)], equals(0xdd000000)); // Check a pixel value
    });

    test('can inject gestures', () async {
      final DiagramController controller = DiagramController(
        builder: (BuildContext context) => TestTappableDiagram(),
        outputDirectory: outputDir,
        pixelRatio: 1.0,
        screenDimensions: const Size(100.0, 100.0),
      );

      final File outputFile = File('test3.png');
      File actualOutputFile = await controller.drawDiagramToFile(outputFile);
      List<int> imageContents = actualOutputFile.readAsBytesSync();
      image.Image decodedImage = image.decodePng(imageContents)!;
      expect(decodedImage.width, equals(64));
      expect(decodedImage.height, equals(48));
      expect(decodedImage[decodedImage.index(44, 18)], equals(0xfff39621)); // Check a pixel value

      final TestGesture gesture = await controller.startGesture(const Offset(50.0, 50.0));
      await gesture.up();
      controller.advanceTime(const Duration(seconds: 1));

      actualOutputFile = await controller.drawDiagramToFile(outputFile);
      imageContents = actualOutputFile.readAsBytesSync();
      decodedImage = image.decodePng(imageContents)!;
      expect(decodedImage[decodedImage.index(44, 18)], equals(0xff3643f4)); // Check a pixel value
    });
  });
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

enum VideoFormat {
  mp4,
  gif,
}

/// Container class to read and write a JSON file containing metadata generated
/// by the [DiagramController.drawAnimatedDiagramToFiles] method.
class AnimationMetadata {
  AnimationMetadata.fromData({
    this.name,
    this.category,
    required this.duration,
    required this.frameRate,
    required this.frameFiles,
    required this.metadataFile,
    required this.videoFormat,
    required this.width,
  });

  factory AnimationMetadata.fromFile(File metadataFile) {
    assert(metadataFile.existsSync());
    metadataFile = File(path.normalize(metadataFile.absolute.path));
    final Map<String, Object?> metadata =
        json.decode(metadataFile.readAsStringSync()) as Map<String, dynamic>;
    final String baseDir = path.dirname(metadataFile.absolute.path);
    final List<File> frameFiles =
        (metadata[_frameFilesKey]! as List<dynamic>).map<File>(
      (dynamic name) {
        return File(path.normalize(path.join(baseDir, name.toString())));
      },
    ).toList();
    final Duration duration =
        Duration(milliseconds: metadata[_durationMsKey]! as int);
    return AnimationMetadata.fromData(
      metadataFile: metadataFile,
      name: metadata[_nameKey]! as String,
      category: metadata[_categoryKey]! as String,
      duration: duration,
      frameRate: metadata[_frameRateKey]! as double,
      frameFiles: frameFiles,
      width: metadata[_widthKey]! as int,
      videoFormat:
          VideoFormat.values.byName(metadata[_videoFormatKey]! as String),
    );
  }

  static const String _frameFilesKey = 'frame_files';
  static const String _categoryKey = 'category';
  static const String _nameKey = 'name';
  static const String _frameRateKey = 'frame_rate';
  static const String _durationMsKey = 'duration_ms';
  static const String _videoFormatKey = 'format';
  static const String _widthKey = 'width';

  Future<File> saveToFile() async {
    final Map<String, dynamic> metadata = <String, dynamic>{
      _nameKey: name ?? 'unknown',
      _categoryKey: category ?? 'unknown',
      _durationMsKey: duration.inMilliseconds,
      _videoFormatKey: videoFormat.name,
      _frameRateKey: frameRate,
      _widthKey: width,
      _frameFilesKey: frameFiles.map<String>((File file) {
        return path.relative(file.path,
            from: path.dirname(metadataFile.absolute.path));
      }).toList(),
    };
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    final String jsonMetadata = encoder.convert(metadata);
    print(
        'Writing metadata for ${duration.inMilliseconds}ms animation (${frameFiles.length} frames) to: ${metadataFile.path}');
    return metadataFile.writeAsString(jsonMetadata);
  }

  /// The category that this diagram is part of. This determines the output
  /// directory that it ends up in.
  final String? category;

  /// The base name of the diagram. This is the basis for the filenames that
  /// the diagram uses.
  final String? name;

  /// The frame rate, in frames per second, of the animation.
  final double frameRate;

  /// The overall duration of the animation, saved to the nearest millisecond.
  final Duration duration;

  /// The list of files that make up this animation. These should have relative
  /// filenames, relative to the location of the metadata file.
  final List<File> frameFiles;

  /// The metadata file that the data was read from or will be written to by
  /// the [saveToFile] method, depending on whether this wrapper class is being
  /// used to read or write the metadata.
  final File metadataFile;

  /// The video format of the output file.
  final VideoFormat videoFormat;

  /// The width of the video in pixel.
  final int width;
}

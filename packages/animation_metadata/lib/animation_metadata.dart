// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Container class to read and write a JSON file containing metadata generated
/// by the [DiagramController.drawAnimatedDiagramToFiles] method.
class AnimationMetadata {
  AnimationMetadata.fromData({
    this.name,
    this.category,
    this.duration,
    this.frameRate,
    this.frameFiles,
    this.metadataFile,
  });

  factory AnimationMetadata.fromFile(File metadataFile) {
    assert(metadataFile.existsSync());
    metadataFile = new File(path.normalize(metadataFile.absolute.path));
    final Map<String, dynamic> metadata = json.decode(metadataFile.readAsStringSync());
    final String baseDir = path.dirname(metadataFile.absolute.path);
    final List<File> frameFiles = metadata[_frameFilesKey].map<File>(
          (dynamic name) {
        return new File(path.normalize(path.join(baseDir, name)));
      },
    ).toList();
    final Duration duration = new Duration(milliseconds: metadata[_durationMsKey]);
    return new AnimationMetadata.fromData(
      metadataFile: metadataFile,
      name: metadata[_nameKey],
      category: metadata[_categoryKey],
      duration: duration,
      frameRate: metadata[_frameRateKey],
      frameFiles: frameFiles,
    );
  }

  static const String _frameFilesKey = 'frame_files';
  static const String _categoryKey = 'category';
  static const String _nameKey = 'name';
  static const String _frameRateKey = 'frame_rate';
  static const String _durationMsKey = 'duration_ms';

  Future<File> saveToFile() async {
    final Map<String, dynamic> metadata = <String, dynamic>{
      _nameKey: name ?? 'unknown',
      _categoryKey: category ?? 'unknown',
      _durationMsKey: duration.inMilliseconds,
      _frameRateKey: frameRate,
      _frameFilesKey: frameFiles.map<String>((File file) {
        return path.relative(file.path, from: path.dirname(metadataFile.absolute.path));
      }).toList(),
    };
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    print('Metadata: $metadata');
    final String jsonMetadata = encoder.convert(metadata);
    return metadataFile.writeAsString(jsonMetadata);
  }

  /// The category that this diagram is part of. This determines the output
  /// directory that it ends up in.
  final String category;

  /// The base name of the diagram. This is the basis for the filenames that
  /// the diagram uses.
  final String name;

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
}

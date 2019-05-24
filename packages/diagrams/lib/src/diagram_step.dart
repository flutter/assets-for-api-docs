// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';

/// Describes a step in drawing the diagrams.
abstract class DiagramStep<T extends DiagramMetadata> {
  DiagramStep(this.controller);

  final DiagramController controller;

  /// The category that these diagrams belong in.
  ///
  /// Typically, this is the Flutter library where the corresponding topic
  /// resides (e.g. 'material', 'animation', etc.). This is used to make the
  /// subdirectory where the diagrams will be written. It should match the path
  /// used in the URL for linking to the image on the documentation website.
  String get category;

  /// Returns the list of all available diagrams for this step.
  Future<List<T>> get diagrams;

  /// Generates the given diagram and returns the resulting [File].
  Future<File> generateDiagram(T diagram);

  /// Generates all diagrams for this step.
  ///
  /// Returns a list of Files where the diagrams were written.
  ///
  /// If `onlyGenerate` is supplied, then only generate diagrams which match one
  /// of the given file basename. Only matches the basename with no suffix, not
  /// the path.
  Future<List<File>> generateDiagrams({List<String> onlyGenerate: const <String>[]}) async {
    final List<File> files = <File>[];
    for (T diagram in await diagrams) {
      if (onlyGenerate.isNotEmpty && !onlyGenerate.contains(diagram.name)) {
        continue;
      }
      files.add(await generateDiagram(diagram));
    }
    return files;
  }
}

/// Mixin class for an individual diagram in a step to provide metadata about
/// the Diagram for filtering (e.g. filename).
abstract class DiagramMetadata {
  String get name;
}

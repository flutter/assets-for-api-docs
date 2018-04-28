// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram/diagram.dart';

/// Describes a step in drawing the diagrams.
abstract class DiagramStep {
  DiagramStep(this.controller);

  final DiagramController controller;

  /// The category that these diagrams belong in.
  ///
  /// Typically, this is the Flutter library where the corresponding topic
  /// resides (e.g. 'material', 'animation', etc.). This is used to make the
  /// subdirectory where the diagrams will be written. It should match the path
  /// used in the URL for linking to the image on the documentation website.
  String get category;

  /// Generates all diagrams in this step.
  ///
  /// Returns a list of Files where the diagrams were written.
  Future<List<File>> generateDiagrams();
}
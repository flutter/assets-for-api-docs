// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:animation_metadata/animation_metadata.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Possible supported platforms that can be specified for the diagram.
enum DiagramPlatform {
  android,
  fuchsia,
  ios,
  linux,
  macos,
  windows,
}

Map<String, DiagramPlatform> diagramStepPlatformNames =
    Map<String, DiagramPlatform>.fromEntries(DiagramPlatform.values
        .map<MapEntry<String, DiagramPlatform>>((DiagramPlatform platform) {
  return MapEntry<String, DiagramPlatform>(
    platform.toString().replaceFirst('$DiagramPlatform.', ''),
    platform,
  );
}));

/// Describes a step in drawing the diagrams.
abstract class DiagramStep {
  /// The category that these diagrams belong in.
  ///
  /// Typically, this is the Flutter library where the corresponding topic
  /// resides (e.g. 'material', 'animation', etc.). This is used to make the
  /// subdirectory where the diagrams will be written. It should match the path
  /// used in the URL for linking to the image on the documentation website.
  String get category;

  /// The set of platforms that this diagram step is intended to be rendered on.
  ///
  /// This is either set to [DiagramPlatform.values], where it will be generated
  /// on all platforms, or set to a specific set of platforms where it should be
  /// generated.
  ///
  /// An example of setting this to something other than the default of
  /// [DiagramPlatform.values] is setting it to [DiagramPlatform.macos] in order
  /// to be able to access fonts that are only available on macOS.
  Set<DiagramPlatform> get platforms => DiagramPlatform.values.toSet();

  /// Returns the list of all available diagrams for this step.
  Future<List<DiagramMetadata>> get diagrams;
}

/// Mixin class for an individual diagram in a step to provide metadata about
/// the Diagram for filtering (e.g. filename).
mixin DiagramMetadata on Widget {
  /// The snake_case name of this diagram, without a file extension.
  String get name;

  /// The frame rate this diagram should be captured at, defaults to 60 frames
  /// per second.
  double get frameRate => 60.0;

  /// The duration of the animation that should be captured, or null if this is
  /// a still image.
  ///
  /// This duration includes [startAt], so the output video will have a
  /// duration of [duration] minus [startAt].
  Duration? get duration => null;

  /// The format of the output video.
  ///
  /// This is only used when this diagram generates a video.
  VideoFormat get videoFormat => VideoFormat.mp4;

  /// How much time should pass before capturing the animation or image.
  Duration get startAt => Duration.zero;

  /// Called after the widget is built, blocking the diagram from being captured
  /// until it finishes.
  ///
  /// Overriding this method is useful if you want to wait for assets to load
  /// before capturing, e.g. with [precacheImage].
  Future<void> setUp(GlobalKey key) async {}

  /// A list of error patterns to expect while the diagram is being captured,
  /// errors that match any of these patterns get ignored by the diagram
  /// generator.
  Set<Pattern> get expectedErrors => const <Pattern>{};
}

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library diagram;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:path/path.dart' as path;
import 'package:vector_math/vector_math_64.dart';

// The diagram host widget. Diagrams are wrapped by this widget to provide
// the needed structure for capturing them.
class _Diagram extends StatefulWidget {
  const _Diagram({
    Key key,
    @required this.boundaryKey,
    @required this.child,
  })  : assert(child != null),
        assert(boundaryKey != null),
        super(key: key);

  final GlobalKey boundaryKey;
  final Widget child;

  _DiagramState createState() => new _DiagramState();
}

class _DiagramState extends State<_Diagram> {
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Material(
        child: new Builder(
          builder: (BuildContext context) {
            return new Center(
              child: new RepaintBoundary(
                key: widget.boundaryKey,
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}

const Size _kDefaultDiagramViewportSize = const Size(1280.0, 1024.0);

// View configuration that allows diagrams to not match the physical dimensions
// of the device. This will change the view used to display the flutter surface
// so that the diagram surface fits on the device, but it doesn't affect the
// captured image pixels.
class _DiagramViewConfiguration extends ViewConfiguration {
  _DiagramViewConfiguration({
    double pixelRatio: 1.0,
    Size size: _kDefaultDiagramViewportSize,
  })  : _paintMatrix = _getMatrix(size, ui.window.devicePixelRatio),
        _hitTestMatrix = _getMatrix(size, 1.0),
        super(size: size);

  static Matrix4 _getMatrix(Size size, double devicePixelRatio) {
    final double inverseRatio = devicePixelRatio / ui.window.devicePixelRatio;
    final double actualWidth = ui.window.physicalSize.width * inverseRatio;
    final double actualHeight = ui.window.physicalSize.height * inverseRatio;
    final double desiredWidth = size.width;
    final double desiredHeight = size.height;
    double scale, shiftX, shiftY;
    if ((actualWidth / actualHeight) > (desiredWidth / desiredHeight)) {
      scale = actualHeight / desiredHeight;
      shiftX = (actualWidth - desiredWidth * scale) / 2.0;
      shiftY = 0.0;
    } else {
      scale = actualWidth / desiredWidth;
      shiftX = 0.0;
      shiftY = (actualHeight - desiredHeight * scale) / 2.0;
    }
    final Matrix4 matrix = new Matrix4.compose(
        new Vector3(shiftX, shiftY, 0.0), // translation
        new Quaternion.identity(), // rotation
        new Vector3(scale, scale, 1.0) // scale
    );
    return matrix;
  }

  final Matrix4 _paintMatrix;
  final Matrix4 _hitTestMatrix;

  @override
  Matrix4 toMatrix() => _paintMatrix.clone();

  /// Provides the transformation matrix that converts coordinates in the test
  /// coordinate space to coordinates in logical pixels on the real display.
  ///
  /// This is essentially the same as [toMatrix] but ignoring the device pixel
  /// ratio.
  ///
  /// This is useful because pointers are described in logical pixels, as
  /// opposed to graphics which are expressed in physical pixels.
  Matrix4 toHitTestMatrix() => _hitTestMatrix.clone();

  @override
  String toString() => 'TestViewConfiguration';
}

// Provides a binding different from the regular Flutter binding so that
// diagrams can control their timeline and physical device size.
class _DiagramFlutterBinding extends BindingBase
    with
        GestureBinding, //
        ServicesBinding,
        SchedulerBinding,
        PaintingBinding,
        RendererBinding,
        WidgetsBinding {
  @override
  void initInstances() {
    super.initInstances();
    // Short circuit the begin frame to use our timestamp instead of the "real" one.
    // Re-use the previous onBeginFrame so that all of the hot reload, etc. works.
    dynamic oldBeginFrame = ui.window.onBeginFrame;
    ui.window.onBeginFrame = (Duration timestamp) {
      oldBeginFrame(_timestamp);
    };
  }

  Duration _timestamp = Duration.zero;

  /// Determines the ratio between physical units and logical units.
  ///
  /// The [pixelRatio] describes the scale between the logical pixels and the
  /// size of the output image. It is independent of the
  /// [window.devicePixelRatio] for the device, so specifying 1.0 (the default)
  /// will give you a 1:1 mapping between logical pixels and the output pixels
  /// in the image. The output image is not anti-aliased, so you may wish to
  /// use a larger device pixel ratio to obtain an image large enough to
  /// down sample.
  ///
  /// Defaults to 1.0.
  double get pixelRatio => _pixelRatio;
  double _pixelRatio = 1.0;
  set pixelRatio(double pixelRatio) {
    _pixelRatio = pixelRatio;
    handleMetricsChanged();
  }

  /// Determines the dimensions of the virtual screen that the diagram will
  /// be drawn on, in logical units.
  Size get screenDimensions => _screenDimensions;
  Size _screenDimensions = _kDefaultDiagramViewportSize;
  set screenDimensions(Size screenDimensions) {
    _screenDimensions = screenDimensions;
    handleMetricsChanged();
  }

  /// Returns the singleton for the binding, after making sure it is
  /// initialized.
  static WidgetsBinding instance() {
    if (WidgetsBinding.instance == null) {
      new _DiagramFlutterBinding();
    }
    return WidgetsBinding.instance;
  }

  @override
  ViewConfiguration createViewConfiguration() {
    return new _DiagramViewConfiguration(
      pixelRatio: pixelRatio,
      size: screenDimensions,
    );
  }

  /// Captures an image of the [RepaintBoundary] with the given key.
  Future<image.Image> takeSnapshot(GlobalKey key) async {
    RenderRepaintBoundary object = key.currentContext.findRenderObject();
    ui.Image capture = await object.toImage(pixelRatio: pixelRatio);
    ByteData data = await capture.toByteData();
    return new image.Image.fromBytes(
      capture.width,
      capture.height,
      data.buffer.asUint32List(),
    );
  }

  /// Updates the current diagram with the given builder as the child of the
  /// root widget, using the given [boundaryKey].
  void updateDiagram(
    WidgetBuilder builder,
    GlobalKey boundaryKey, {
    Duration duration: Duration.zero,
  }) {
    Widget rootWidget = new _Diagram(
      boundaryKey: boundaryKey,
      child: new Builder(builder: builder),
    );
    attachRootWidget(rootWidget);
    scheduleWarmUpFrame();
  }

  /// Advances time by the given duration, and generates a new frame.
  ///
  /// The [duration] must not be null, or less than [Duration.zero].
  void pump({Duration duration: Duration.zero}) {
    assert(duration != null);
    assert(duration >= Duration.zero);
    _timestamp += duration;

    handleBeginFrame(_timestamp);
    handleDrawFrame();
  }
}

/// A generator used by [DiagramController] for generating filenames for frames
/// in animated diagram sequences.
typedef File AnimationFrameFilenameGenerator(Duration timestamp, int index);

/// A controller for creating diagrams generated by using Flutter widgets.
///
/// This is used to configure and create individual image diagrams, as well as
/// animations of diagrams with control over the time used by animation tickers.
class DiagramController {
  /// Creates a diagram controller.
  ///
  /// The [builder] parameter must not be null, and is required.
  DiagramController({
    @required WidgetBuilder builder,
    this.outputDirectory,
    AnimationFrameFilenameGenerator frameFilenameGenerator,
    double pixelRatio: 1.0,
    Size screenDimensions: _kDefaultDiagramViewportSize,
  }) : assert(builder != null) {
    _builder = builder;
    _frameFilenameGenerator ??= _basicFrameFilenameGenerator;
    outputDirectory ??= Directory.current;
    _binding.pixelRatio = pixelRatio;
    _binding.screenDimensions = screenDimensions;
    _updateDiagram();
  }

  final GlobalKey _boundaryKey = new GlobalKey(debugLabel: 'Diagram Boundary');

  /// The builder used to generate each frame of the diagram.
  ///
  /// If the [builder] is changed, then the widget it builds will be used for
  /// subsequent frames drawn of the diagram.
  ///
  /// Defaults to the `initialBuilder` given to [new DiagramController].
  WidgetBuilder get builder => _builder;
  WidgetBuilder _builder;
  set builder(WidgetBuilder builder) {
    assert(builder != null);
    if (_builder != builder) {
      _builder = builder;
      _updateDiagram();
    }
  }

  /// The output directory used when a [File] generated by the
  /// [frameFilenameGenerator], or the `outputFile` argument to
  /// [drawDiagramToFile] is a relative path. The written file will be relative
  /// to [outputDirectory]. If the filename is absolute, then [outputDirectory]
  /// is ignored.
  ///
  /// Defaults to [Directory.current].
  ///
  /// On a device, this will need to be set to the result of
  /// [getApplicationDocumentsDirectory] (from the path_provider package) or a
  /// subdirectory of that directory to have sufficient permissions to write
  /// files.
  Directory outputDirectory;

  /// The generator for filenames when calling drawAnimatedDiagramToFile.
  ///
  /// If the returned filenames are relative paths, they will be relative to
  /// [outputDirectory].
  AnimationFrameFilenameGenerator get frameFilenameGenerator => _frameFilenameGenerator;
  AnimationFrameFilenameGenerator _frameFilenameGenerator;
  set frameFilenameGenerator(AnimationFrameFilenameGenerator frameFilenameGenerator) {
    _frameFilenameGenerator = frameFilenameGenerator ?? _basicFrameFilenameGenerator;
  }

  _DiagramFlutterBinding get _binding => _DiagramFlutterBinding.instance();

  /// Advances the animation clock by the given duration.
  ///
  /// The [increment] must be greater than, or equal to, [Duration.zero].
  void advanceTime(Duration increment) => _binding.pump(duration: increment);

  /// Returns an [image.Image] representing the current diagram.
  ///
  /// The returned image will have the dimensions of the widget generated by
  /// [builder] in logical coordinates, multiplied by the [pixelRatio].
  ///
  /// Time will be advanced by [duration] before taking the snapshot.
  Future<image.Image> drawDiagramToImage({Duration duration: Duration.zero}) async {
    advanceTime(duration);
    return _binding.takeSnapshot(_boundaryKey);
  }

  /// Draws the widget returned by [builder] and writes it to [outputFile].
  ///
  /// The file will be written in whatever format the suffix on the file
  /// indicates. Valid suffixes are ".jpg", ".jpeg", ".png", ".gif", and ".tga".
  Future<Null> drawDiagramToFile(File outputFile) async {
    assert(outputFile != null);
    if (!outputFile.isAbsolute && outputDirectory != null) {
      // If output path is relative, make it relative to the output directory.
      outputFile = new File(path.join(outputDirectory.absolute.path, outputFile.path));
    }
    image.Image captured = await drawDiagramToImage();
    List<int> encoded = image.encodeNamedImage(captured, outputFile.path);
    print('Writing ${encoded.length} bytes to ${outputFile.absolute.path}');
    await outputFile.writeAsBytes(encoded);
  }

  /// Draws multiple frames of the widget generated by [builder] into multiple
  /// files.
  ///
  /// The filenames are determined by [frameFilenameGenerator].
  ///
  /// The files will be written in whatever format the suffix on the file
  /// indicates. Valid suffixes are ".jpg", ".jpeg", ".png", ".gif", and ".tga".
  ///
  /// The animation will start at timestamp [start], end at [end], with the time
  /// between frames specified by [frameDuration].  For instance, to generate
  /// 11 frames of an animation that is 1 second long, set [start] to
  /// [Duration.zero] (the default), set [end] to `const Duration(seconds: 1)`,
  /// and set [frameDuration] to `const Duration(milliseconds: 100)`. The
  /// animation includes the frames at [start] and [end].
  ///
  /// None of the parameters may be null. The [start] parameter must be less
  /// than or equal to the [end] parameter, and the [frameDuration] must be
  /// less than or equal to the time between [start] and [end]. All durations
  /// must be greater than [Duration.zero].
  Future<Null> drawAnimatedDiagramToFiles({
    Duration start: Duration.zero,
    @required Duration end,
    @required Duration frameDuration,
  }) async {
    assert(end != null);
    assert(start != null);
    assert(frameDuration != null);
    assert(end >= start);
    assert(frameDuration <= (end - start));
    assert(frameDuration > Duration.zero);
    assert(end > Duration.zero);
    assert(start >= Duration.zero);

    Duration now = start;
    int index = 0;
    while (now <= end) {
      File outputFile = _getFrameFile(now, index);
      image.Image captured = await drawDiagramToImage();
      List<int> encoded = image.encodeNamedImage(captured, outputFile.path);
      print('Writing frame $index ($now), ${encoded.length} bytes, to ${outputFile.absolute.path}');
      outputFile.writeAsBytesSync(encoded);
      advanceTime(frameDuration);
      now += frameDuration;
      ++index;
    }
  }

  static File _basicFrameFilenameGenerator(Duration timestamp, int index) {
    return new File('frame_${index.toString().padLeft(3, '0')}.png');
  }

  // Update the diagram using the current [builder].
  void _updateDiagram() => _binding.updateDiagram(builder, _boundaryKey);

  File _getFrameFile(Duration timestamp, int index) {
    File outputFile = _frameFilenameGenerator(timestamp, index);
    if (!outputFile.isAbsolute && outputDirectory != null) {
      // If output path is relative, make it relative to the output directory.
      outputFile = new File(path.join(outputDirectory.absolute.path, outputFile.path));
    }
    return outputFile;
  }
}

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:animation_metadata/animation_metadata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:vector_math/vector_math_64.dart';

/// Provides a [WidgetController] to diagrams, which can be used to
/// programmatically input gestures to the widget tree.
class DiagramWidgetController extends InheritedWidget {
  const DiagramWidgetController({
    super.key,
    required this.controller,
    required super.child,
  });

  final WidgetController controller;

  @override
  bool updateShouldNotify(DiagramWidgetController oldWidget) => controller != oldWidget.controller;

  static WidgetController of(BuildContext context) {
    return context.findAncestorWidgetOfExactType<DiagramWidgetController>()!.controller;
  }
}

// The diagram host widget. Diagrams are wrapped by this widget to provide
// the needed structure for capturing them.
class _Diagram extends StatelessWidget {
  const _Diagram({
    required this.boundaryKey,
    required this.widgetController,
    required this.child,
  });

  final GlobalKey boundaryKey;
  final WidgetController widgetController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DiagramWidgetController(
      controller: widgetController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
          child: Builder(
            builder: (BuildContext context) {
              return Center(
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

const Size _kDefaultDiagramViewportSize = Size(1280.0, 1024.0);

// View configuration that allows diagrams to not match the physical dimensions
// of the device. This will change the view used to display the flutter surface
// so that the diagram surface fits on the device, but it doesn't affect the
// captured image pixels.
class _DiagramViewConfiguration extends ViewConfiguration {
  _DiagramViewConfiguration({
    Size size = _kDefaultDiagramViewportSize,
  })  : _paintMatrix = _getMatrix(size, ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0),
        super(
          physicalConstraints: BoxConstraints.tightFor(
            width: size.width,
            height: size.height,
          ) * (ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0),
          logicalConstraints:  BoxConstraints.tightFor(
            width: size.width,
            height: size.height,
          ),
          devicePixelRatio: ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0,
        );

  static Matrix4 _getMatrix(Size size, double devicePixelRatio) {
    final double baseRatio = ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0;
    final double inverseRatio = devicePixelRatio / baseRatio;
    final Size implicitSize = ui.PlatformDispatcher.instance.implicitView?.physicalSize ?? Size.zero;
    final double actualWidth = implicitSize.width * inverseRatio;
    final double actualHeight = implicitSize.height * inverseRatio;
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
    final Matrix4 matrix = Matrix4.compose(
        Vector3(shiftX, shiftY, 0.0), // translation
        Quaternion.identity(), // rotation
        Vector3(scale, scale, 1.0) // scale
        );
    return matrix;
  }

  final Matrix4 _paintMatrix;

  @override
  Matrix4 toMatrix() => _paintMatrix.clone();

  @override
  String toString() => '_DiagramViewConfiguration';
}

// Provides a concrete implementation of WidgetController.
class _DiagramWidgetController extends WidgetController implements TickerProvider {
  _DiagramWidgetController(super.binding) : _tickers = <_DiagramTicker>{};

  @override
  DiagramFlutterBinding get binding => super.binding as DiagramFlutterBinding;

  @override
  Future<void> pump([
    Duration duration = Duration.zero,
  ]) {
    return TestAsyncUtils.guard(() => binding.pump(duration: duration));
  }

  final Set<Ticker> _tickers;

  @override
  Ticker createTicker(TickerCallback onTick) {
    final _DiagramTicker result = _DiagramTicker(onTick, _removeTicker);
    _tickers.add(result);
    return result;
  }

  void _removeTicker(_DiagramTicker ticker) {
    assert(_tickers.contains(ticker));
    _tickers.remove(ticker);
  }

  @override
  Future<List<Duration>> handlePointerEventRecord(List<PointerEventRecord> records) async {
    return const <Duration>[];
  }

  @override
  Future<int> pumpAndSettle([
    Duration duration = const Duration(milliseconds: 100),
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
  ]) {
    assert(duration > Duration.zero);
    assert(() {
      final WidgetsBinding binding = this.binding;
      if (binding is LiveTestWidgetsFlutterBinding &&
          binding.framePolicy == LiveTestWidgetsFlutterBindingFramePolicy.benchmark) {
        throw StateError(
          'When using LiveTestWidgetsFlutterBindingFramePolicy.benchmark, '
          'hasScheduledFrame is never set to true. This means that pumpAndSettle() '
          'cannot be used, because it has no way to know if the application has '
          'stopped registering new frames.',
        );
      }
      return true;
    }());
    return TestAsyncUtils.guard<int>(() async {
      int count = 0;
      do {
        await binding.pump(duration: duration);
        count += 1;
      } while (binding.hasScheduledFrame);
      return count;
    });
  }
}

typedef _TickerDisposeCallback = void Function(_DiagramTicker ticker);

class _DiagramTicker extends Ticker {
  _DiagramTicker(super.onTick, this._onDispose);

  final _TickerDisposeCallback _onDispose;

  @override
  void dispose() {
    _onDispose(this);
    super.dispose();
  }
}

/// Provides a binding different from the regular Flutter binding so that
/// diagrams can control their timeline and physical device size.
class DiagramFlutterBinding extends BindingBase
    with
        GestureBinding,
        SemanticsBinding,
        SchedulerBinding,
        ServicesBinding,
        PaintingBinding,
        RendererBinding,
        WidgetsBinding {
  @override
  void initInstances() {
    super.initInstances();
    _controller = _DiagramWidgetController(this);
  }

  late _DiagramWidgetController _controller;

  /// The current [DiagramFlutterBinding], if one has been created.
  static DiagramFlutterBinding get instance => ensureInitialized()!;

  static DiagramFlutterBinding? _instance;

  @override
  void handleBeginFrame(Duration? rawTimeStamp) {
    // Override the timestamp so time doesn't pass unless we want it to.
    super.handleBeginFrame(_timestamp);
  }

  Duration _timestamp = Duration.zero;
  final GlobalKey _boundaryKey = GlobalKey();

  /// Determines the ratio between physical units and logical units.
  ///
  /// The [pixelRatio] describes the scale between the logical pixels and the
  /// size of the output image. It is independent of the
  /// [PlatformDispatcher.implicitView] for the device, so specifying 1.0 (the
  /// default) will give you a 1:1 mapping between logical pixels and the output
  /// pixels in the image.
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
    if (_screenDimensions != screenDimensions) {
      _screenDimensions = screenDimensions;
      handleMetricsChanged();
    }
  }

  TickerProvider get vsync => _controller;

  Future<TestGesture> startGesture(Offset downLocation, {int? pointer}) {
    return _controller.startGesture(downLocation, pointer: pointer);
  }

  @override
  ViewConfiguration createViewConfigurationFor(RenderView renderView) {
    return _DiagramViewConfiguration(
      size: screenDimensions,
    );
  }

  /// Captures an image of the [RepaintBoundary] with the given key.
  Future<ui.Image> takeSnapshot() {
    final RenderRepaintBoundary object = _boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    return object.toImage(pixelRatio: pixelRatio);
  }

  /// Updates the current diagram with the given builder as the child of the
  /// root widget, and generates a frame.
  void updateDiagram(
    WidgetBuilder builder, {
    Duration duration = Duration.zero,
  }) {
    final Widget rootWidget = wrapWithDefaultView(_Diagram(
      boundaryKey: _boundaryKey,
      widgetController: _controller,
      child: Builder(builder: builder),
    ));
    attachRootWidget(rootWidget);
    pump();
  }

  /// Advances time by the given duration, and generates a frame.
  ///
  /// The [duration] must not be null, or less than [Duration.zero].
  Future<void> pump({Duration duration = Duration.zero}) {
    assert(duration >= Duration.zero);
    _timestamp += duration;
    handleBeginFrame(_timestamp);
    handleDrawFrame();
    return Future<void>.value();
  }

  /// Ensures the binding has been initialized before accessing the default
  /// binary messenger.
  static DiagramFlutterBinding? ensureInitialized() {
    _instance ??= DiagramFlutterBinding();
    return _instance;
  }
}

/// A generator used by [DiagramController] for generating filenames for frames
/// in animated diagram sequences.
typedef AnimationFilenameGenerator = File Function();

/// A keyframe function designed to be executed before a particular frame is
/// captured. Passes the current value of "now" (the time elapsed since the
/// beginning of the animation).
typedef DiagramKeyframe = void Function(Duration duration);

/// A callback given to drawAnimatedDiagramToFiles that is called for each
/// frame.
typedef DiagramGestureCallback = void Function(DiagramController diagram, Duration now);

/// A controller for creating diagrams generated by using Flutter widgets.
///
/// This is used to configure and create individual image diagrams, as well as
/// animations of diagrams with control over the time used by animation tickers.
class DiagramController {
  /// Creates a diagram controller for generating images of diagrams.
  DiagramController({
    WidgetBuilder? builder,
    Directory? outputDirectory,
    double? pixelRatio,
    Size screenDimensions = _kDefaultDiagramViewportSize,
  })  : outputDirectory = outputDirectory ?? Directory.current,
        _builder = builder {
    _binding.pixelRatio = pixelRatio ?? ui.PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0;
    _binding.screenDimensions = screenDimensions;
    if (_builder != null) {
      _binding.updateDiagram(_builder!);
    }
  }

  /// The builder used to generate each frame of the diagram.
  ///
  /// If the [builder] is changed, then the widget it builds will be used for
  /// subsequent frames drawn of the diagram.
  ///
  /// Defaults to the `initialBuilder` given to [DiagramController].
  WidgetBuilder? get builder => _builder;
  WidgetBuilder? _builder;
  set builder(WidgetBuilder? builder) {
    if (_builder != builder) {
      _builder = builder;
      if (builder != null) {
        _binding.updateDiagram(builder);
      }
    }
  }

  /// The output directory used when a [File] generated by the `outputFile`
  /// argument to [drawDiagramToFile] is a relative path. The written file will
  /// be relative to [outputDirectory]. If the filename is absolute, then
  /// [outputDirectory] is ignored.
  ///
  /// Defaults to [Directory.current].
  ///
  /// On a device, this will need to be set to the result of
  /// [getApplicationDocumentsDirectory] (from the path_provider package) or a
  /// subdirectory of that directory to have sufficient permissions to write
  /// files.
  Directory outputDirectory;

  double get pixelRatio => _binding.pixelRatio;
  set pixelRatio(double ratio) => _binding.pixelRatio = ratio;

  TickerProvider get vsync => _binding.vsync;

  DiagramFlutterBinding get _binding => DiagramFlutterBinding.instance;

  /// Start a gesture.  The returned [TestGesture] can be used to provide
  /// further interaction. It may be necessary to call [advanceTime] with
  /// no arguments to schedule a frame after interacting with the returned
  /// gesture ([startGesture] automatically does this for you for the initial
  /// tap down event).
  Future<TestGesture> startGesture(Offset location, {int? pointer}) async {
    final TestGesture gesture = await _binding.startGesture(location, pointer: pointer);
    advanceTime(); // Schedule a frame.
    return gesture;
  }

  /// Advances the animation clock by the given duration.
  ///
  /// The [increment] must be greater than, or equal to, [Duration.zero].
  Future<void> advanceTime([Duration increment = Duration.zero]) {
    _binding.pump(duration: increment);
    final Completer<void> completer = Completer<void>();
    _binding.addPostFrameCallback((Duration timeStamp) => completer.complete());
    return completer.future;
  }

  /// Returns an [image.Image] representing the current diagram.
  ///
  /// The returned image will have the dimensions of the widget generated by
  /// [builder] in logical coordinates, multiplied by the [pixelRatio].
  ///
  /// Time will be advanced to [timestamp] before taking the snapshot.
  Future<ui.Image> drawDiagramToImage({
    Duration timestamp = Duration.zero,
    double framerate = 60.0,
  }) async {
    // Even though we are only capturing a single frame, advance time at minimum
    // increments to let tickers update and async tasks run.
    final Duration framerateDuration = Duration(milliseconds: 1000 ~/ framerate);
    while (timestamp != Duration.zero) {
      final Duration advanceBy = timestamp > framerateDuration ? framerateDuration : timestamp;
      timestamp -= advanceBy;
      await advanceTime(advanceBy);
    }
    return _binding.takeSnapshot();
  }

  /// Draws the widget returned by [builder] and writes it to [outputFile].
  ///
  /// The file will be written in PNG format, and the only acceptable suffix
  /// for the [outputFile] is ".png".
  ///
  /// If [timestamp] is specified, advance time by [timestamp] before taking the
  /// snapshot.
  Future<File> drawDiagramToFile(
    File outputFile, {
    Duration timestamp = Duration.zero,
    double framerate = 60.0,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    if (!outputFile.isAbsolute) {
      // If output path is relative, make it relative to the output directory.
      outputFile = File(path.join(outputDirectory.absolute.path, outputFile.path));
    }
    assert(outputFile.path.endsWith('.png'));
    await advanceTime();
    final ui.Image captured = await drawDiagramToImage(
      timestamp: timestamp,
      framerate: framerate,
    );
    final ByteData? encoded = await captured.toByteData(format: format);
    final List<int> bytes = encoded!.buffer.asUint8List().toList();
    print('Writing ${bytes.length} bytes, ${captured.width}x${captured.height} '
        '${_byteFormatToString(format)}, to: ${outputFile.absolute.path}');
    await outputFile.writeAsBytes(bytes);
    return outputFile;
  }

  /// Draws multiple frames of the widget generated by [builder] into multiple
  /// images and returns them.
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
  Future<List<ui.Image>> drawAnimatedDiagramToImages({
    Duration start = Duration.zero,
    required Duration end,
    required Duration frameDuration,
  }) async {
    assert(end >= start);
    assert(frameDuration <= (end - start));
    assert(frameDuration > Duration.zero);
    assert(end > Duration.zero);
    assert(start >= Duration.zero);

    Duration now = start;
    final List<ui.Image> outputImages = <ui.Image>[];
    while (now <= end) {
      final ui.Image captured = await drawDiagramToImage();
      print('Generated frame for $now, ${captured.width}x${captured.height}.');
      outputImages.add(captured);
      advanceTime(frameDuration);
      now += frameDuration;
    }
    return outputImages;
  }

  /// Draws multiple frames of the widget generated by [builder] into multiple
  /// files, and returns a metadata file containing information for converting
  /// the files into a video file.
  ///
  /// A JSON metadata file will also be written, containing information about
  /// the duration, frame rate for the animation, and the frame files written,
  /// used by the generator in converting it to a video. The name of this file
  /// is determined by [nameGenerator].
  ///
  /// The files will be written in PNG format. Animation frames are named with
  /// the base name returned by [nameGenerator], and ending with an
  /// underscore followed by four digits describing the frame number, and
  /// ending in ".png" (e.g. "frame_0000.png").
  ///
  /// The animation will start at timestamp [start], end at [end], with the
  /// frame rate (in frames per second) specified by [frameRate].  For instance,
  /// to generate 11 frames of an animation that is 1 second long, set [start] to
  /// [Duration.zero] (the default), set [end] to `const Duration(seconds: 1)`,
  /// and set [frameRate] to `11.0`. The
  /// animation includes the frames at [start] and [end].
  ///
  /// None of the parameters may be null. The [start] parameter must be less
  /// than or equal to the [end] parameter. The [end] parameter must be greater
  /// than [Duration.zero]. The [start] parameter must be greater than or equal
  /// to [Duration.zero]. The [frameRate] must be greater than zero.
  Future<File> drawAnimatedDiagramToFiles({
    required Duration end,
    Duration start = Duration.zero,
    required double frameRate,
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
    required String name,
    String? category,
    Map<Duration, DiagramKeyframe>? keyframes,
    DiagramGestureCallback? gestureCallback,
    VideoFormat videoFormat = VideoFormat.mp4,
  }) async {
    assert(end >= start);
    assert(frameRate > 0.0);
    assert(end > Duration.zero);
    assert(start >= Duration.zero);

    Duration now = start;
    final Duration frameDuration = Duration(microseconds: (1e6 / frameRate).round());
    int index = 0;
    final List<File> outputFiles = <File>[];
    List<Duration> keys = <Duration>[];
    if (keyframes != null) {
      keys = keyframes.keys.toList()..sort();
    }
    int width = 0;
    // Add an half-frame to account for possible rounding error: we want
    // to make sure to get the last frame.
    while (now <= (end + Duration(microseconds: frameDuration.inMicroseconds ~/ 2))) {
      // If we've arrived at the next keyframe, then call the keyframe
      // function to execute the next event.
      if (keyframes != null && keys.isNotEmpty) {
        if (now >= keys.first) {
          keyframes[keys.first]!(now);
          keys.removeAt(0);
        }
      }

      if (gestureCallback != null) {
        gestureCallback(this, now);
      }
      final File outputFile = _getFrameFilename(now, index, name);
      final ui.Image captured = await drawDiagramToImage();
      width = max(width, captured.width);
      final ByteData? encoded = await captured.toByteData(format: format);
      final List<int> bytes = encoded!.buffer.asUint8List().toList();
      outputFile.writeAsBytesSync(bytes);
      advanceTime(frameDuration);
      outputFiles.add(outputFile);
      now += frameDuration;
      ++index;
    }
    print('Wrote $index frames of $name to ${outputDirectory.path}');
    final File metadataFile = File(path.join(outputDirectory.absolute.path, '$name.json'));
    final AnimationMetadata metadata = AnimationMetadata.fromData(
      name: name,
      category: category,
      duration: end - start,
      frameRate: 1e6 / frameDuration.inMicroseconds,
      frameFiles: outputFiles,
      metadataFile: metadataFile,
      videoFormat: videoFormat,
      width: width,
    );
    return metadata.saveToFile();
  }

  String _byteFormatToString(ui.ImageByteFormat format) {
    switch (format) {
      case ui.ImageByteFormat.rawRgba:
        return 'RAW RGBA';
      case ui.ImageByteFormat.rawUnmodified:
        return 'NATIVE';
      case ui.ImageByteFormat.png:
        return 'PNG';
      case ui.ImageByteFormat.rawStraightRgba:
        return 'RAW STRAIGHT RGBA';
      case ui.ImageByteFormat.rawExtendedRgba128:
        return 'RAW EXTENDED RGBA 128';
    }
  }

  File _getFrameFilename(Duration timestamp, int index, String name) {
    return File(
      path.join(
        outputDirectory.absolute.path,
        '${name}_${index.toString().padLeft(5, '0')}.png',
      ),
    );
  }
}

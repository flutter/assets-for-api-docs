// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// This defines a colored placeholder with padding, used to represent a
/// generic widget in diagrams.
class Hole extends StatelessWidget {
  const Hole({
    super.key,
    this.color = const Color(0xFFFFFFFF),
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Placeholder(
          color: color,
        ),
      ),
    );
  }
}

/// This is a struct to represent a text label in the [LabelPainterWidget].
class Label {
  const Label(this.key, this.text, this.anchor);
  final GlobalKey key;
  final String text;
  final FractionalOffset anchor;
}

/// The will take a list of locations that a label should point to, defined
/// by the [Label] structure.
class LabelPainterWidget extends StatelessWidget {
  /// Creates a widget that paints labels in defined locations.
  ///
  /// All parameters are required and must not be null.
  LabelPainterWidget({
    required GlobalKey key,
    required List<Label> labels,
    required GlobalKey heroKey,
  })  : painter =
            LabelPainter(labels: labels, heroKey: heroKey, canvasKey: key),
        super(key: key);

  final LabelPainter painter;

  @override
  Widget build(BuildContext context) => CustomPaint(painter: painter);
}

/// The custom painter that [LabelPainterWidget] uses to paint the list of
/// labels it is given.
class LabelPainter extends CustomPainter {
  LabelPainter({
    required this.labels,
    required this.heroKey,
    required this.canvasKey,
  }) : _painters = <Label, TextPainter>{} {
    for (final Label label in labels) {
      final TextPainter painter = TextPainter(
        textDirection: TextDirection.ltr,
        text: TextSpan(text: label.text, style: _labelTextStyle),
      );
      painter.layout();
      _painters[label] = painter;
    }
  }

  final List<Label> labels;
  final GlobalKey heroKey;
  final GlobalKey canvasKey;

  final Map<Label, TextPainter> _painters;

  static const TextStyle _labelTextStyle = TextStyle(color: Color(0xFF000000));

  static const double margin = 16.0;

  @override
  void paint(Canvas canvas, Size size) {
    final RenderBox hero =
        heroKey.currentContext!.findRenderObject()! as RenderBox;
    final RenderBox diagram =
        canvasKey.currentContext!.findRenderObject()! as RenderBox;
    final Paint dotPaint = Paint();
    final Paint linePaint = Paint()..strokeWidth = 2.0;
    final Offset heroTopLeft =
        diagram.globalToLocal(hero.localToGlobal(Offset.zero));
    for (final Label label in labels) {
      final RenderBox box =
          label.key.currentContext!.findRenderObject()! as RenderBox;
      final Offset anchor = diagram
          .globalToLocal(box.localToGlobal(label.anchor.alongSize(box.size)));
      final Offset anchorOnHero = anchor - heroTopLeft;
      final FractionalOffset relativeAnchor =
          FractionalOffset.fromOffsetAndSize(anchorOnHero, hero.size);
      final double distanceToTop = anchorOnHero.dy;
      final double distanceToBottom = hero.size.height - anchorOnHero.dy;
      final double distanceToLeft = anchorOnHero.dx;
      final double distanceToRight = hero.size.width - anchorOnHero.dx;
      Offset labelPosition;
      Offset textPosition = Offset.zero;
      final TextPainter painter = _painters[label]!;
      if (distanceToTop <= distanceToLeft &&
          distanceToTop <= distanceToRight &&
          distanceToTop <= distanceToBottom) {
        labelPosition = Offset(anchor.dx + (relativeAnchor.dx - 0.5) * margin,
            heroTopLeft.dy - margin);
        textPosition = Offset(labelPosition.dx - painter.width / 2.0,
            labelPosition.dy - painter.height);
      } else if (distanceToBottom < distanceToLeft &&
          distanceToBottom < distanceToRight &&
          distanceToTop > distanceToBottom) {
        labelPosition =
            Offset(anchor.dx, heroTopLeft.dy + hero.size.height + margin);
        textPosition =
            Offset(labelPosition.dx - painter.width / 2.0, labelPosition.dy);
      } else if (distanceToLeft < distanceToRight) {
        labelPosition = Offset(heroTopLeft.dx - margin, anchor.dy);
        textPosition = Offset(labelPosition.dx - painter.width - 2.0,
            labelPosition.dy - painter.height / 2.0);
      } else if (distanceToLeft > distanceToRight) {
        labelPosition =
            Offset(heroTopLeft.dx + hero.size.width + margin, anchor.dy);
        textPosition =
            Offset(labelPosition.dx, labelPosition.dy - painter.height / 2.0);
      } else {
        labelPosition = Offset(anchor.dx, heroTopLeft.dy - margin * 2.0);
        textPosition = Offset(anchor.dx - painter.width / 2.0,
            anchor.dy - margin - painter.height);
      }
      canvas.drawCircle(anchor, 4.0, dotPaint);
      canvas.drawLine(anchor, labelPosition, linePaint);
      painter.paint(canvas, textPosition);
    }
  }

  @override
  bool shouldRepaint(LabelPainter oldDelegate) {
    return labels != oldDelegate.labels || canvasKey != oldDelegate.canvasKey;
  }

  @override
  bool hitTest(Offset position) => false;
}

/// Resolves [provider] and returns an [ui.Image] that can be used in a
/// [CustomPainter].
Future<ui.Image> getImage(ImageProvider provider) {
  final Completer<ui.Image> completer = Completer<ui.Image>();
  final ImageStream stream = provider.resolve(ImageConfiguration.empty);
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (ImageInfo image, bool sync) {
      completer.complete(image.image);
      stream.removeListener(listener);
    },
    onError: (Object error, StackTrace? stack) {
      print(error);
      throw error; // ignore: only_throw_errors
    },
  );

  stream.addListener(listener);
  return completer.future;
}

/// Paints [span] to [canvas] with a given offset and alignment.
void paintSpan(
  Canvas canvas,
  TextSpan span, {
  required Offset offset,
  Alignment alignment = Alignment.center,
  EdgeInsets padding = EdgeInsets.zero,
  TextAlign textAlign = TextAlign.center,
}) {
  final TextPainter result = TextPainter(
    textDirection: TextDirection.ltr,
    text: span,
    textAlign: textAlign,
  );
  result.layout();
  final double width = result.width + padding.horizontal;
  final double height = result.height + padding.vertical;
  result.paint(
    canvas,
    Offset(
      padding.left + offset.dx + (width / -2) + (alignment.x * width / 2),
      padding.top + offset.dy + (height / -2) + (alignment.y * height / 2),
    ),
  );
}

/// Similar to [paintSpan] but provides a default text style.
void paintLabel(
  Canvas canvas,
  String label, {
  required Offset offset,
  Alignment alignment = Alignment.center,
  EdgeInsets padding = EdgeInsets.zero,
  TextAlign textAlign = TextAlign.center,
  TextStyle? style,
}) {
  paintSpan(
    canvas,
    TextSpan(
      text: label,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14.0,
      ).merge(style ?? const TextStyle()),
    ),
    offset: offset,
    alignment: alignment,
    padding: padding,
    textAlign: textAlign,
  );
}

/// Mixin on diagram states which provides concise callbacks for [Ticker]s.
///
/// This is useful to keep actions like gestures in sync with animations since
/// tickers in the diagram generator don't follow real-world time that [Timer]
/// and [Future.delayed] use in a live environment.
@optionalTypeArgs
mixin LockstepStateMixin<T extends StatefulWidget> on State<T>
    implements TickerProvider {
  late final Ticker _ticker;
  final Map<Duration, Completer<void>> _completers =
      <Duration, Completer<void>>{};

  Duration elapsed = Duration.zero;

  /// Waits for the total elapsed duration to reach [duration].
  Future<void> waitLockstepElapsed(Duration duration) {
    if (duration <= elapsed) {
      return Future<void>.value();
    }
    final Completer<void> completer =
        _completers.putIfAbsent(duration, () => Completer<void>());
    return completer.future;
  }

  /// Waits for the ticker to elapse [duration].
  Future<void> waitLockstep(Duration duration) {
    return waitLockstepElapsed(elapsed + duration);
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration elapsed) {
      this.elapsed = elapsed;

      // Avoid concurrent modification of _completers by getting the durations
      // all at once before removing them.
      final List<Duration> ready = _completers.keys
          .where((Duration duration) => elapsed >= duration)
          .toList();

      for (final Duration duration in ready) {
        _completers[duration]!.complete();
        _completers.remove(duration);
      }
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

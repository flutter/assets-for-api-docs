// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math' show max;
import 'dart:ui' as ui;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'diagram_step.dart';

const String _text = 'text';
const String _textEllipsis = 'text_ellipsis';
const String _textRich = 'text_rich';
const String _textBorder = 'text_border';
const String _textGradient = 'text_gradient';

class TextDiagram extends StatelessWidget implements DiagramMetadata {
  const TextDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    Widget returnWidget;

    switch (name) {
      case _text:
        returnWidget = const Text(
          'Hello, Ruth! How are you?',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
        break;
      case _textEllipsis:
        returnWidget = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: const Text(
            'Hello, Ruth! How are you?',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
        break;
      case _textRich:
        returnWidget = const Text.rich(
          TextSpan(
            text: 'Hello', // default text style
            children: <TextSpan>[
              TextSpan(
                text: ' beautiful ',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              TextSpan(
                text: 'world',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
        break;
      case _textBorder:
        returnWidget = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Stack(
            children: <Widget>[
              // Stroked text as border.
              Text(
                'Greetings, planet!',
                style: TextStyle(
                  fontSize: 40,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 6
                    ..color = Colors.blue[700]!,
                ),
              ),
              // Solid text as fill.
              Text(
                'Greetings, planet!',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        );
        break;
      case _textGradient:
        returnWidget = ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Stack(
            children: <Widget>[
              // Gradient text.
              Text(
                'Greetings, planet!',
                style: TextStyle(
                  fontSize: 40,
                  foreground: Paint()
                    ..shader = ui.Gradient.linear(
                      const Offset(0, 20),
                      const Offset(150, 20),
                      <Color>[
                        Colors.red,
                        Colors.yellow,
                      ],
                    )
                ),
              ),
            ],
          ),
        );
        break;
      default:
        returnWidget = const Text('Error');
        break;
    }

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(240.0, 140.0)),
      child: Container(
        alignment: FractionalOffset.center,
        padding: const EdgeInsets.all(5.0),
        color: Colors.white,
        child: returnWidget,
      ),
    );
  }
}

class TextHeightDiagram extends StatelessWidget implements DiagramMetadata {
  const TextHeightDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: ' AaBbGgJj ',
        style: TextStyle(
          fontSize: 100,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    return Container(
      width: 800,
      height: 200,
      color: Colors.white,
      child: CustomPaint(
        size: const Size(1000, 300),
        painter: TextDiagramPainter(textPainter),
      ),
    );
  }
}

class TextDiagramPainter extends CustomPainter {
  const TextDiagramPainter(this.textPainter);

  final TextPainter textPainter;

  static const int largeIndex = 99;

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.layout();

    final List<TextBox> boxes = textPainter.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: largeIndex)
    );

    final Paint paint = Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 3.5;
    const double top = 0;
    final double bottom = textPainter.height;
    final double baseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

    final double ratio = 100.0 / textPainter.height;
    final double emTop = baseline - (baseline - top) * ratio;
    final double emBottom = baseline + (bottom - baseline) * ratio;

    final double width = boxes[boxes.length - 1].right;
    final Offset baseOffset = Offset((size.width - width) / 2, (size.height - textPainter.height) / 2);

    textPainter.paint(canvas, baseOffset);
    // Baseline
    canvas.drawLine(
      baseOffset + Offset(0, baseline),
      baseOffset + Offset(width, baseline),
      paint,
    );

    paint.color = Colors.blue[900]!;
    // Top
    canvas.drawLine(
      baseOffset,
      baseOffset + Offset(width, top),
      paint,
    );

    // Bottom
    canvas.drawLine(
      baseOffset + Offset(0, bottom),
      baseOffset + Offset(width, bottom),
      paint,
    );

    paint.strokeWidth = 2;
    paint.color = Colors.red[900]!;
    // emTop
    canvas.drawLine(
      baseOffset + Offset(0, emTop),
      baseOffset + Offset(width, emTop),
      paint,
    );

    // emBottom
    canvas.drawLine(
      baseOffset + Offset(0, emBottom),
      baseOffset + Offset(width, emBottom),
      paint,
    );

    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;

    Path path = Path();
    path.moveTo(baseOffset.dx + width + 10, baseOffset.dy + emTop);
    path.lineTo(baseOffset.dx + width + 25, baseOffset.dy + emTop);
    path.lineTo(baseOffset.dx + width + 25, baseOffset.dy + emBottom);
    path.lineTo(baseOffset.dx + width + 10, baseOffset.dy + emBottom);
    canvas.drawPath(path, paint);

    paint.color = Colors.blue[900]!;
    path = Path();
    path.moveTo(baseOffset.dx - 10, baseOffset.dy + top);
    path.lineTo(baseOffset.dx - 25, baseOffset.dy + top);
    path.lineTo(baseOffset.dx - 25, baseOffset.dy + bottom);
    path.lineTo(baseOffset.dx - 10, baseOffset.dy + bottom);
    canvas.drawPath(path, paint);

    const double margin = 8;

    TextPainter label = TextPainter(
      text: const TextSpan(
        text: 'Font metrics\ndefault height',
        style: TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    label.layout();
    label.paint(canvas, baseOffset + Offset(-25.0 - (paint.strokeWidth + margin) - label.width, (top + bottom) / 2 - 16));

    paint.color = Colors.red[900]!;
    label = TextPainter(
      text: const TextSpan(
        text: 'Font Size\n(EM-square)',
        style: TextStyle(
          fontSize: 12,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    label.layout();
    label.paint(canvas, baseOffset + Offset(width + 25 + margin, (emTop + emBottom) / 2 - 16));

    paint.color = Colors.black;
    // Baseline label
    label = TextPainter(
      text: const TextSpan(
        text: 'Alphabetic Baseline',
        style: TextStyle(
          fontSize: 11,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    label.layout();
    label.paint(canvas, baseOffset + Offset(0, baseline + 3));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final TextDiagramPainter diagramPainter = oldDelegate as TextDiagramPainter;
    return textPainter != diagramPainter.textPainter;
  }
}

// Height values comparison.
class TextHeightComparison extends TextHeightDiagram implements DiagramMetadata {
  const TextHeightComparison(String name) : super(name);

  @override
  Widget build(BuildContext context) {

    double totalHeight = 70.0 + 10;
    for (final double h in <double>[1, 1, 1.15, 2, 3]) {
      totalHeight += 70 * h + 30;
    }

    return Container(
      width: 600,
      height: totalHeight,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            width: 600,
            height: 70,
            color: const Color.fromARGB(255, 180, 180, 180),
            child: const Center(
              child: Text(
                'Roboto, fontSize:50',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const CustomPaint(
            size: Size(600, 70.0 + 30 + 10),
            painter: TextHeightComparisonPainter('Axy', null, 0),
          ),
          const CustomPaint(
            size: Size(600, 70.0 * 1.0 + 30),
            painter: TextHeightComparisonPainter('Axy', 1, 1),
          ),
          const CustomPaint(
            size: Size(600, 70.0 * 1.15 + 30),
            painter: TextHeightComparisonPainter('Axy', 1.15, 2),
          ),
          const CustomPaint(
            size: Size(600, 70.0 * 2.0 + 30),
            painter: TextHeightComparisonPainter('Axy', 2, 3),
          ),
          const CustomPaint(
            size: Size(600, 70.0 * 3.0 + 30),
            painter: TextHeightComparisonPainter('Axy', 3, 4),
          ),
        ],
      ),
    );
  }
}

class TextHeightComparisonPainter extends CustomPainter {

  const TextHeightComparisonPainter(this.text, this.height, this.index);

  final String text;
  final double? height;
  final int index;

  static const int largeIndex = 99;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    if (index % 2 == 0) {
      paint.color = const Color.fromARGB(255, 235, 235, 235);
    } else {
      paint.color = const Color.fromARGB(255, 250, 250, 250);
    }
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: 'height:$height, $text',
        style: TextStyle(
          fontSize: 50,
          height: height,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final List<TextBox> boxes = textPainter.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: largeIndex)
    );

    paint.color = Colors.black;
    paint.strokeWidth = 3.5;
    const double top = 0;
    final double bottom = textPainter.height;
    final double baseline = textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);

    final double width = boxes[boxes.length - 1].right;
    final Offset baseOffset = Offset((size.width - width) / 2 + 30, (size.height - textPainter.height) / 2);

    textPainter.paint(canvas, baseOffset);

    paint.color = Colors.red[900]!;
    // Top
    canvas.drawLine(
      baseOffset,
      baseOffset + Offset(width, top),
      paint,
    );

    // Bottom
    canvas.drawLine(
      baseOffset + Offset(0, bottom),
      baseOffset + Offset(width, bottom),
      paint,
    );

    // Baseline
    paint.color = Colors.black;
    paint.strokeWidth = 2.5;
    canvas.drawLine(
      baseOffset + Offset(0, baseline),
      baseOffset + Offset(width, baseline),
      paint,
    );

    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;

    paint.color = Colors.blue[900]!;
    final Path path = Path();
    path.moveTo(baseOffset.dx - 10, baseOffset.dy + top);
    path.lineTo(baseOffset.dx - 25, baseOffset.dy + top);
    path.lineTo(baseOffset.dx - 25, baseOffset.dy + bottom);
    path.lineTo(baseOffset.dx - 10, baseOffset.dy + bottom);
    canvas.drawPath(path, paint);

    TextPainter label = TextPainter(
      text: TextSpan(
        text:'${bottom - top}px',
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    );
    label.layout();
    label.paint(canvas, baseOffset + Offset(-25.0 - 80, (top + bottom) / 2 - 10));

    paint.color = Colors.black;
    // Baseline label
    label = TextPainter(
      text: const TextSpan(
        text: 'Alphabetic Baseline',
        style: TextStyle(
          fontSize: 9,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    label.layout();
    label.paint(canvas, baseOffset + Offset(0, baseline + 1));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final TextHeightComparisonPainter diagramPainter = oldDelegate as TextHeightComparisonPainter;
    return text != diagramPainter.text || height != diagramPainter.height;
  }
}

/// Side-by-side comparison of paragraphs with different text height
/// configuration combinations.
class TextHeightBreakdown extends TextHeightDiagram implements DiagramMetadata {
  const TextHeightBreakdown(String name) : super(name);

  static const double _height = 4;
  static const double _fontSize = 90;
  static const String _text = ' Axy ';

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Center(
            child: Text(
              'Roboto, fontSize: $_fontSize, height: $_height',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      // This must be the first child of the column for the Row
                      // elements to be properly baseline-aligned.
                      TextHeightBreakdownRow(
                        text: _text,
                        backgroundColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: _height,
                          color: Colors.black,
                          leadingDistribution: TextLeadingDistribution.proportional,
                        ),
                        paintHeightIndicator: true,
                        paintCaptions: true,
                        paintLeadingIndicator: true,
                      ),
                      SizedBox(height: 30),
                      // This column has the height indicator so the glyph is not
                      // centered. This is a hack to offset the "Configuration 1"
                      // caption so it looks more aligned with the glyph.
                      Text('                        Configuration 1', textScaleFactor: 1.5),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      TextHeightBreakdownRow(
                        text: _text,
                        backgroundColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: _height,
                          color: Colors.black,
                          leadingDistribution:
                              TextLeadingDistribution.proportional,
                        ),
                        textHeightBehavior:
                            TextHeightBehavior(applyHeightToFirstAscent: false),
                        paintCaptions: true,
                      ),
                      SizedBox(height: 30),
                      Text('Configuration 2', textScaleFactor: 1.5),
                    ],
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      TextHeightBreakdownRow(
                        text: _text,
                        backgroundColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: _height,
                          color: Colors.black,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        paintLeadingIndicator: true,
                      ),
                      SizedBox(height: 30),
                      Text('Configuration 3', textScaleFactor: 1.5),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      TextHeightBreakdownRow(
                        text: _text,
                        backgroundColor: Colors.transparent,
                        style: TextStyle(
                          fontSize: _fontSize,
                          height: _height,
                          color: Colors.black,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        textHeightBehavior: TextHeightBehavior(applyHeightToLastDescent: false),
                      ),
                      SizedBox(height: 30),
                      Text('Configuration 4', textScaleFactor: 1.5),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TextHeightBreakdownRow extends LeafRenderObjectWidget {
   const TextHeightBreakdownRow({
     Key? key,
     required this.text,
     required this.backgroundColor,
     required this.style,
     this.textHeightBehavior,
     this.paintHeightIndicator = false,
     this.paintLeadingIndicator = false,
     this.paintCaptions = false,
  }) : super(key: key);

  final String text;
  final TextStyle style;
  final Color backgroundColor;
  final TextHeightBehavior? textHeightBehavior;
  final bool paintHeightIndicator;
  final bool paintLeadingIndicator;
  final bool paintCaptions;

  @override
  RenderTextHeightBreakdown createRenderObject(BuildContext context) {
    return RenderTextHeightBreakdown(
      text: TextSpan(text: text, style: style),
      backgroundColor: backgroundColor,
      textDirection: Directionality.of(context),
      textHeightBehavior: textHeightBehavior,
      paintHeightIndicator: paintHeightIndicator,
      paintLeadingIndicator: paintLeadingIndicator,
      paintCaptions: paintCaptions,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTextHeightBreakdown renderObject) {
    renderObject
      ..text = TextSpan(text: text, style: style)
      ..backgroundColor = backgroundColor
      ..textDirection = Directionality.of(context)
      ..textHeightBehavior = textHeightBehavior
      ..paintHeightIndicator = paintHeightIndicator
      ..paintLeadingIndicator = paintLeadingIndicator
      ..paintCaptions = paintCaptions;
  }
}

class RenderTextHeightBreakdown extends RenderBox with RenderObjectWithChildMixin<RenderBox>{
  RenderTextHeightBreakdown({
    required TextDirection textDirection,
    required TextSpan text,
    required Color backgroundColor,
    required TextHeightBehavior? textHeightBehavior,
    required bool paintHeightIndicator,
    required bool paintCaptions,
    required bool paintLeadingIndicator,
  })  : _backgroundColor = backgroundColor,
        _paintHeightIndicator = paintHeightIndicator,
        _paintLeadingIndicator = paintLeadingIndicator,
        _paintCaptions = paintCaptions,
        _textPainter = TextPainter(
          textDirection: textDirection,
          text: text,
          textHeightBehavior: textHeightBehavior,
        );

  final TextPainter _textPainter;

  TextDirection get textDirection => _textPainter.textDirection!;
  set textDirection(TextDirection value) {
    if (_textPainter.textDirection == value)
      return;
    _textPainter.textDirection = value;
    markNeedsLayout();
  }

  TextSpan get text => _textPainter.text as TextSpan;
  set text(TextSpan? value) {
    if (_textPainter.text == value)
      return;
    _textPainter.text = value;
    markNeedsLayout();
  }

  Color get backgroundColor => _backgroundColor;
  Color _backgroundColor;
  set backgroundColor(Color value) {
    if (value == _backgroundColor) {
      return;
    }
    _backgroundColor = value;
    markNeedsPaint();
  }

  TextHeightBehavior? get textHeightBehavior => _textPainter.textHeightBehavior;
  set textHeightBehavior(TextHeightBehavior? newValue) {
    if (textHeightBehavior == newValue) {
      return;
    }
    _textPainter.textHeightBehavior = newValue;
    markNeedsLayout();
  }

  bool get paintHeightIndicator => _paintHeightIndicator;
  bool _paintHeightIndicator;
  set paintHeightIndicator(bool value) {
    if (value == _paintHeightIndicator)
      return;

    _paintHeightIndicator = value;
    markNeedsPaint();
  }

  bool get paintLeadingIndicator => _paintLeadingIndicator;
  bool _paintLeadingIndicator;
  set paintLeadingIndicator(bool value) {
    if (value == _paintLeadingIndicator)
      return;
    _paintLeadingIndicator = value;
    markNeedsPaint();
  }

  bool get paintCaptions => _paintCaptions;
  bool _paintCaptions;
  set paintCaptions(bool value) {
    if (value == _paintCaptions)
      return;
    _paintCaptions = value;
    markNeedsPaint();
  }

  late final TextPainter heightCaptionTextPainter = TextPainter(textDirection: textDirection, textAlign: TextAlign.center);
  static late final TextStyle heightCaptionTextStyle = TextStyle(fontSize: 20, color: Colors.blue[900]!);
  static const Offset fontMetricsLabelPadding = Offset(0, 3);
  static const double heightCaptionBracketMinX = -25;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    _textPainter.layout(minWidth: constraints.minWidth, maxWidth: double.infinity);
    if (paintHeightIndicator) {
      heightCaptionTextPainter.text = TextSpan(text: 'Text Height:\n${_textPainter.height} px', style: heightCaptionTextStyle);
      heightCaptionTextPainter.layout(minWidth: constraints.minWidth, maxWidth: double.infinity);
      return constraints.constrain(Size(
        heightCaptionTextPainter.width + _textPainter.width + fontMetricsLabelPadding.dx - heightCaptionBracketMinX,
        max(heightCaptionTextPainter.height, _textPainter.height),
      ));
    }
    return constraints.constrain(_textPainter.size);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) => _textPainter.computeDistanceToActualBaseline(baseline);

  @override
  void performLayout() {
    size = computeDryLayout(constraints);
    assert(size.height == _textPainter.height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Paint paint = Paint();
    final Canvas canvas = context.canvas;
    paint.color = backgroundColor;
    // Paint the background color.
    canvas.drawRect(offset & size, paint);

    final Offset lineBoxOrigin = paintHeightIndicator
      // Left-align the height caption. Ideally this should also be centered.
      ? Offset(heightCaptionTextPainter.width + fontMetricsLabelPadding.dx - heightCaptionBracketMinX, 0) + offset
      : (size - _textPainter.size as Offset) / 2 + offset;

    assert(lineBoxOrigin.dy == offset.dy);
    // Paint the text. Layout is done in performLayout.
    _textPainter.paint(canvas, lineBoxOrigin);

    // Change the coordinate space to the line box (i.e. in textPainter
    // coordinates), paint the guides and labels.
    canvas.save();
    canvas.translate(lineBoxOrigin.dx, lineBoxOrigin.dy);

    final List<TextBox> boxes = _textPainter.getBoxesForSelection(TextSelection(baseOffset: 0, extentOffset: text.text!.length));
    assert(boxes.length == 1);
    final Rect glyphsBox = boxes.first.toRect();

    paint.strokeWidth = 7.5;
    paint.color = Colors.blue[900]!;
    final double guideWidth = max(size.width - lineBoxOrigin.dx, glyphsBox.right);
    // Top guide
    canvas.drawLine(Offset.zero, Offset(guideWidth, 0), paint);
    // Bottom guide
    canvas.drawLine(Offset(0, _textPainter.height), Offset(guideWidth, _textPainter.height), paint);

    paint.strokeWidth = 2.5;
    paint.color = Colors.red[900]!;
    // Glyph ascent guide
    canvas.drawLine(Offset(0, glyphsBox.top), Offset(guideWidth, glyphsBox.top), paint);
    // Glyph descent guide
    canvas.drawLine(Offset(0, glyphsBox.bottom), Offset(guideWidth, glyphsBox.bottom), paint);

    // Baseline
    paint.strokeWidth = 2.5;
    paint.color = Colors.black;
    final double baseline = _textPainter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    canvas.drawLine(
      Offset(0, baseline),
      Offset(guideWidth, baseline),
      paint,
    );

    if (paintHeightIndicator) {
      _doPaintHeightIndicator(canvas, _textPainter.size);
    }

    if (paintCaptions) {
      _doPaintCaptions(canvas, _textPainter.size, glyphsBox, baseline);
    }

    if (paintLeadingIndicator) {
      _doPaintLeadingIndicators(canvas, Size(guideWidth, _textPainter.height), glyphsBox);
    }
    canvas.restore();
  }

  void _doPaintLeadingIndicators(Canvas canvas, Size size, Rect glyphsBox) {
    final TextStyle textStyle = TextStyle(fontSize: 9, color: Colors.blue[900]!);
    final TextPainter labelPainter = TextPainter(
      text: TextSpan(text: 'Top Leading', style: textStyle),
      textAlign: TextAlign.right,
      textDirection: textDirection,
    );

    final Paint paint = Paint();
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.blue[900]!;

    void drawPointedLine(Offset start, Offset end) {
      final Path path = Path();
      final double pointDirection = end.dy > start.dy ? -1 : 1;
      const double arrowScale = 5;

      final Offset arrowPoint1 = end + Offset(1, pointDirection) * arrowScale;
      final Offset arrowPoint2 = end + Offset(-1, pointDirection) * arrowScale;

      path.moveTo(end.dx, end.dy);
      path.lineTo(arrowPoint1.dx, arrowPoint1.dy);
      path.moveTo(end.dx, end.dy);
      path.lineTo(arrowPoint2.dx, arrowPoint2.dy);
      path.moveTo(end.dx, end.dy);
      path.lineTo(start.dx, start.dy);
      canvas.drawPath(path, paint);
    }

    // Top Leading Area
    if (glyphsBox.top > 1) {
      labelPainter.layout();
      final Rect topLeadingArea = Offset.zero & Size(size.width, glyphsBox.top);
      final Rect topTextRect = Rect.fromCenter(
        center: topLeadingArea.center,
        width: labelPainter.width,
        height: labelPainter.height,
      );
      labelPainter.paint(canvas, topTextRect.topLeft);

      drawPointedLine(
        -fontMetricsLabelPadding + topTextRect.topCenter,
        fontMetricsLabelPadding * 2 + topLeadingArea.topCenter,
      );

      drawPointedLine(
        fontMetricsLabelPadding + topTextRect.bottomCenter,
        -fontMetricsLabelPadding + topLeadingArea.bottomCenter,
      );
    }

    if (glyphsBox.bottom >= size.height - 1)
      return;
    // Bottom Leading Area
    labelPainter.text = TextSpan(text: 'Bottom Leading', style: textStyle);
    labelPainter.layout();
    final Rect bottomLeadingArea = Offset(0, glyphsBox.bottom) & Size(size.width, size.height - glyphsBox.bottom);
    final Rect bottomTextRect = Rect.fromCenter(
      center: bottomLeadingArea.center,
      width: labelPainter.width,
      height: labelPainter.height,
    );
    labelPainter.paint(canvas, bottomTextRect.topLeft);

    drawPointedLine(
      -fontMetricsLabelPadding + bottomTextRect.topCenter,
      fontMetricsLabelPadding + bottomLeadingArea.topCenter,
    );

    drawPointedLine(
      fontMetricsLabelPadding + bottomTextRect.bottomCenter,
      fontMetricsLabelPadding * -2 + bottomLeadingArea.bottomCenter,
    );
  }

  void _doPaintHeightIndicator(Canvas canvas, Size size) {
    final Paint paint = Paint();
    // Height bracket & label
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.blue[900]!;

    final Path path = Path();
    path.moveTo(- 10, 0);
    path.lineTo(heightCaptionBracketMinX, 0);
    path.lineTo(heightCaptionBracketMinX, size.height);
    path.lineTo(- 10, size.height);
    canvas.drawPath(path, paint);

    // Layout is done in performLayout.
    final Offset origin = Offset(
      heightCaptionBracketMinX - heightCaptionTextPainter.width,
      (size.height - heightCaptionTextPainter.height) / 2,
    ) - fontMetricsLabelPadding;
    heightCaptionTextPainter.paint(canvas, origin);
  }

  void _doPaintCaptions(Canvas canvas, Size size, Rect glyphsBox, double baseline) {
    // Ascent
    final TextPainter labelPainter = TextPainter(
      text: TextSpan(
        text:'Font Ascent',
        style: TextStyle(
          fontSize: 9,
          color: Colors.red[900]!,
        ),
      ),
      textAlign: TextAlign.right,
      textDirection: textDirection,
    );
    labelPainter.layout();
    Offset labelPaintOrigin = Offset(0, glyphsBox.top - labelPainter.height) - fontMetricsLabelPadding;
    labelPainter.paint(canvas, labelPaintOrigin);

    // Descent
    labelPainter.text = TextSpan(
      text: 'Font Descent',
      style: TextStyle(
        fontSize: 9,
        color: Colors.red[900]!,
      ),
    );
    labelPainter.layout();
    labelPaintOrigin = Offset(0, glyphsBox.bottom) + fontMetricsLabelPadding;
    labelPainter.paint(canvas, labelPaintOrigin);

     // Baseline
    labelPainter.text = const TextSpan(
      text: 'Alphabetic Baseline',
      style: TextStyle(
        fontSize: 9,
        color: Colors.black,
      ),
    );
    labelPainter.layout();
    labelPaintOrigin = Offset(0, baseline) + fontMetricsLabelPadding;
    labelPainter.paint(canvas, labelPaintOrigin);

    // Top
    labelPainter.text = TextSpan(
      text: 'Text Top',
      style: TextStyle(
        fontSize: 9,
        color: Colors.blue[900]!,
      ),
    );
    labelPainter.layout();
    labelPaintOrigin = Offset.zero + fontMetricsLabelPadding * 2;
    labelPainter.paint(canvas, labelPaintOrigin);

    labelPainter.text = TextSpan(
      text: 'Text Bottom',
      style: TextStyle(
        fontSize: 9,
        color: Colors.blue[900]!,
      ),
    );
    labelPainter.layout();
    labelPaintOrigin = size.bottomLeft(Offset.zero) - Offset(0, labelPainter.height) - fontMetricsLabelPadding * 2;
    labelPainter.paint(canvas, labelPaintOrigin);
  }
}

class TextHeightDiagramStep extends DiagramStep<TextHeightDiagram> {
  TextHeightDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'painting';

  @override
  Future<List<TextHeightDiagram>> get diagrams async => <TextHeightDiagram>[
    const TextHeightDiagram('text_height_diagram'),
    const TextHeightComparison('text_height_comparison_diagram'),
    const TextHeightBreakdown('text_height_breakdown'),
  ];

  @override
  Future<File> generateDiagram(TextHeightDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

class TextDiagramStep extends DiagramStep<TextDiagram> {
  TextDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'widgets';

  @override
  Future<List<TextDiagram>> get diagrams async => <TextDiagram>[
    const TextDiagram(_text),
    const TextDiagram(_textEllipsis),
    const TextDiagram(_textRich),
    const TextDiagram(_textBorder),
    const TextDiagram(_textGradient),
  ];

  @override
  Future<File> generateDiagram(TextDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

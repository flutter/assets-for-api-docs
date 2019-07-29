// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

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
                    ..color = Colors.blue[700],
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

    return new ConstrainedBox(
      key: new UniqueKey(),
      constraints: new BoxConstraints.tight(const Size(240.0, 140.0)),
      child: new Container(
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

    paint.color = Colors.blue[900];
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
    paint.color = Colors.red[900];
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

    paint.color = Colors.blue[900];
    path = Path();
    path.moveTo(baseOffset.dx - 10, baseOffset.dy + top);
    path.lineTo(baseOffset.dx - 25, baseOffset.dy + top);
    path.lineTo(baseOffset.dx - 25, baseOffset.dy + bottom);
    path.lineTo(baseOffset.dx - 10, baseOffset.dy + bottom);
    canvas.drawPath(path, paint);

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
    label.paint(canvas, baseOffset + Offset(-25.0 - 80, (top + bottom) / 2 - 16));

    paint.color = Colors.red[900];
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
    label.paint(canvas, baseOffset + Offset(width + 25 + 8, (emTop + emBottom) / 2 - 16));

    paint.color = Colors.black;
    // Baseline label
    label = TextPainter(
      text: const TextSpan(
        text: 'Baseline',
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
    final TextDiagramPainter diagramPainter = oldDelegate;
    return textPainter != diagramPainter.textPainter;
  }
}

// Height values comparison.
class TextHeightComparison extends TextHeightDiagram implements DiagramMetadata {
  const TextHeightComparison(String name) : super(name);

  @override
  Widget build(BuildContext context) {

    double totalHeight = 70.0 + 10;
    for (double h in <double>[1, 1, 1.15, 2, 3]) {
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
  final double height;
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

    paint.color = Colors.red[900];
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

    paint.color = Colors.blue[900];
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
        text:'Baseline',
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
    final TextHeightComparisonPainter diagramPainter = oldDelegate;
    return text != diagramPainter.text || height != diagramPainter.height;
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
      ];

  @override
  Future<File> generateDiagram(TextHeightDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
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
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

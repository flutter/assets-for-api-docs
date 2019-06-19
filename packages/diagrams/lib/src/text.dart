// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'diagram_step.dart';

class TextDiagram extends StatelessWidget implements DiagramMetadata {
  const TextDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text:' Aalg我हिन्दी ',
        style: TextStyle(
          fontSize: 100,
          color: Colors.black,
        ),
      ),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    switch (name) {
      case 'text_height_diagram':
        return Container(
          width: 800,
          height: 200,
          color: Colors.white,
          child: CustomPaint(
            size: Size(1000, 300),
            painter: CurvePainter(textPainter),
            child: Center(
              child: Stack(
                alignment: Alignment(0, 0),
                children: <Widget>[
                  // Text('Hello'),

                ],
              ),
            ),
          ),
        );
        break;
      default:
        return const Text('Error');
        break;
    }
  }
}

class CurvePainter extends CustomPainter {

  const CurvePainter(this.textPainter);

  final TextPainter textPainter;

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.layout();

    List<TextBox> boxes = textPainter.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: 99)
    );

    var paint = Paint();
    paint.color = Colors.black;
    paint.strokeWidth = 3.5;
    final double top = 0;
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

    var path = Path();
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
      text: TextSpan(
        text:'Font metrics\ndefault height',
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
      text: TextSpan(
        text:'Font Size\n(EM-square)',
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
      text: TextSpan(
        text:'Baseline',
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
    return false;
  }
}

class TextDiagramStep extends DiagramStep<TextDiagram> {
  TextDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'painting';

  @override
  Future<List<TextDiagram>> get diagrams async => <TextDiagram>[
        const TextDiagram('text_height_diagram'),
      ];

  @override
  Future<File> generateDiagram(TextDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(new File('${diagram.name}.png'));
  }
}

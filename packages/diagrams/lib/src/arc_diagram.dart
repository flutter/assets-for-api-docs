import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'diagram_step.dart';

class Palette {
  const Palette({
    required this.primary,
    required this.text,
    required this.subtitle,
    required this.background,
    required this.method,
    required this.operator,
    required this.literal,
    required this.comment,
  });

  final Color primary;
  final Color text;
  final Color subtitle;
  final Color background;
  final Color method;
  final Color operator;
  final Color literal;
  final Color comment;
}

const Palette palette = Palette(
  primary: Color(0xff447bef),
  text: Color(0xff383a42),
  subtitle: Color(0xff9c9cb1),
  background: Colors.white,
  method: Color(0xff447bef),
  operator: Color(0xff1485ba),
  literal: Color(0xffe2574e),
  comment: Color(0xffa0a1a7),
);

enum SpanType {
  text,
  method,
  comment,
  literal,
  operator,
}

class CodeSpan {
  const CodeSpan(this.type, this.text);

  final SpanType type;
  final String text;
}

class CodeStyles {
  CodeStyles({
    required this.palette,
    required this.fontSize,
    required this.fontFamily,
    this.package,
  });

  final Palette palette;
  final double fontSize;
  final String fontFamily;
  final String? package;

  late final TextStyle baseStyle = TextStyle(
    color: palette.text,
    fontSize: fontSize,
    fontFamily: fontFamily,
    package: package,
  );

  late final Map<SpanType, TextStyle> styles = <SpanType, TextStyle>{
    SpanType.text: baseStyle,
    SpanType.method: baseStyle.copyWith(color: palette.method),
    SpanType.comment: baseStyle.copyWith(color: palette.comment),
    SpanType.literal: baseStyle.copyWith(color: palette.literal),
    SpanType.operator: baseStyle.copyWith(color: palette.operator),
  };

  TextSpan highlight(List<CodeSpan> spans) {
    return TextSpan(
      children: <TextSpan>[
        for (final CodeSpan span in spans)
          TextSpan(
            style: styles[span.type],
            text: span.text,
          ),
      ],
    );
  }
}

final CodeStyles codeStyles = CodeStyles(
  palette: palette,
  fontSize: 16.0,
  fontFamily: 'Ubuntu Mono',
);

/// Paints text around an arc on the given [canvas].
///
/// This works best when [rect] is a perfect square.
void paintTextArc(
  Canvas canvas,
  String text, {
  bool inside = true,
  bool clockwise = false,
  required Rect rect,
  required double theta,
  required double alignment,
  required TextStyle style,
  double? letterSpacing = 4.0,
}) {
  style = style.copyWith(letterSpacing: letterSpacing);

  if (text.isEmpty) {
    return;
  }

  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  );

  // Lay out the full text and step through each character to get their offsets.
  textPainter.layout();
  final List<double> letterOffsets = <double>[];
  for (int i = 0; i < text.length + 1; i++) {
    letterOffsets.add(
      textPainter.getOffsetForCaret(TextPosition(offset: i), Rect.zero).dx,
    );
  }

  // Calculate the baseline / middle radius, adjusting for whether or not the
  // text is on the inside of the circle or running clockwise.
  final LineMetrics lineMetrics = textPainter.computeLineMetrics().single;
  final Rect baselineRect = rect.inflate(inside
      ? (clockwise ? lineMetrics.descent : -lineMetrics.height)
      : (clockwise ? lineMetrics.height : 0.0));
  final Rect centerRect =
      rect.inflate(inside ? lineMetrics.height / -2 : lineMetrics.height / 2);

  // Calculate the aligned start offset (in pixels) and then the ratio of pixels
  // to radians.
  final double endOffset = letterOffsets.last;
  final double textOffset = (-endOffset / 2) + (alignment * endOffset / 2);
  final double circumference = (centerRect.width + centerRect.height) * 2;
  final double thetaPixels = pi * 2 / circumference;

  for (int i = 0; i < text.length; i++) {
    // Calculate the offset and angle of the center of the letter, using the
    // center is important because the text looks weird if we rotate it from
    // the top left.
    final String letter = text[i];
    final double letterOffset = letterOffsets[i];
    final double letterWidth = letterOffsets[i + 1] - letterOffset;
    final double offset = (letterOffset + textOffset) + letterWidth / 2;
    final double arcTheta =
        theta + offset * (clockwise ? thetaPixels : -thetaPixels);
    final Offset arcOffset = Offset(
          cos(arcTheta) * baselineRect.width / 2,
          sin(arcTheta) * baselineRect.height / 2,
        ) +
        baselineRect.center;

    // Finally paint the letter.
    canvas.save();
    canvas.translate(arcOffset.dx, arcOffset.dy);
    canvas.rotate(arcTheta + pi / (clockwise ? 2 : -2));
    textPainter.text = TextSpan(text: letter, style: style);
    textPainter.layout();
    textPainter.paint(canvas, Offset(letterWidth / -2, 0));
    canvas.restore();
  }
}

/// Adds a dotted arc as new segments to [path].
///
/// The [strokeLength] parameter is the ideal length of a stroke in pixels, and
/// [spaceLength] is the ideal length of the space between strokes in pixels.
///
/// The stroke and space lengths are automatically adjusted so that the dashes
/// are placed symmetrically, this works best when the arc is large and the
/// strokes are small.
void addDottedArcTo(
  Path path, {
  required Rect rect,
  required double startAngle,
  required double sweepAngle,
  required double strokeLength,
  required double spaceLength,
  bool forceMoveTo = false,
}) {
  // Compute the number of segments and stroke length that closest matches
  // idealStrokeLength and idealSpaceLength, scaling them to ensure there are
  // dashes at both ends of the arc.
  final Path arcPath = Path()..addArc(rect, startAngle, sweepAngle);
  final PathMetric arcMetrics = arcPath.computeMetrics().single;
  final double arcLength = arcMetrics.length;
  final int numSegments = (arcLength / (strokeLength + spaceLength)).round();
  final double interval =
      (arcLength / numSegments) + (spaceLength / numSegments);
  final double effectiveStrokeLength =
      interval * (strokeLength / (spaceLength + strokeLength));

  // Get the tangents of the start and end of each segment, then use addArc to
  // add them to the path.
  for (int i = 0; i < numSegments; i++) {
    final double startDistance = i * interval;
    final Tangent startTangent = arcMetrics.getTangentForOffset(startDistance)!;
    final Tangent endTangent =
        arcMetrics.getTangentForOffset(startDistance + effectiveStrokeLength)!;
    final double startTheta = -startTangent.angle - pi / 2;
    final double endTheta = -endTangent.angle - pi / 2;
    path.addArc(
      rect,
      startTheta,
      (endTheta - startTheta) % (pi * 2),
    );
  }
}

/// Draws a dotted arc to [canvas], see [addDottedArcTo].
void paintDottedArc(
  Canvas canvas, {
  required Rect rect,
  required double startAngle,
  required double sweepAngle,
  required double strokeLength,
  required double spaceLength,
  bool forceMoveTo = false,
  required Paint paint,
}) {
  final Path path = Path();
  addDottedArcTo(
    path,
    rect: rect,
    startAngle: startAngle,
    sweepAngle: sweepAngle,
    strokeLength: strokeLength,
    spaceLength: spaceLength,
    forceMoveTo: true,
  );
  canvas.drawPath(path, paint);
}

/// Paints an anchor to [canvas], this is commonly represented in vector editing
/// software as a square outline.
void paintAnchor(
  Canvas canvas,
  Offset offset,
  Color color, {
  double size = 10.0,
}) {
  final Paint paint = Paint()
    ..color = palette.background
    ..style = PaintingStyle.fill;
  canvas.drawRect(
    Rect.fromCenter(center: offset, width: size, height: size),
    paint,
  );
  paint
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  canvas.drawRect(
    Rect.fromCenter(center: offset, width: size, height: size),
    paint,
  );
}

/// Paints [span] to [canvas] with a given offset and alignment.
void paintSpan(
  Canvas canvas,
  TextSpan span, {
  required Offset offset,
  Alignment alignment = Alignment.center,
  TextAlign textAlign = TextAlign.center,
}) {
  final TextPainter result = TextPainter(
    textDirection: TextDirection.ltr,
    text: span,
    textAlign: textAlign,
  );
  result.layout();
  result.paint(
    canvas,
    Offset(
      offset.dx + (result.width / -2) + (alignment.x * result.width / 2),
      offset.dy + (result.height / -2) + (alignment.y * result.height / 2),
    ),
  );
}

void paintArrowHead(
  Canvas canvas,
  Offset center,
  double angle,
  Color color, {
  double length = 7.0,
  double thickness = 3.0,
  bool bottomOnly = false,
}) {
  final Matrix2 matrix = Matrix2.rotation(angle);
  final Vector2 topVec = matrix.transform(Vector2(-length, length));
  final Vector2 bottomVec = matrix.transform(Vector2(-length, -length));

  final Path path = Path()
    ..moveTo(center.dx + bottomVec.x, center.dy + bottomVec.y)
    ..lineTo(center.dx, center.dy);

  if (!bottomOnly) {
    path.lineTo(center.dx + topVec.x, center.dy + topVec.y);
  }

  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color
      ..strokeWidth = thickness,
  );
}

/// Similar to [paintSpan] but provides a default text style.
void paintLabel(
  Canvas canvas,
  String label, {
  required Offset offset,
  FontStyle style = FontStyle.normal,
  FontWeight fontWeight = FontWeight.normal,
  Color color = Colors.black45,
  double fontSize = 14.0,
  Alignment alignment = Alignment.center,
  TextAlign textAlign = TextAlign.center,
}) {
  paintSpan(
    canvas,
    TextSpan(
      text: label,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        fontStyle: style,
        fontSize: fontSize,
      ),
    ),
    offset: offset,
    alignment: alignment,
    textAlign: textAlign,
  );
}

class ArcDiagramPainter extends CustomPainter {
  const ArcDiagramPainter({
    required this.startAngle,
    required this.sweepAngle,
    this.startLabelAlignment = 0.5,
    this.sweepLabelAlignment = 0.5,
  });

  final double startAngle;
  final double sweepAngle;
  final double startLabelAlignment;
  final double sweepLabelAlignment;

  @override
  void paint(Canvas canvas, Size size) {
    final Color startArcColor = palette.text;
    final Color sweepArcColor = palette.primary;
    const double arcRectMargin = 32.0;
    const double rectLabelMargin = 8.0;
    final Rect arcRect = Rect.fromLTRB(
      arcRectMargin,
      arcRectMargin + rectLabelMargin,
      size.height - arcRectMargin,
      (size.height - arcRectMargin) + rectLabelMargin,
    );
    const double arcLineThickness = 4.0;
    final bool overlaps = startAngle >= 0 != sweepAngle >= 0;
    final double overlapNudge = overlaps ? 3.5 : 0.0;

    final Offset nudgedArcStart = arcRect.center +
        Offset(
          cos(startAngle) * (arcRect.width / 2 + overlapNudge),
          sin(startAngle) * (arcRect.height / 2 + overlapNudge),
        );

    final Offset arcEnd = arcRect.center +
        Offset(
          cos(startAngle + sweepAngle) * arcRect.width / 2,
          sin(startAngle + sweepAngle) * arcRect.height / 2,
        );

    final Paint paint = Paint()
      ..color = palette.subtitle
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Unit circle, 8 angles at 45 degree increments
    for (int i = 0; i < 8; i++) {
      final double theta = (i / 8) * pi * 2;

      const double rayLength = 16.0;
      const double rayStart = -32.0;
      const double labelStart = -86.0;

      final Offset arcIn = Offset(
        cos(theta) * ((rayStart - rayLength) + arcRect.width / 2),
        sin(theta) * ((rayStart - rayLength) + arcRect.height / 2),
      );

      final Offset arcOut = Offset(
        cos(theta) * (rayStart + arcRect.width / 2),
        sin(theta) * (rayStart + arcRect.height / 2),
      );

      // Draw spokes of unit circle
      canvas.drawLine(
        arcRect.center + arcIn,
        arcRect.center + arcOut,
        paint,
      );

      final Offset labelOffset = arcRect.center +
          Offset(
            cos(theta) * (labelStart + arcRect.width / 2),
            sin(theta) * (labelStart + arcRect.height / 2),
          );

      // Label text for each angle
      paintSpan(
        canvas,
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: const <String>[
                '0°, 360°',
                '45°',
                '90°',
                '135°',
                '180°',
                '225°',
                '270°',
                '315°',
              ][i],
            ),
            const TextSpan(text: '\n'),
            TextSpan(
              text: const <String>[
                '0, 2π',
                'π/4',
                'π/2',
                '3π/4',
                'π',
                '5π/4',
                '3π/2',
                '7π/4',
              ][i],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
          style: TextStyle(
            color: palette.subtitle,
          ),
        ),
        offset: labelOffset,
      );
    }

    // Draw rect + label text
    paint
      ..color = palette.subtitle
      ..strokeWidth = 3.0;
    canvas.drawRect(arcRect, paint);
    paintLabel(
      canvas,
      'rect',
      offset: arcRect.topLeft - const Offset(0, 4),
      alignment: Alignment.topRight,
      color: palette.subtitle,
      fontSize: 18.0,
      fontWeight: FontWeight.bold,
    );

    // Draw arrow at sweepAngle
    paintArrowHead(
      canvas,
      arcEnd,
      startAngle + sweepAngle + pi / (startAngle > sweepAngle ? -2 : 2),
      sweepArcColor,
      thickness: arcLineThickness,
      bottomOnly: overlaps,
    );

    // Draw indicator for startAngle
    paint
      ..color = startArcColor
      ..strokeWidth = arcLineThickness;
    paintDottedArc(
      canvas,
      rect: arcRect.inflate(overlapNudge),
      startAngle: 0,
      sweepAngle: startAngle,
      strokeLength: 22.0,
      spaceLength: 16.0,
      paint: paint,
    );
    paintTextArc(
      canvas,
      'startAngle',
      rect: arcRect.deflate(overlaps ? 4.0 : 4.0),
      style: TextStyle(
        color: startArcColor,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      alignment: 0.0,
      theta: startAngle * startLabelAlignment,
    );

    // Draw indicator for sweepAngle
    paint
      ..color = sweepArcColor
      ..strokeWidth = arcLineThickness;
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, paint);
    paintTextArc(
      canvas,
      'sweepAngle',
      rect: arcRect.deflate(4.0),
      style: TextStyle(
        color: sweepArcColor,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
      alignment: 0.0,
      theta: lerpDouble(
        startAngle,
        startAngle + sweepAngle,
        sweepLabelAlignment,
      )!,
    );

    // Draw arrow at startAngle
    paintArrowHead(
      canvas,
      nudgedArcStart,
      startAngle + pi / 2,
      startArcColor,
      thickness: arcLineThickness,
      bottomOnly: overlaps,
    );
  }

  @override
  bool shouldRepaint(ArcDiagramPainter oldDelegate) {
    return false;
  }
}

abstract class ArcDiagram extends StatelessWidget implements DiagramMetadata {
  const ArcDiagram({super.key});
}

class CanvasDrawArcDiagram extends ArcDiagram {
  const CanvasDrawArcDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.background,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 400,
            height: 400,
            child: CustomPaint(
              foregroundPainter: ArcDiagramPainter(
                startAngle: pi / 2,
                sweepAngle: 3 * pi / 4,
              ),
            ),
          ),
          SizedBox(
            width: 300,
            child: Text.rich(
              codeStyles.highlight(const <CodeSpan>[
                CodeSpan(SpanType.text, 'canvas.'),
                CodeSpan(SpanType.method, 'drawArc'),
                CodeSpan(SpanType.text, '('),
                CodeSpan(SpanType.text, '\n  rect,'),
                CodeSpan(SpanType.text, '\n  pi '),
                CodeSpan(SpanType.operator, '/ '),
                CodeSpan(SpanType.literal, '2'),
                CodeSpan(SpanType.text, ','),
                CodeSpan(SpanType.comment, '     // 90° startAngle'),
                CodeSpan(SpanType.literal, '\n  3 '),
                CodeSpan(SpanType.operator, '* '),
                CodeSpan(SpanType.text, 'pi '),
                CodeSpan(SpanType.operator, '/ '),
                CodeSpan(SpanType.literal, '4'),
                CodeSpan(SpanType.text, ','),
                CodeSpan(SpanType.comment, ' // 135° sweepAngle'),
                CodeSpan(SpanType.literal, '\n  false'),
                CodeSpan(SpanType.text, ','),
                CodeSpan(SpanType.text, '\n  paint,'),
                CodeSpan(SpanType.text, '\n);'),
              ]),
            ),
          )
        ],
      ),
    );
  }

  @override
  String get name => 'canvas_draw_arc';
}

class PathAddArcDiagram extends ArcDiagram {
  const PathAddArcDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.background,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 400,
            height: 400,
            child: CustomPaint(
              foregroundPainter: ArcDiagramPainter(
                startAngle: pi / 2,
                sweepAngle: 3 * pi / 4,
              ),
            ),
          ),
          SizedBox(
            width: 300,
            child: Text.rich(
              codeStyles.highlight(const <CodeSpan>[
                CodeSpan(SpanType.comment, '// clockwise'),
                CodeSpan(SpanType.text, '\npath.'),
                CodeSpan(SpanType.method, 'addArc'),
                CodeSpan(SpanType.text, '('),
                CodeSpan(SpanType.text, '\n  rect,'),
                CodeSpan(SpanType.text, '\n  pi '),
                CodeSpan(SpanType.operator, '/ '),
                CodeSpan(SpanType.literal, '2'),
                CodeSpan(SpanType.text, ','),
                CodeSpan(SpanType.comment, '     //  90° startAngle'),
                CodeSpan(SpanType.literal, '\n  3 '),
                CodeSpan(SpanType.operator, '* '),
                CodeSpan(SpanType.text, 'pi '),
                CodeSpan(SpanType.operator, '/ '),
                CodeSpan(SpanType.literal, '4'),
                CodeSpan(SpanType.text, ','),
                CodeSpan(SpanType.comment, ' // 135° sweepAngle'),
                CodeSpan(SpanType.text, '\n);'),
              ]),
            ),
          )
        ],
      ),
    );
  }

  @override
  String get name => 'path_add_arc';
}

class PathAddArcCCWDiagram extends ArcDiagram {
  const PathAddArcCCWDiagram({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: palette.background,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 400,
            height: 400,
            child: CustomPaint(
              foregroundPainter: ArcDiagramPainter(
                startAngle: 5 * pi / 4,
                sweepAngle: -3 * pi / 4,
                startLabelAlignment: 1 / 5,
              ),
            ),
          ),
          SizedBox(
            width: 300,
            child: Text.rich(
              codeStyles.highlight(const <CodeSpan>[
                CodeSpan(SpanType.comment, '// counter-clockwise'),
                CodeSpan(SpanType.text, '\npath.'),
                CodeSpan(SpanType.method, 'addArc'),
                CodeSpan(SpanType.text, '('),
                CodeSpan(SpanType.text, '\n  rect,'),
                CodeSpan(SpanType.literal, '\n  5 '),
                CodeSpan(SpanType.operator, '* '),
                CodeSpan(SpanType.text, 'pi '),
                CodeSpan(SpanType.operator, '/ '),
                CodeSpan(SpanType.literal, '4'),
                CodeSpan(SpanType.text, ','),
                CodeSpan(SpanType.comment, '  //  225° startAngle'),
                CodeSpan(SpanType.literal, '\n  -3 '),
                CodeSpan(SpanType.operator, '* '),
                CodeSpan(SpanType.text, 'pi '),
                CodeSpan(SpanType.operator, '/ '),
                CodeSpan(SpanType.literal, '4'),
                CodeSpan(SpanType.text, ','),
                CodeSpan(SpanType.comment, ' // -135° sweepAngle'),
                CodeSpan(SpanType.text, '\n);'),
              ]),
            ),
          )
        ],
      ),
    );
  }

  @override
  String get name => 'path_add_arc_ccw';
}

class ArcDiagramStep extends DiagramStep<ArcDiagram> {
  ArcDiagramStep(super.controller);

  @override
  final String category = 'dart-ui';

  @override
  Future<List<ArcDiagram>> get diagrams async => const <ArcDiagram>[
        CanvasDrawArcDiagram(),
        PathAddArcDiagram(),
        PathAddArcCCWDiagram(),
      ];

  @override
  Future<File> generateDiagram(ArcDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

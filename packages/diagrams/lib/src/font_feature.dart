// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui' show FontFeature;

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'diagram_step.dart';

// When adding a new font here, add it to:
//    /utils/diagram_generator/pubspec.yaml
// ...and put the binary and license file in:
//    /utils/diagram_generator/fonts

const double _margin = 5.0;
const double _gap = _margin * 5;

abstract class FontFeatureDiagram<T> extends StatelessWidget implements DiagramMetadata {
  const FontFeatureDiagram();

  Iterable<T> get entries;
  Widget buildEntry(BuildContext context, T entry);
  String describe(T entry);

  TextStyle get textStyle => const TextStyle(
    color: Colors.black,
    fontSize: 32.0,
  );

  Widget buildRow(BuildContext context, T entry) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          top: _margin,
          left: _margin,
          child: buildEntry(context, entry),
        ),
        Positioned(
          left: 0.0,
          top: 0.0,
          child: buildDescription(context, entry),
        ),
      ],
    );
  }

  Widget buildDescription(BuildContext context, T entry) {
    return Text(
      describe(entry),
      style: const TextStyle(
        fontSize: 10.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: UniqueKey(),
      width: 600.0,
      height: (textStyle.fontSize! * 1.2 + _margin + _gap) * entries.length + _margin * 3.0 - _gap,
      child: Container(
        padding: const EdgeInsets.all(_margin),
        color: Colors.white,
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: 600.0,
          maxWidth: 600.0,
          minHeight: 0.0,
          maxHeight: double.infinity,
          child: Column(
            children: entries.map((T entry) => SizedBox(
              height: _margin + textStyle.fontSize! * 1.2 + _gap,
              child: buildRow(context, entry),
            )).toList(),
          ),
        ),
      ),
    );
  }
}

class FontFeatureValueDiagram extends FontFeatureDiagram<int> {
  const FontFeatureValueDiagram(
    this.feature,
    this.values,
    this.font, {
    this.sampleText = 'The infamous Tuna Torture.', // from s03e09, of course
    this.style,
    this.additionalFontFeatures,
  });

  @override
  String get name => 'font_feature_$feature';

  final String feature;
  final List<int> values;
  final String font;
  final String sampleText;
  final TextStyle? style;
  final List<FontFeature>? additionalFontFeatures;

  @override
  Iterable<int> get entries => values;

  @override
  Widget buildEntry(BuildContext context, int entry) => Text(
    sampleText,
    style: textStyle
      .copyWith(
        fontFamily: font,
        fontFeatures: <FontFeature>[
          FontFeature(feature, entry),
          ...?additionalFontFeatures,
        ],
      ).merge(style),
    textAlign: TextAlign.left,
  );

  @override
  String describe(int entry) => '$feature $entry';
}

class HistoricalFontFeatureDiagram extends FontFeatureDiagram<List<FontFeature>> {
  const HistoricalFontFeatureDiagram(
    this.font, {
    required this.sampleText,
  });

  @override
  String get name => 'font_feature_historical';

  final String font;
  final String sampleText;

  @override
  Iterable<List<FontFeature>> get entries => const <List<FontFeature>>[
    <FontFeature>[ FontFeature('hist', 0), FontFeature('hlig', 0) ],
    <FontFeature>[ FontFeature('hist', 1), FontFeature('hlig', 0) ],
    <FontFeature>[ FontFeature('hist', 0), FontFeature('hlig', 1) ],
    <FontFeature>[ FontFeature('hist', 1), FontFeature('hlig', 1) ],
  ];

  @override
  Widget buildEntry(BuildContext context, List<FontFeature> entry) => Text(
    sampleText,
    style: textStyle
      .copyWith(
        fontFamily: font,
        fontFeatures: entry,
      ),
    textAlign: TextAlign.left,
  );

  @override
  String describe(List<FontFeature> entry) => entry.map<String>((FontFeature feature) => '${feature.feature} ${feature.value}').join(', ');
}

class LocalizedFontFeatureDiagram extends FontFeatureDiagram<Locale> {
  const LocalizedFontFeatureDiagram();

  @override
  String get name => 'font_feature_locl';

  @override
  Iterable<Locale> get entries => const <Locale>[ Locale('ja'), Locale('ko'), Locale('zh', 'CN'), Locale('zh', 'TW') ]; // alphabetical order

  @override
  Widget buildEntry(BuildContext context, Locale entry) => Text(
    '次 化 刃 直 入 令',
    style: textStyle
      .copyWith(
        fontFamily: 'Noto Sans',
        fontFeatures: <FontFeature>[
          const FontFeature('locl', 1), // redundant, this is the default anyway
        ],
      ),
    textAlign: TextAlign.left,
    locale: entry,
  );

  @override
  String describe(Locale entry) => 'Locale: ${entry.toLanguageTag()}';
}

abstract class SideBySideFontFeatureDiagram<T> extends FontFeatureDiagram<T> {
  const SideBySideFontFeatureDiagram();

  String get font;

  @override
  Widget buildRow(BuildContext context, T entry) {
    return Row(
      children: <Widget>[
        buildSubEntry(context, entry, enable: false),
        buildSubEntry(context, entry, enable: true),
      ],
    );
  }

  Widget buildSubEntry(BuildContext context, T entry, { bool enable = true }) => Expanded(
    child: Stack(
      children: <Widget>[
        Positioned.fill(
          top: _margin,
          left: _margin,
          child: buildEntry(context, entry, enable: enable),
        ),
        Positioned(
          left: 0.0,
          top: 0.0,
          child: buildDescription(context, entry, enable: enable),
        ),
      ],
    ),
  );

  @override
  Widget buildDescription(BuildContext context, T entry, { bool enable = true }) {
    return Text(
      describe(entry, enable: enable),
      style: const TextStyle(
        fontSize: 10.0,
      ),
    );
  }

  @override
  Widget buildEntry(BuildContext context, T entry, { bool enable = true }) {
    return Text(
      describe(entry, enable: enable),
      style: const TextStyle(
        fontSize: 10.0,
      ),
    );
  }

  @override
  String describe(T entry, { bool enable = true });
}

class CharacterVariantsFontFeatureDiagram extends SideBySideFontFeatureDiagram<String> {
  const CharacterVariantsFontFeatureDiagram();

  @override
  String get name => 'font_feature_cvXX';

  @override
  String get font => 'Source Code Pro';

  @override
  Iterable<String> get entries => const <String>[ 'cv01', 'cv02', 'cv04', ];

  static const Map<String, String> demos = <String, String>{
    'cv01': 'aáâ β',
    'cv02': 'gǵĝ θб',
    'cv04': 'Iiíî Ll',

    'cv06': 'Ŋ',
    'cv07': 'β',
    'cv08': 'θ',
    'cv09': 'φ',
    'cv10': 'б',

    'cv12': '0',
    'cv17': '1',
    'cv16': '\$',
    'cv15': '*',
  };

  @override
  Widget buildEntry(BuildContext context, String entry, { bool enable = true }) => Text(
    demos[entry]!,
    style: textStyle
      .copyWith(
        fontFamily: font,
        fontFeatures: enable ? <FontFeature>[
          FontFeature(entry, 1),
        ] : null,
      ),
    textAlign: TextAlign.left,
  );


  @override
  String describe(String entry, { bool enable = true }) {
    return 'with $entry ${enable ? "enabled" : "disabled"}';
  }
}

class StylisticSetsFontFeatureDiagram1 extends SideBySideFontFeatureDiagram<String> {
  const StylisticSetsFontFeatureDiagram1();

  @override
  String get name => 'font_feature_ssXX_1';

  @override
  String get font => 'Source Code Pro';

  @override
  Iterable<String> get entries => const <String>[ 'ss02', 'ss03', 'ss04' ];

  static const Map<String, String> demos = <String, String>{
    'ss02': 'aáâ β',
    'ss03': 'gǵĝ θб',
    'ss04': 'Iiíî Ll',
  };

  @override
  Widget buildEntry(BuildContext context, String entry, { bool enable = true }) => Text(
    demos[entry]!,
    style: textStyle
      .copyWith(
        fontFamily: font,
        fontFeatures: enable ? <FontFeature>[
          FontFeature(entry, 1),
        ] : null,
      ),
    textAlign: TextAlign.left,
  );


  @override
  String describe(String entry, { bool enable = true }) {
    return 'with $entry ${enable ? "enabled" : "disabled"}';
  }
}

class StylisticSetsFontFeatureDiagram2 extends FontFeatureDiagram<int> {
  const StylisticSetsFontFeatureDiagram2();

  @override
  String get name => 'font_feature_ssXX_2';

  @override
  Iterable<int> get entries => const <int>[ 0x00, 0x01, 0x02, 0x03 ];

  String get font => 'Piazzolla';

  @override
  Widget buildEntry(BuildContext context, int entry) => Text(
    '-> MCMXCVII <-', // the year SG-1 started
    style: textStyle
      .copyWith(
        fontFamily: font,
        fontFeatures: <FontFeature>[
          if (0x01 & entry > 0)
            const FontFeature('ss01', 1),
          if (0x02 & entry > 0)
            const FontFeature('ss02', 2),
        ],
      ),
    textAlign: TextAlign.left,
  );

  @override
  String describe(int entry) {
    switch (entry) {
      case 0x00: return 'no stylistic sets enabled';
      case 0x01: return 'only ss01 enabled';
      case 0x02: return 'only ss02 enabled';
      case 0x03: return 'ss01 and ss02 enabled';
    }
    throw UnsupportedError('$entry not recognized');
  }
}

class FontFeatureDiagramStep extends DiagramStep<FontFeatureDiagram<Object>> {
  FontFeatureDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'dart-ui';

  @override
  Future<List<FontFeatureDiagram<Object>>> get diagrams async => <FontFeatureDiagram<Object>>[
    const FontFeatureValueDiagram('aalt', <int>[0, 1, 2], 'Raleway'),
    const FontFeatureValueDiagram('afrc', <int>[0, 1], 'Ubuntu Mono', sampleText: 'Fractions: 1/2 2/3 3/4 4/5'),
    const FontFeatureValueDiagram('calt', <int>[0, 1], 'Barriecito', sampleText: 'Ooohh, we weren\'t going to tell him that.'),
    const FontFeatureValueDiagram('case', <int>[0, 1], 'Piazzolla', sampleText: '(A) [A] {A} «A» A/B A•B'),
    const CharacterVariantsFontFeatureDiagram(), // cvXX, uses 'Source Code Pro'
    const FontFeatureValueDiagram('dnom', <int>[0, 1], 'Piazzolla', sampleText: 'Fractions: 1/2 2/3 3/4 4/5'),
    const FontFeatureValueDiagram('frac', <int>[0, 1], 'Ubuntu Mono', sampleText: 'Fractions: 1/2 2/3 3/4 4/5'),
    const HistoricalFontFeatureDiagram('Cardo', sampleText: 'VIBRANT fish assisted his business.'),
    const FontFeatureValueDiagram('lnum', <int>[0, 1], 'Sorts Mill Goudy', sampleText: 'CALL 311-555-2368 NOW!'),
    const LocalizedFontFeatureDiagram(), // locl, uses 'Noto Sans'
    const FontFeatureValueDiagram('nalt', <int>[0, 1, 2, 3, 4, 5, 7], 'Gothic A1', sampleText: 'abc 123'),
    const FontFeatureValueDiagram('numr', <int>[0, 1], 'Piazzolla', sampleText: 'Fractions: 1/2 2/3 3/4 4/5'),
    const FontFeatureValueDiagram('onum', <int>[0, 1], 'Piazzolla', sampleText: 'Call 311-555-2368 now!'),
    const FontFeatureValueDiagram('ordn', <int>[0, 1], 'Piazzolla', sampleText: '1st, 2nd, 3rd, 4th...'),
    const FontFeatureValueDiagram('pnum', <int>[0, 1], 'Kufam', sampleText: 'Call 311-555-2368 now!'),
    const FontFeatureValueDiagram('salt', <int>[0, 1], 'Source Code Pro', sampleText: 'Agile Game - \$100 initial bet'),
    const FontFeatureValueDiagram('sinf', <int>[0, 1], 'Piazzolla', sampleText: 'C8H10N4O2'),
    const StylisticSetsFontFeatureDiagram1(), // ssXX, uses 'Source Code Pro'
    const StylisticSetsFontFeatureDiagram2(), // ssXX, uses 'Piazzolla'
    const FontFeatureValueDiagram('subs', <int>[0, 1], 'Piazzolla', sampleText: 'Line from x1,y1 to x2,y2'),
    const FontFeatureValueDiagram('sups', <int>[0, 1], 'Sorts Mill Goudy', sampleText: 'The isotope 238U decays to 206Pb'),
    const FontFeatureValueDiagram('swsh', <int>[0, 1], 'BioRhyme Expanded', sampleText: 'Queer & Romantic'),
    const FontFeatureValueDiagram('tnum', <int>[0, 1], 'Piazzolla', sampleText: 'Call 311-555-2368 now!'),
    const FontFeatureValueDiagram('zero', <int>[0, 1], 'Source Code Pro', sampleText: 'One million is: 1,000,000.00'),
  ];

  @override
  Future<File> generateDiagram(FontFeatureDiagram<Object> diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

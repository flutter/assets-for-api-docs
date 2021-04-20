// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:dart_style/dart_style.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as path;

import 'configuration.dart';
import 'data_types.dart';
import 'util.dart';

/// Generates the snippet HTML, as well as saving the output snippet main to
/// the output directory.
class SnippetGenerator {
  SnippetGenerator(
      {SnippetConfiguration? configuration,
      FileSystem filesystem = const LocalFileSystem(),
      Directory? flutterRoot})
      : flutterRoot = flutterRoot ??
      FlutterInformation.instance.getFlutterRoot(),
        configuration = configuration ??
            FlutterRepoSnippetConfiguration(
                filesystem: filesystem,
                flutterRoot: flutterRoot ??
                    FlutterInformation.instance.getFlutterRoot());

  final Directory flutterRoot;

  /// The configuration used to determine where to get/save data for the
  /// snippet.
  final SnippetConfiguration configuration;

  static const JsonEncoder jsonEncoder = JsonEncoder.withIndent('    ');

  /// A Dart formatted used to format the snippet code and finished application
  /// code.
  static DartFormatter formatter = DartFormatter(pageWidth: 80, fixes: StyleFix.all);

  /// This returns the output file for a given snippet ID. Only used for
  /// [SampleType.sample] snippets.
  File getOutputFile(String id) =>
      configuration.filesystem.file(path.join(configuration.outputDirectory.path, '$id.dart'));

  /// Gets the path to the template file requested.
  File? getTemplatePath(String templateName, {Directory? templatesDir}) {
    final Directory templateDir = templatesDir ?? configuration.templatesDirectory;
    final File templateFile =
        configuration.filesystem.file(path.join(templateDir.path, '$templateName.tmpl'));
    return templateFile.existsSync() ? templateFile : null;
  }

  /// Returns an iterable over the template files available in the templates
  /// directory in the configuration.
  Iterable<File> getAvailableTemplates() sync* {
    final Directory templatesDir = configuration.templatesDirectory;
    for (final File file in templatesDir.listSync().whereType<File>()) {
      if (file.basename.endsWith('.tmpl')) {
        yield file;
      }
    }
  }

  /// Interpolates the [injections] into an HTML skeleton file.
  ///
  /// Similar to interpolateTemplate, but we are only looking for `code-`
  /// components, and we care about the order of the injections.
  ///
  /// Takes into account the [type] and doesn't substitute in the id and the app
  /// if not a [SnippetType.sample] snippet.
  String interpolateSkeleton(
    CodeSample sample,
    String skeleton,
  ) {
    final List<String> result = <String>[];
    const HtmlEscape htmlEscape = HtmlEscape();
    String? language;
    for (final TemplateInjection injection in sample.parts) {
      if (!injection.name.startsWith('code')) {
        continue;
      }
      result.addAll(injection.stringContents);
      if (injection.language.isNotEmpty) {
        language = injection.language;
      }
      result.addAll(<String>['', '// ...', '']);
    }
    if (result.length > 3) {
      result.removeRange(result.length - 3, result.length);
    }
    // Only insert a div for the description if there actually is some text there.
    // This means that the {{description}} marker in the skeleton needs to
    // be inside of an {@inject-html} block.
    String description = sample.parts
        .firstWhere((TemplateInjection tuple) => tuple.name == 'description')
        .mergedContent;
    description = description.trim().isNotEmpty
        ? '<div class="snippet-description">{@end-inject-html}$description{@inject-html}</div>'
        : '';

    // DartPad only supports stable or master as valid channels. Use master
    // if not on stable so that local runs will work (although they will
    // still take their sample code from the master docs server).
    final String channel = sample.metadata['channel'] == 'stable' ? 'stable' : 'master';

    final Map<String, String> substitutions = <String, String>{
      'description': description,
      'code': htmlEscape.convert(result.join('\n')),
      'language': language ?? 'dart',
      'serial': '',
      'id': sample.metadata['id']! as String,
      'channel': channel,
      'element': sample.metadata['element'] as String? ?? sample.element,
      'app': '',
    };
    if (sample is ApplicationSample) {
      substitutions
        ..['serial'] = sample.metadata['serial']?.toString() ?? '0'
        ..['app'] = htmlEscape.convert(sample.output);
    }
    return skeleton.replaceAllMapped(RegExp('{{(${substitutions.keys.join('|')})}}'),
        (Match match) {
      return substitutions[match[1]]!;
    });
  }

  /// Consolidates all of the snippets and the assumptions into one snippet, in
  /// order to create a compilable result.
  Iterable<SourceLine> consolidateSnippets(List<CodeSample> samples, {bool addMarkers = false}) {
    if (samples.isEmpty) {
      return <SourceLine>[];
    }
    final Iterable<SnippetSample> snippets = samples.whereType<SnippetSample>();
    final List<SourceLine> snippetLines = <SourceLine>[
      ...snippets.first.assumptions,
    ];
    for (final SnippetSample sample in snippets) {
      parseInput(sample);
      snippetLines.addAll(_processBlocks(sample));
    }
    return snippetLines;
  }

  /// A RegExp that matches a Dart constructor.
  static final RegExp _constructorRegExp = RegExp(r'(const\s+)?_*[A-Z][a-zA-Z0-9<>._]*\(');

  /// A serial number so that we can create unique expression names when we
  /// generate them.
  int _expressionId = 0;

  List<SourceLine> _surround(String prefix, Iterable<SourceLine> body, String suffix) {
    return <SourceLine>[
      if (prefix.isNotEmpty) SourceLine(prefix),
      ...body,
      if (suffix.isNotEmpty) SourceLine(suffix),
    ];
  }

  /// Process one block of sample code (the part inside of "```" markers).
  /// Splits any sections denoted by "// ..." into separate blocks to be
  /// processed separately. Uses a primitive heuristic to make sample blocks
  /// into valid Dart code.
  List<SourceLine> _processBlocks(CodeSample sample) {
    final List<SourceLine> block = sample.parts
        .where((TemplateInjection injection) => injection.name != 'description')
        .expand<SourceLine>((TemplateInjection injection) => injection.contents)
        .toList();
    if (block.isEmpty) {
      return <SourceLine>[];
    }
    return _processBlock(block);
  }

  List<SourceLine> _processBlock(List<SourceLine> block) {
    final String firstLine = block.first.text;
    if (firstLine.startsWith('new ') || firstLine.startsWith(_constructorRegExp)) {
      _expressionId += 1;
      return _surround('dynamic expression$_expressionId = ', block, ';');
    } else if (firstLine.startsWith('await ')) {
      _expressionId += 1;
      return _surround('Future<void> expression$_expressionId() async { ', block, ' }');
    } else if (block.first.text.startsWith('class ') || block.first.text.startsWith('enum ')) {
      return block;
    } else if ((block.first.text.startsWith('_') || block.first.text.startsWith('final ')) &&
        block.first.text.contains(' = ')) {
      _expressionId += 1;
      return _surround('void expression$_expressionId() { ', block.toList(), ' }');
    } else {
      final List<SourceLine> buffer = <SourceLine>[];
      int blocks = 0;
      SourceLine? subLine;
      final List<SourceLine> subsections = <SourceLine>[];
      for (int index = 0; index < block.length; index += 1) {
        // Each section of the dart code that is either split by a blank line, or with
        // '// ...' is treated as a separate code block.
        if (block[index].text.trim().isEmpty || block[index].text == '// ...') {
          if (subLine == null) {
            continue;
          }
          blocks += 1;
          subsections.addAll(_processBlock(buffer));
          buffer.clear();
          assert(buffer.isEmpty);
          subLine = null;
        } else if (block[index].text.startsWith('// ')) {
          if (buffer.length > 1) // don't include leading comments
            buffer.add(SourceLine(
                '/${block[index].text}')); // so that it doesn't start with "// " and get caught in this again
        } else {
          subLine ??= block[index];
          buffer.add(block[index]);
        }
      }
      if (blocks > 0) {
        if (subLine != null) {
          subsections.addAll(_processBlock(buffer));
        }
        // Combine all of the subsections into one section, now that they've been processed.
        return subsections;
      } else {
        return block;
      }
    }
  }

  /// Parses the input for the various code and description segments, and
  /// returns them in the order found.
  List<TemplateInjection> parseInput(CodeSample sample) {
    bool inCodeBlock = false;
    final List<SourceLine> description = <SourceLine>[];
    final List<TemplateInjection> components = <TemplateInjection>[];
    String? language;
    final RegExp codeStartEnd =
        RegExp(r'^\s*```(?<language>[-\w]+|[-\w]+ (?<section>[-\w]+))?\s*$');
    for (final SourceLine line in sample.input) {
      final RegExpMatch? match = codeStartEnd.firstMatch(line.text);
      if (match != null) {
        // If we saw the start or end of a code block
        inCodeBlock = !inCodeBlock;
        if (match.namedGroup('language') != null) {
          language = match[1]!;
          if (match.namedGroup('section') != null) {
            components.add(TemplateInjection('code-${match.namedGroup('section')}', <SourceLine>[],
                language: language));
          } else {
            components.add(TemplateInjection('code', <SourceLine>[], language: language));
          }
        } else {
          language = null;
        }
        continue;
      }
      if (!inCodeBlock) {
        description.add(line);
      } else {
        assert(language != null);
        components.last.contents.add(line);
      }
    }
    sample.parts = <TemplateInjection>[
      TemplateInjection('description', description),
      if (sample is SnippetSample) TemplateInjection('#assumptions', sample.assumptions),
      ...components,
    ];
    return sample.parts;
  }

  String _loadFileAsUtf8(File file) {
    return file.readAsStringSync(encoding: utf8);
  }

  String generateHtml(CodeSample sample) {
    final String skeleton = _loadFileAsUtf8(configuration.getHtmlSkeletonFile(sample.type));
    return interpolateSkeleton(sample, skeleton);
  }

  /// The main routine for generating snippets.
  ///
  /// The [sample] is the file containing the dartdoc comments (minus the leading
  /// comment markers).
  ///
  /// The [type] is the type of snippet to create: either a
  /// [SampleType.sample] or a [SampleType.snippet].
  ///
  /// [showDartPad] indicates whether DartPad should be shown where possible.
  /// Currently, this value only has an effect if [type] is
  /// [SampleType.sample], in which case an alternate skeleton file is
  /// used to create the final HTML output.
  ///
  /// The optional [template] parameter can be used to override specifies the
  /// name of the template to use for interpolating the application code.
  /// Defaults to the template provided by the [CodeSample].
  ///
  /// The [id] is a string ID to use for the output file, and to tell the user
  /// about in the `flutter create` hint. It must not be null if the [type] is
  /// [SampleType.sample].
  String generateCode(
    CodeSample sample, {
    File? output,
    bool addSectionMarkers = false,
    bool includeAssumptions = false,
  }) {
    configuration.createOutputDirectoryIfNeeded();

    final List<TemplateInjection> snippetData = parseInput(sample);
    switch (sample.runtimeType) {
      case DartpadSample:
      case ApplicationSample:
        final Directory templatesDir = configuration.templatesDirectory;
        final String templateName = sample.template;
        final File? templateFile = getTemplatePath(templateName, templatesDir: templatesDir);
        if (templateFile == null) {
          io.stderr.writeln('The template $templateName was not found in the templates '
              'directory ${templatesDir.path}');
          io.exit(1);
        }
        final String templateContents = _loadFileAsUtf8(templateFile);
        final String templateRelativePath =
            templateFile.absolute.path.contains(flutterRoot.absolute.path)
                ? path.relative(templateFile.absolute.path, from: flutterRoot.absolute.path)
                : templateFile.absolute.path;
        sample.output = interpolateTemplate(
          snippetData,
          addSectionMarkers
              ? '/// Template: $templateRelativePath\n$templateContents'
              : templateContents,
          sample.metadata,
          addSectionMarkers: addSectionMarkers,
        );

        final int descriptionIndex =
            snippetData.indexWhere((TemplateInjection data) => data.name == 'description');
        final String descriptionString =
            descriptionIndex == -1 ? '' : snippetData[descriptionIndex].mergedContent;
        sample.description = descriptionString;
        break;
      case SnippetSample:
        if (sample is SnippetSample) {
          // So Dart does correct type inference.
          String templateContents;
          final Map<String, Object?> metadata = Map<String, Object?>.from(sample.metadata);
          if (includeAssumptions) {
            templateContents =
                '${headers.map<String>((SourceLine line) => line.text).join('\n')}\n{{#assumptions}}\n{{description}}\n{{code}}';
          } else {
            templateContents = '{{description}}\n{{code}}';
          }
          final String app = interpolateTemplate(
            snippetData,
            templateContents,
            metadata,
            addSectionMarkers: addSectionMarkers,
          );
          sample.output = app;
          final int descriptionIndex =
              snippetData.indexWhere((TemplateInjection data) => data.name == 'description');
          final String descriptionString =
              descriptionIndex == -1 ? '' : snippetData[descriptionIndex].mergedContent;
          sample.description = descriptionString;
        }
        break;
    }
    sample.metadata['description'] = sample.description;
    if (output != null) {
      output.writeAsStringSync(sample.output);

      final File metadataFile = configuration.filesystem.file(path.join(
          path.dirname(output.path), '${path.basenameWithoutExtension(output.path)}.json'));
      sample.metadata['file'] = path.basename(output.path);
      metadataFile.writeAsStringSync(jsonEncoder.convert(sample.metadata));
    }
    return sample.output;
  }

  /// Computes the headers needed for each snippet file.
  List<SourceLine> get headers {
    return _headers ??= <String>[
      '// generated code',
      '// ignore_for_file: unused_import',
      '// ignore_for_file: unused_element',
      '// ignore_for_file: unused_local_variable',
      "import 'dart:async';",
      "import 'dart:convert';",
      "import 'dart:math' as math;",
      "import 'dart:typed_data';",
      "import 'dart:ui' as ui;",
      "import 'package:flutter_test/flutter_test.dart';",
      for (final File file in _listDartFiles(FlutterInformation.instance.getFlutterRoot()
          .childDirectory('packages')
          .childDirectory('flutter')
          .childDirectory('lib'))) ...<String>[
        '',
        '// ${file.path}',
        "import 'package:flutter/${path.basename(file.path)}';",
      ],
    ].map<SourceLine>((String code) => SourceLine(code)).toList();
  }

  List<SourceLine>? _headers;

  static List<File> _listDartFiles(Directory directory, {bool recursive = false}) {
    return directory
        .listSync(recursive: recursive, followLinks: false)
        .whereType<File>()
        .where((File file) => path.extension(file.path) == '.dart')
        .toList();
  }
}

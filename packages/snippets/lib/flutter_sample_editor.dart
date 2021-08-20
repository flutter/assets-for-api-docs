// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';
import 'dart:math' as math;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as path;
import 'package:process/process.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:recase/recase.dart';
import 'package:snippets/snippet_generator.dart';
import 'package:snippets/snippet_parser.dart';

import 'analysis.dart';
import 'data_types.dart';
import 'util.dart';

/// An editor for the samples in a Flutter source file.
///
/// This class is used to [extract] an editable sample to a project at the given [location], and then [reinsert] the
/// edited sample in the original Flutter source file.
class FlutterSampleLiberator {
  FlutterSampleLiberator(
    this.element,
    this.sample, {
    required this.location,
    String? name,
    this.filesystem = const LocalFileSystem(),
    this.processManager = const LocalProcessManager(),
    Directory? flutterRoot,
  })  : _name = name,
        flutterRoot =
            flutterRoot ?? FlutterInformation.instance.getFlutterRoot();

  /// The optional [FileSystem] object to use for filesystem access.
  ///
  /// Defaults to [LocalFileSystem].
  final FileSystem filesystem;

  /// The optional [ProcessManager] object to use for invoking subprocesses.
  ///
  /// Defaults to [LocalProcessManager].
  final ProcessManager processManager;

  /// The [SourceElement] that owns the [sample] to be extracted/reinserted.
  final SourceElement element;

  /// The [CodeSample] to extract/reinsert into the source file.
  final CodeSample sample;

  /// The location of the editable sample.
  ///
  /// This serves as a destination for the [extract] function, and a source for
  /// the [reinsert] function.
  final Directory location;
  // A name that overrides the default naming if specified in the constructor.
  final String? _name;

  /// The optional Flutter root directory specified.
  ///
  /// Defaults to the output of [FlutterInformation.instance.getFlutterRoot].
  final Directory flutterRoot;

  /// The name of the extracted sample, either supplied to the constructor, or
  /// (if not), a name valid for use in a "pubspec.yaml" file derived from the
  /// element's type, element name, and the index of the sample within the
  /// element's doc comment.
  String get name =>
      _name ??
      '${sample.type}_${sample.element.snakeCase.replaceAll('.', '_')}_${sample.index}';

  /// The output "main.dart" file for the extracted sample.
  File get mainDart => location.childDirectory('lib').childFile('main.dart');

  CodeSample _findMatchingCodeSample() {
    final Iterable<SourceElement> sourceElements =
        getFileCommentElements(element.file);
    final Iterable<SourceElement> matchingElements =
        sourceElements.where((SourceElement matchElement) {
      return matchElement.elementName == element.elementName &&
          matchElement.className == element.className &&
          matchElement.type == element.type;
    });
    if (matchingElements.length != 1) {
      throw SnippetException(
          'Unable to find original location for sample ${sample.index} on ${sample.element} in ${element.file}');
    }
    final SnippetDartdocParser parser = SnippetDartdocParser(filesystem);
    final SourceElement matchingElement = matchingElements.first;
    parser.parseComment(matchingElement);
    final List<CodeSample> foundBlocks =
        matchingElement.samples.where((CodeSample foundSample) {
      return foundSample.index == sample.index;
    }).toList();
    if (foundBlocks.length != 1) {
      throw SnippetException(
          'Unable to find original location for sample ${sample.index} on ${sample.element}');
    }
    return foundBlocks.first;
  }

  // "sample" is the matching sample in the current source file.
  Future<Map<String, int>> _findReplacementRangeAndIndents(
      [CodeSample? sample]) async {
    sample ??= _findMatchingCodeSample();
    int startRange = 0;
    int endRange = 0;
    int startFirstLine = 0;
    String firstLine = '';
    if (sample.input.isEmpty) {
      startRange = sample.start.startChar - 1;
      endRange = startRange;
      startFirstLine = startRange;
      firstLine = '';
    } else {
      startRange = sample.input.first.startChar;
      endRange = sample.input.last.endChar;
      // Back up from the start of range, and find the first newline.
      final String contents = await element.file.readAsString();
      if (contents.isEmpty) {
        throw SnippetException('Source file ${element.file} is empty');
      }
      int cursor = startRange;
      while (cursor >= 0 && contents[cursor] != '\n') {
        cursor--;
      }
      startFirstLine = contents[cursor] == '\n' ? cursor + 1 : cursor;
      // Move forward from the start of range, and find the first newline.
      cursor = startRange;
      while (cursor < contents.length && contents[cursor] != '\n') {
        cursor++;
      }
      firstLine = contents.substring(startFirstLine, cursor);
    }

    return <String, int>{
      'startRange': startFirstLine,
      'endRange': endRange,
      'firstIndent': getIndent(firstLine)
    };
  }

  String _buildSampleReplacement(Map<String, List<String>> sections,
      List<String> sectionOrder, int indent) {
    final String commentMarker = '${' ' * indent}///';
    final List<String> result = <String>[];
    for (final String section in sectionOrder) {
      if (!sections.containsKey(section) || sections[section]!.isEmpty) {
        // Skip missing/empty sections entirely.
        continue;
      }
      final String dartdocSection =
          section.replaceFirst(RegExp(r'code-?'), ' ').trimRight();
      final List<String> sectionContents = sections[section]!;
      final int sectionIndent = getIndent(sectionContents.first);
      if (section != 'description' && section != 'sampleLink') {
        result.add('$commentMarker ```dart$dartdocSection');
      }
      result.addAll(sections[section]!.map<String>((String line) {
        // Remove the base indent and any trailing spaces.
        line = line.substring(
            math.min(math.min(sectionIndent, getIndent(line)), line.length));
        return '$commentMarker $line'.trimRight();
      }));
      if (section != 'description' && section != 'sampleLink') {
        result.add('$commentMarker ```');
      }
      if (section != sectionOrder.last) {
        result.add(commentMarker); // add a blank line between sections.
      }
    }
    return result.join('\n');
  }

  Future<void> _parseMainDart(
      {required Map<String, List<String>> sections,
      required List<String> sectionOrder}) async {
    final List<String> mainDartLines = await mainDart.readAsLines();
    final RegExp sectionMarkerRe = RegExp(
        r'^([/]{2}\*) ((?<direction>\S)\3{7}) (?<name>[-a-zA-Z0-9]+).*$');
    String? currentSection;
    int firstTrailingEmpty = -1;
    sections.clear();
    sectionOrder.clear();
    for (String line in mainDartLines) {
      final RegExpMatch? match = sectionMarkerRe.firstMatch(line);
      if (match != null) {
        if (match.namedGroup('direction')! == '\u25bc' /* ▼ */) {
          // Start of section, initialize it.
          currentSection = match.namedGroup('name');
          sections[currentSection!] ??= <String>[];
          sectionOrder.add(currentSection);
        } else {
          // End of a section
          // Remove any blank lines at the end
          if (firstTrailingEmpty >= 0 &&
              firstTrailingEmpty < sections[currentSection]!.length) {
            sections[currentSection]!.removeRange(
                firstTrailingEmpty, sections[currentSection]!.length);
          }
          // Remove the section if it's empty.
          if (sections[currentSection]!.isEmpty) {
            sections.remove(currentSection);
          }
          currentSection = null;
          firstTrailingEmpty = -1;
        }
      } else {
        if (currentSection != null) {
          if (currentSection == 'description') {
            // Strip comment markers off of description lines.
            line = line.replaceFirst(RegExp(r'^\s*///? ?'), '');
          }
          // Skip empty lines at the beginning of a section.
          final bool isEmpty = line.trim().isEmpty;
          if (sections[currentSection]!.isEmpty && isEmpty) {
            continue;
          }
          sections[currentSection]!.add(line);
          if (!isEmpty) {
            // If we find a non-empty line, reset the trailing empty index.
            firstTrailingEmpty = sections[currentSection]!.length;
          }
        }
      }
    }
  }

  /// Extracts the configured sample project to the configured output location.
  ///
  /// Returns true if the extraction succeeded.
  Future<bool> extract(
      {bool overwrite = false,
      File? mainDart,
      bool includeMobile = false}) async {
    if (await location.exists() && !overwrite) {
      throw SnippetException(
          'Project output location ${location.absolute.path} exists, refusing to overwrite.');
    }

    final File flutter = flutterRoot.childDirectory('bin').childFile('flutter');
    if (!processManager.canRun(flutter.absolute.path)) {
      throw SnippetException('Unable to run flutter command');
    }

    final String description = 'A temporary code sample for ${sample.element}';
    ProcessResult result = await processManager.run(<String>[
      flutter.absolute.path,
      'create',
      if (overwrite) '--overwrite',
      '--org=dev.flutter',
      '--no-pub',
      '--description',
      description,
      '--project-name',
      name,
      '--template=app',
      '--platforms=linux,windows,macos,web${includeMobile ? ',ios,android' : ''}',
      location.absolute.path,
    ]);

    if (result.exitCode != 0) {
      return false;
    }

    // Now, get rid of stuff we don't care about and write out main.dart.
    await location.childDirectory('test').delete(recursive: true);
    await location.childDirectory('lib').delete(recursive: true);
    await location.childDirectory('lib').create();

    mainDart ??= location.childDirectory('lib').childFile('main.dart');
    await mainDart.parent.create(recursive: true);
    await mainDart.writeAsString(sample.output);

    // Rewrite the pubspec to include the right constraints and point to the flutter root.

    final File pubspec = location.childFile('pubspec.yaml');
    final Version flutterVersion =
        FlutterInformation.instance.getFlutterVersion();
    final Version dartVersion = FlutterInformation.instance.getDartSdkVersion();
    await pubspec.writeAsString('''
name: $name
description: $description
publish_to: 'none'

version: 1.0.0+1

environment: 
  sdk: ">=$dartVersion <3.0.0"
  flutter: ">=$flutterVersion <3.0.0"

dependencies:
  cupertino_icons: 1.0.2
  flutter:
    sdk: flutter
  flutter_test:
    sdk: flutter
    
flutter:
  uses-material-design: true
''');

    // Overwrite the analysis_options.yaml so that it matches the Flutter repo.

    final File analysisOptions = location.childFile('analysis_options.yaml');
    await analysisOptions.writeAsString('''
include: ${flutterRoot.absolute.path}/analysis_options.yaml
''');

    // Run 'flutter pub get' to update the dependencies.
    result = await processManager.run(
        <String>[flutter.absolute.path, 'pub', 'get'],
        workingDirectory: location.absolute.path);

    return result.exitCode == 0;
  }

  /// Reinserts the configured sample into its original Flutter source file
  /// after editing.
  Future<String> reinsert() async {
    try {
      // Load up the modified main.dart and parse out the components, keeping them
      // in order.
      final Map<String, List<String>> sections = <String, List<String>>{};
      final List<String> sectionOrder = <String>[];
      await _parseMainDart(sections: sections, sectionOrder: sectionOrder);

      // Re-parse the original file to find the current char range for the
      // original example.
      final Map<String, int> rangesAndIndents =
          await _findReplacementRangeAndIndents();
      final int startRange = rangesAndIndents['startRange']!;
      final int endRange = rangesAndIndents['endRange']!;
      final File frameworkFile = sample.start.file!;
      String frameworkContents = await frameworkFile.readAsString();

      // Create a substitute example, and replace the char range with the new example.
      final String replacement = _buildSampleReplacement(
          sections, sectionOrder, rangesAndIndents['firstIndent']!);
      // Rewrite the original framework file.
      frameworkContents = frameworkContents.replaceRange(startRange, endRange,
          startRange == endRange ? '\n$replacement' : replacement);
      await frameworkFile.writeAsString(frameworkContents);
    } on SnippetException catch (e) {
      return e.message;
    }
    return '';
  }

  /// Reinserts the configured sample into its original Flutter source file
  /// with a link to the new location instead of the source code.
  Future<void> reinsertAsReference(File mainDart) async {
    // Re-parse the original file to find the current char range for the
    // original example.
    final CodeSample matchingSample = _findMatchingCodeSample();
    final Map<String, int> rangesAndIndents =
        await _findReplacementRangeAndIndents(matchingSample);
    final int startRange = rangesAndIndents['startRange']!;
    final int endRange = rangesAndIndents['endRange']!;
    final File frameworkFile = sample.start.file!;
    String frameworkContents = await frameworkFile.readAsString();

    final SnippetGenerator generator = SnippetGenerator();
    generator.parseInput(matchingSample); // Just to get the description.

    // Create a substitute example that only contains a reference to the
    // output file, and the description.
    final String linkPath =
        path.relative(mainDart.path, from: flutterRoot.absolute.path);
    final String replacement = _buildSampleReplacement(<String, List<String>>{
      'description': matchingSample.description.split('\n'),
      'sampleLink': <String>['** See code in $linkPath **'],
    }, <String>[
      'description',
      'sampleLink'
    ], rangesAndIndents['firstIndent']!);
    // Rewrite the original framework file.
    frameworkContents = frameworkContents.replaceRange(startRange, endRange,
        startRange == endRange ? '\n$replacement' : replacement);
    await frameworkFile.writeAsString(frameworkContents);
  }
}

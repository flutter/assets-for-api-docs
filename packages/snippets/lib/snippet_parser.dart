// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';

import 'data_types.dart';
import 'util.dart';

/// Parses [CodeSample]s from the source file given to [parse], or from
class SnippetDartdocParser {
  SnippetDartdocParser();

  /// The prefix of each comment line
  static const String _dartDocPrefix = '///';

  /// The prefix of each comment line with a space appended.
  static const String _dartDocPrefixWithSpace = '$_dartDocPrefix ';

  /// A RegExp that matches the beginning of a dartdoc snippet or sample.
  static final RegExp _dartDocSampleBeginRegex =
      RegExp(r'{@tool (?<type>sample|snippet|dartpad)(?:| (?<args>[^}]*))}');

  /// A RegExp that matches the end of a dartdoc snippet or sample.
  static final RegExp _dartDocSampleEndRegex = RegExp(r'{@end-tool}');

  /// A RegExp that matches the start of a code block within dartdoc.
  static final RegExp _codeBlockStartRegex = RegExp(r'///\s+```dart.*$');

  /// A RegExp that matches the end of a code block within dartdoc.
  static final RegExp _codeBlockEndRegex = RegExp(r'///\s+```\s*$');

  /// Extracts the samples from the elements in [elements] and adds the result
  /// to the given elements.
  void parseAndAddAssumptions(
    Iterable<SourceElement> elements,
    File assumptionsFile, {
    bool silent = true,
  }) {
    final List<SourceLine> assumptions = parseAssumptions(assumptionsFile);
    for (final CodeSample sample
        in elements.expand<CodeSample>((SourceElement element) => element.samples)) {
      if (sample is SnippetSample) {
        sample.assumptions = assumptions;
      }
      sample.metadata.addAll(<String, Object?>{
        'id': '${sample.element}.${sample.index}',
        'element': sample.element,
        'sourcePath': assumptionsFile.path,
        'sourceLine': sample.start.line,
      });
    }
  }

  SourceElement parseFromDartdocToolFile(
    File input, {
    int? startLine,
    String? element,
    required File sourceFile,
    String template = '',
    String type = '',
    bool silent = true,
  }) {
    final List<SourceLine> lines = <SourceLine>[];
    int lineNumber = startLine ?? 0;
    final List<String> inputStrings = <String>[
      // The parser wants to read the arguments from the input, so we create a new
      // tool line to match the given arguments, so that we can use the same parser for
      // editing and docs generation.
      '/// {@tool $type ${template.isNotEmpty ? ' --template=$template}' : ''}}',
      // Snippet input comes in with the comment markers stripped, so we add them
      // back to make it conform to the source format, so we can use the same
      // parser for editing samples as we do for processing docs.
      ...input.readAsLinesSync().map<String>((String line) => '/// $line'.trimRight()),
      '/// {@end-tool}',
    ];
    for (final String line in inputStrings) {
      lines.add(
        SourceLine(line, element: element ?? '', line: lineNumber, file: sourceFile),
      );
      lineNumber++;
    }
    // No need to get assumptions: dartdoc won't give that to us.
    final SourceElement newElement =
        SourceElement(SourceElementType.unknownType, element!, -1, file: input, comment: lines);
    parseFromComments(<SourceElement>[newElement], silent: silent);
    for (final CodeSample sample in newElement.samples) {
      sample.metadata.addAll(<String, Object?>{
        'id': '${sample.element}.${sample.index}',
        'element': sample.element,
        'sourcePath': sourceFile.path,
        'sourceLine': sample.start.line,
      });
    }
    return newElement;
  }

  List<SourceLine> parseAssumptions(File file) {
    // Whether or not we're in the file-wide preamble section ("Examples can assume").
    bool inPreamble = false;
    final List<SourceLine> preamble = <SourceLine>[];
    int lineNumber = 0;
    int charPosition = 0;
    for (final String line in file.readAsLinesSync()) {
      if (inPreamble && line.trim().isEmpty) {
        // Reached the end of the preamble.
        break;
      }
      if (!line.startsWith('// ')) {
        lineNumber++;
        charPosition += line.length + 1;
        continue;
      }
      if (line == '// Examples can assume:') {
        inPreamble = true;
        lineNumber++;
        charPosition += line.length + 1;
        continue;
      }
      if (inPreamble) {
        preamble.add(SourceLine(
          line.substring(3),
          startChar: charPosition,
          endChar: charPosition + line.length + 1,
          element: '#assumptions',
          file: file,
          line: lineNumber,
        ));
      }
      lineNumber++;
      charPosition += line.length + 1;
    }
    return preamble;
  }

  void parseFromComments(
    Iterable<SourceElement> elements, {
    bool silent = true,
  }) {
    int dartpadCount = 0;
    int sampleCount = 0;
    int snippetCount = 0;

    for (final SourceElement element in elements) {
      if (element.comment.isEmpty) {
        continue;
      }
      parseComment(element);
      for (final CodeSample sample in element.samples) {
        sample.metadata.addAll(<String, Object?>{
          'id': '${sample.element}.${sample.index}',
          'element': sample.element,
          'sourcePath': sample.start.file?.path ?? '',
          'sourceLine': sample.start.line,
        });
        switch (sample.runtimeType) {
          case ApplicationSample:
            sampleCount++;
            break;
          case DartpadSample:
            dartpadCount++;
            break;
          case SnippetSample:
            snippetCount++;
            break;
        }
      }
    }

    if (!silent) {
      print('Found:\n'
          '  $snippetCount snippet code blocks,\n'
          '  $sampleCount non-dartpad sample code sections, and\n'
          '  $dartpadCount dartpad sections.\n');
    }
  }

  void parseComment(SourceElement element) {
    // Whether or not we're in a snippet code sample (with template) specifically.
    bool inSnippet = false;
    // Whether or not we're in a '```dart' segment.
    bool inDart = false;
    List<SourceLine> block = <SourceLine>[];
    List<String> snippetArgs = <String>[];
    final List<CodeSample> samples = <CodeSample>[];

    int index = 0;
    for (final SourceLine line in element.comment) {
      final String trimmedLine = line.text.trim();
      if (inSnippet) {
        if (!trimmedLine.startsWith(_dartDocPrefix)) {
          throw SnippetException('Snippet section unterminated.',
              file: line.file?.path, line: line.line);
        }
        if (_dartDocSampleEndRegex.hasMatch(trimmedLine)) {
          switch (snippetArgs.first) {
            case 'snippet':
              samples.add(
                SnippetSample(
                  block,
                  index: index++,
                  lineProto: line,
                ),
              );
              break;
            case 'sample':
              samples.add(
                ApplicationSample(
                  input: block,
                  args: snippetArgs,
                  index: index++,
                  lineProto: line,
                ),
              );
              break;
            case 'dartpad':
              samples.add(
                DartpadSample(
                  input: block,
                  args: snippetArgs,
                  index: index++,
                  lineProto: line,
                ),
              );
              break;
            default:
              throw SnippetException('Unknown snippet type ${snippetArgs.first}');
          }
          snippetArgs = <String>[];
          block = <SourceLine>[];
          inSnippet = false;
        } else {
          block.add(line.copyWith(text: line.text.replaceFirst(RegExp(r'\s*/// ?'), '')));
        }
      } else {
        if (_dartDocSampleEndRegex.hasMatch(trimmedLine)) {
          if (inDart) {
            throw SnippetException("Dart section didn't terminate before end of sample",
                file: line.file?.path, line: line.line);
          }
        }
        if (inDart) {
          if (_codeBlockEndRegex.hasMatch(trimmedLine)) {
            inDart = false;
            block = <SourceLine>[];
          } else if (trimmedLine == _dartDocPrefix) {
            block.add(line.copyWith(text: ''));
          } else {
            final int index = line.text.indexOf(_dartDocPrefixWithSpace);
            if (index < 0) {
              throw SnippetException(
                'Dart section inexplicably did not contain "$_dartDocPrefixWithSpace" prefix.',
                file: line.file?.path,
                line: line.line,
              );
            }
            block.add(line.copyWith(text: line.text.substring(index + 4)));
          }
        } else if (_codeBlockStartRegex.hasMatch(trimmedLine)) {
          assert(block.isEmpty);
          inDart = true;
        }
      }
      if (!inSnippet && !inDart) {
        final RegExpMatch? sampleMatch = _dartDocSampleBeginRegex.firstMatch(trimmedLine);
        if (sampleMatch != null) {
          inSnippet = sampleMatch.namedGroup('type') == 'snippet' ||
              sampleMatch.namedGroup('type') == 'sample' ||
              sampleMatch.namedGroup('type') == 'dartpad';
          if (inSnippet) {
            if (sampleMatch.namedGroup('args') != null) {
              // There are arguments to the snippet tool to keep track of.
              snippetArgs = <String>[
                sampleMatch.namedGroup('type')!,
                ..._splitUpQuotedArgs(sampleMatch.namedGroup('args')!).toList()
              ];
            } else {
              snippetArgs = <String>[
                sampleMatch.namedGroup('type')!,
              ];
            }
          }
        }
      }
    }
    element.samples.clear();
    element.samples.addAll(samples);
  }

  /// Helper to process arguments given as a (possibly quoted) string.
  ///
  /// First, this will split the given [argsAsString] into separate arguments,
  /// taking any quoting (either ' or " are accepted) into account, including
  /// handling backslash-escaped quotes.
  ///
  /// Then, it will prepend "--" to any args that start with an identifier
  /// followed by an equals sign, allowing the argument parser to treat any
  /// "foo=bar" argument as "--foo=bar" (which is a dartdoc-ism).
  Iterable<String> _splitUpQuotedArgs(String argsAsString) {
    // This function is used because the arg parser package doesn't handle
    // quoted args.

    // Regexp to take care of splitting arguments, and handling the quotes
    // around arguments, if any.
    //
    // Match group 1 (option) is the "foo=" (or "--foo=") part of the option, if any.
    // Match group 2 (quote) contains the quote character used (which is discarded).
    // Match group 3 (value) is a quoted arg, if any, without the quotes.
    // Match group 4 (unquoted) is the unquoted arg, if any.
    final RegExp argMatcher = RegExp(r'(?<option>[-_a-zA-Z0-9]+=)?' // option name
        r'(?:' // Start a new non-capture group for the two possibilities.
        r'''(?<quote>["'])(?<value>(?:\\{2})*|(?:.*?[^\\](?:\\{2})*))\2|''' // value with quotes.
        r'(?<unquoted>[^ ]+))'); // without quotes.
    final Iterable<RegExpMatch> matches = argMatcher.allMatches(argsAsString);

    // Remove quotes around args, then for any args that look like assignments
    // (start with valid option names followed by an equals sign), add a "--" in
    // front so that they parse as options to support legacy dartdoc
    // functionality of "option=value".
    return matches.map<String>((RegExpMatch match) {
      String option = '';
      if (match.namedGroup('option') != null && !match.namedGroup('option')!.startsWith('-')) {
        option = '--';
      }
      if (match.namedGroup('quote') != null) {
        // This arg has quotes, so strip them.
        return '$option'
            '${match.namedGroup('value') ?? ''}'
            '${match.namedGroup('unquoted') ?? ''}';
      }
      return '$option${match[0]}';
    });
  }
}

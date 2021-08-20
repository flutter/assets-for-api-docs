// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show exit;

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:snippets/snippets.dart';

const LocalFileSystem filesystem = LocalFileSystem();

void main(List<String> argList) {
  final ArgParser parser = ArgParser();
  parser.addOption('templates', help: 'Where to find the templates');
  parser.addOption(
    'file',
    help: 'Which source file to edit samples in',
  );
  final ArgResults args = parser.parse(argList);
  if (!args.wasParsed('file')) {
    print(
        'File containing samples to edit must be specified with the --file option.');
    print(parser.usage);
    exit(-1);
  }

  final SnippetDartdocParser snippetParser = SnippetDartdocParser(filesystem);

  final File file = filesystem.file(args['file']! as String);
  final List<SourceElement> elements = getFileElements(file).toList();
  snippetParser.parseFromComments(elements);
  snippetParser.parseAndAddAssumptions(elements, file);
  final List<CodeSample> samples = elements
      .expand<CodeSample>((SourceElement element) => element.samples)
      .toList();

  final SnippetGenerator generator = SnippetGenerator();
  for (final CodeSample sample in samples) {
    print('${sample.element}.${sample.index}: $sample');
    print('Generated:\n${generator.generateCode(sample)}');
  }

  final Iterable<SourceLine> consolidated =
      generator.consolidateSnippets(samples);
  print(
      'Consolidated:\n${consolidated.map<String>((SourceLine line) => line.text).join('\n')}');
}

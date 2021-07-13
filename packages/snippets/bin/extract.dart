// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show stderr, exit;

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:snippets/snippets.dart';

const LocalFileSystem filesystem = LocalFileSystem();

const String _kHelpOption = 'help';
const String _kInputOption = 'input';
const String _kOutputOption = 'output';

/// Extracts the samples in a source file to the given output directory, and
/// removes them from the original source files, replacing them with a pointer
/// to the new location.
Future<void> main(List<String> argList) async {
  final FlutterInformation flutterInformation = FlutterInformation();
  final ArgParser parser = ArgParser();
  parser.addOption(
    _kOutputOption,
    defaultsTo: path.join(flutterInformation.getFlutterRoot().absolute.path, 'examples', 'api'),
    help: 'The output path for the generated sample application.',
  );
  parser.addOption(
    _kInputOption,
    mandatory: true,
    help: 'The input Flutter source file containing the sample code to extract.',
  );
  parser.addFlag(
    _kHelpOption,
    defaultsTo: false,
    negatable: false,
    help: 'Prints help documentation for this command',
  );

  final ArgResults args = parser.parse(argList);

  if (args[_kHelpOption] as bool) {
    stderr.writeln(parser.usage);
    exit(0);
  }

  if (args[_kInputOption] == null) {
    stderr.writeln(parser.usage);
    errorExit('The --$_kInputOption option must be specified.');
  }

  if (args[_kOutputOption] == null || (args[_kOutputOption] as String).isEmpty) {
    stderr.writeln(parser.usage);
    errorExit('The --$_kOutputOption option must be specified.');
  }

  final File input = filesystem.file(args['input'] as String);
  if (!input.existsSync()) {
    errorExit('The input file ${input.path} does not exist.');
  }
  final String flutterSource = path.join(
    flutterInformation.getFlutterRoot().absolute.path,
    'packages',
    'flutter',
    'lib',
    'src',
  );
  if (!path.isWithin(flutterSource, input.absolute.path)) {
    errorExit('Input file must be under the $flutterSource directory: $input is not.');
  }

  final Iterable<SourceElement> fileElements = getFileElements(input);
  final SnippetDartdocParser dartdocParser = SnippetDartdocParser();
  final SnippetGenerator snippetGenerator = SnippetGenerator();
  dartdocParser.parseFromComments(fileElements);
  dartdocParser.parseAndAddAssumptions(fileElements, input, silent: true);
  const String copyright = '''
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.''';
  for (final CodeSample sample
      in fileElements.expand<CodeSample>((SourceElement element) => element.samples)) {
    final String relativePath = path.relative(sample.start.file!.path,
        from: flutterInformation.getFlutterRoot().absolute.path);
    snippetGenerator.generateCode(
      sample,
      includeAssumptions: false,
      description:
          'See description in the comments in the file:\n  $relativePath',
      copyright: copyright,
    );
  }

  final String srcPath = path.relative(input.absolute.path, from: flutterSource);
  final String dstPath = path.join(
    flutterInformation.getFlutterRoot().absolute.path,
    'examples',
    'api',
  );
  for (final SourceElement element in fileElements.where((SourceElement element) {
    return element.sampleCount > 0;
  })) {
    for (final CodeSample sample in element.samples) {
      // Ignore anything else, because those are not full apps.
      if (sample.type != 'dartpad' && sample.type != 'sample') {
        continue;
      }
      final File outputFile = filesystem.file(
        path.joinAll(<String>[
          dstPath,
          'lib',
          path.withoutExtension(srcPath), // e.g. material/app_bar
          <String>[
            if (element.className.isNotEmpty) element.className.snakeCase,
            element.name.snakeCase,
            sample.index.toString(),
            'dart',
          ].join('.'),
        ]),
      );
      await outputFile.absolute.parent.create(recursive: true);
      if (outputFile.existsSync()) {
        print('File $outputFile already exists!');
        exit(-1);
      }
      final FlutterSampleLiberator liberator = FlutterSampleLiberator(
        element,
        sample,
        location: filesystem.directory(dstPath),
      );
      if (!filesystem.file(path.join(dstPath, 'pubspec.yaml')).existsSync()) {
        print('Publishing ${outputFile.absolute.path}');
        await liberator.extract(overwrite: true, mainDart: outputFile, includeMobile: true);
      } else {
        await outputFile.absolute.writeAsString(sample.output);
      }
      await liberator.reinsertAsReference(outputFile);
      print('${outputFile.path}: ${getSampleStats(element)}');
    }
  }
  exit(0);
}

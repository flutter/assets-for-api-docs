// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show stderr, exit, exitCode;

import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:snippets/snippets.dart';

const LocalFileSystem filesystem = LocalFileSystem();

const String _kCopyrightNotice = '''
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.''';

const String _kHelpOption = 'help';
const String _kInputOption = 'input';
const String _kOutputOption = 'output';
const String _kVerboseOption = 'verbose';

/// Extracts the samples from a source file to the given output directory, and
/// removes them from the original source files, replacing them with a pointer
/// to the new location.
Future<void> main(List<String> argList) async {
  final FlutterInformation flutterInformation = FlutterInformation();
  final ArgParser parser = ArgParser();
  parser.addOption(
    _kOutputOption,
    defaultsTo: path.join(
        flutterInformation.getFlutterRoot().absolute.path, 'examples', 'api'),
    help: 'The output path for generated sample applications.',
  );
  parser.addOption(
    _kInputOption,
    defaultsTo: null,
    help:
        'The input Flutter source file containing the sample code to extract.',
  );
  parser.addFlag(
    _kHelpOption,
    defaultsTo: false,
    negatable: false,
    help: 'Prints help documentation for this command.',
  );
  parser.addFlag(
    _kVerboseOption,
    defaultsTo: false,
    negatable: false,
    help: 'Prints extra output diagnostics.',
  );

  final ArgResults args = parser.parse(argList);
  final bool verbose = (args[_kVerboseOption] as bool?) ?? false;

  if ((args[_kHelpOption] as bool?) ?? false) {
    stderr.writeln(parser.usage);
    exitCode = 1;
    return;
  }

  if (args[_kInputOption] == null || (args[_kInputOption] as String).isEmpty) {
    stderr.writeln(parser.usage);
    errorExit('The --$_kInputOption option must not be empty.');
  }

  final String outputPath = (args[_kOutputOption] as String?) ?? '';
  if (outputPath.isEmpty) {
    stderr.writeln(parser.usage);
    errorExit('The --$_kOutputOption option must be specified, and not empty.');
  }

  final File input = filesystem.file(args['input'] as String);
  if (!input.existsSync()) {
    errorExit('The input file ${input.absolute.path} does not exist.');
  }
  final String flutterSource = path.join(
    flutterInformation.getFlutterRoot().absolute.path,
    'packages',
    'flutter',
    'lib',
    'src',
  );
  if (!path.isWithin(flutterSource, input.absolute.path)) {
    errorExit(
        'Input file must be under the $flutterSource directory: ${input.absolute.path} is not.');
  }

  try {
    final Iterable<SourceElement> fileElements = getFileElements(input);
    final SnippetDartdocParser dartdocParser = SnippetDartdocParser(filesystem);
    final SnippetGenerator snippetGenerator = SnippetGenerator();
    dartdocParser.parseFromComments(fileElements);
    dartdocParser.parseAndAddAssumptions(fileElements, input, silent: true);

    if (verbose) {
      print('Parsed ${fileElements.length} elements from ${input.path}');
    }
    final String srcPath =
        path.relative(input.absolute.path, from: flutterSource);
    for (final SourceElement element
        in fileElements.where((SourceElement element) {
      return element.sampleCount > 0;
    })) {
      if (verbose) {
        print(
            'Extracting ${element.sampleCount} samples from ${element.elementName}');
      }
      for (final CodeSample sample in element.samples) {
        // Ignore anything else, because those are not full apps.
        if (sample.type != 'dartpad' && sample.type != 'sample' ||
            sample.sourceFile != null) {
          continue;
        }
        snippetGenerator.generateCode(
          sample,
          includeAssumptions: false,
          addSectionMarkers: true,
          copyright: _kCopyrightNotice,
        );
        final File outputFile = filesystem.file(
          path.joinAll(<String>[
            outputPath,
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
          errorExit('File $outputFile already exists!');
        }
        final FlutterSampleLiberator liberator = FlutterSampleLiberator(
          element,
          sample,
          location: filesystem.directory(outputPath),
        );
        if (!filesystem
            .file(path.join(outputPath, 'pubspec.yaml'))
            .existsSync()) {
          if (verbose) {
            print('Publishing ${outputFile.absolute.path}');
          }
          await liberator.extract(
              overwrite: true, mainDart: outputFile, includeMobile: true);
        } else {
          if (verbose) {
            print('Writing ${outputFile.absolute.path}');
          }
          await outputFile.absolute.writeAsString(sample.output);
        }
        await liberator.reinsertAsReference(outputFile);
        print('${outputFile.path}: ${getSampleStats(element)}');
      }
    }
  } on SnippetException catch (e, s) {
    print('Failed: $e\n$s');
    exit(1);
  } on FileSystemException catch (e, s) {
    print('Failed with file system exception: $e\n$s');
    exit(2);
  } catch (e, s) {
    print('Failed with exception: $e\n$s');
    exit(2);
  }
  exit(0);
}

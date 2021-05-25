// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:snippets/snippets.dart';
import 'package:test/test.dart' hide TypeMatcher, isInstanceOf;

import 'filesystem_resource_provider.dart';

class FakeFlutterInformation extends FlutterInformation {
  FakeFlutterInformation(this.flutterRoot);

  final Directory flutterRoot;

  @override
  Map<String, dynamic> getFlutterInformation() {
    return <String, dynamic>{
      'flutterRoot': flutterRoot,
      'frameworkVersion': Version(2, 10, 0),
      'dartSdkVersion': Version(2, 12, 1),
    };
  }
}

void main() {
  group('Parser', () {
    late MemoryFileSystem memoryFileSystem = MemoryFileSystem();
    late FlutterRepoSnippetConfiguration configuration;
    late SnippetGenerator generator;
    late Directory tmpDir;
    late File template;

    void _writeSkeleton(String type) {
      switch (type) {
        case 'dartpad':
          configuration.getHtmlSkeletonFile('dartpad').writeAsStringSync('''
<div>HTML Bits (DartPad-style)</div>
<iframe class="snippet-dartpad" src="https://dartpad.dev/embed-flutter.html?split=60&run=true&sample_id={{id}}&sample_channel={{channel}}"></iframe>
<div>More HTML Bits</div>
''');
          break;
        case 'sample':
        case 'snippet':
          configuration.getHtmlSkeletonFile(type).writeAsStringSync('''
<div>HTML Bits</div>
{{description}}
<pre>{{code}}</pre>
<pre>{{app}}</pre>
<div>More HTML Bits</div>
''');
          break;
      }
    }

    setUp(() {
      // Create a new filesystem.
      memoryFileSystem = MemoryFileSystem();
      tmpDir = memoryFileSystem.systemTempDirectory.createTempSync('flutter_snippets_test.');
      final Directory flutterRoot =
          memoryFileSystem.directory(path.join(tmpDir.absolute.path, 'flutter'));
      configuration =
          FlutterRepoSnippetConfiguration(flutterRoot: flutterRoot, filesystem: memoryFileSystem);
      configuration.createOutputDirectoryIfNeeded();
      configuration.templatesDirectory.createSync(recursive: true);
      configuration.skeletonsDirectory.createSync(recursive: true);
      template =
          memoryFileSystem.file(path.join(configuration.templatesDirectory.path, 'template.tmpl'));
      template.writeAsStringSync('''
// Flutter code sample for {{element}}

{{description}}

{{code-my-preamble}}

{{code}}
''');
      <String>['dartpad', 'sample', 'snippet'].forEach(_writeSkeleton);
      FlutterInformation.instance = FakeFlutterInformation(flutterRoot);
      generator = SnippetGenerator(
          configuration: configuration,
          filesystem: memoryFileSystem,
          flutterRoot: configuration.templatesDirectory.parent);
    });

    test('parses from comments', () async {
      final File inputFile = _createSourceFile(tmpDir, memoryFileSystem);
      final Iterable<SourceElement> elements = getFileElements(inputFile,
          resourceProvider: FileSystemResourceProvider(memoryFileSystem));
      expect(elements, isNotEmpty);
      final SnippetDartdocParser sampleParser = SnippetDartdocParser();
      sampleParser.parseFromComments(elements);
      sampleParser.parseAndAddAssumptions(elements, inputFile);
      expect(elements.length, equals(7));
      int sampleCount = 0;
      for (final SourceElement element in elements) {
        expect(element.samples.length, greaterThanOrEqualTo(1));
        sampleCount += element.samples.length;
        final String code = generator.generateCode(element.samples.first);
        expect(code, contains('// Description'));
        expect(
            code, contains(RegExp('^void ${element.name}Sample\\(\\) \\{.*\$', multiLine: true)));
        final String html = generator.generateHtml(element.samples.first);
        expect(html, contains(RegExp(r'^<pre>void .*Sample\(\) \{.*$', multiLine: true)));
        expect(
            html,
            contains(
                '<div class="snippet-description">{@end-inject-html}Description{@inject-html}</div>\n'));
      }
      expect(sampleCount, equals(8));
    });
    test('parses assumptions', () async {
      final File inputFile = _createSourceFile(tmpDir, memoryFileSystem);
      final SnippetDartdocParser sampleParser = SnippetDartdocParser();
      final List<SourceLine> assumptions = sampleParser.parseAssumptions(inputFile);
      expect(assumptions.length, equals(1));
      expect(assumptions.first.text, equals('int integer = 3;'));
    });
  });
}

File _createSourceFile(Directory tmpDir, FileSystem filesystem) {
  return filesystem.file(path.join(tmpDir.absolute.path, 'snippet_in.dart'))
    ..createSync(recursive: true)
    ..writeAsStringSync(r'''
// Copyright

// @dart = 2.12

import 'foo.dart';

// Examples can assume:
// int integer = 3;

/// Top level variable comment
///
/// {@tool snippet}
/// Description
/// ```dart
/// void topLevelVariableSample() {
/// }
/// ```
/// {@end-tool}
int topLevelVariable = 4;

/// Top level function comment
///
/// {@tool snippet}
/// Description
/// ```dart
/// void topLevelFunctionSample() {
/// }
/// ```
/// {@end-tool}
int topLevelFunction() {
  return integer;
}

/// Class comment
///
/// {@tool snippet}
/// Description
/// ```dart
/// void DocumentedClassSample() {
/// }
/// ```
/// {@end-tool}
///
/// {@tool snippet}
/// Description2
/// ```dart
/// void DocumentedClassSample2() {
/// }
/// ```
/// {@end-tool}
class DocumentedClass {
  /// Constructor comment
  /// {@tool snippet}
  /// Description
  /// ```dart
  /// void DocumentedClass.DocumentedClassSample() {
  /// }
  /// ```
  /// {@end-tool}
  const DocumentedClass();

  /// Named constructor comment
  /// {@tool snippet}
  /// Description
  /// ```dart
  /// void DocumentedClass.DocumentedClass.nameSample() {
  /// }
  /// ```
  /// {@end-tool}
  const DocumentedClass.name();
  
  /// Member variable comment
  /// {@tool snippet}
  /// Description
  /// ```dart
  /// void intMemberSample() {
  /// }
  /// ```
  /// {@end-tool}
  int intMember;  

  /// Member comment
  /// {@tool snippet}
  /// Description
  /// ```dart
  /// void memberSample() {
  /// }
  /// ```
  /// {@end-tool}
  void member() {}  
}
''');
}

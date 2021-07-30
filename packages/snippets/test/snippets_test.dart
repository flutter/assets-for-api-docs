// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:path/path.dart' as path;
import 'package:snippets/snippets.dart';
import 'package:test/test.dart' hide TypeMatcher, isInstanceOf;

void main() {
  group('Generator', () {
    late MemoryFileSystem memoryFileSystem = MemoryFileSystem();
    late SnippetConfiguration configuration;
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
      configuration = FlutterRepoSnippetConfiguration(
          flutterRoot: memoryFileSystem.directory(path.join(tmpDir.absolute.path, 'flutter')),
          filesystem: memoryFileSystem);
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
      generator = SnippetGenerator(
          configuration: configuration,
          filesystem: memoryFileSystem,
          flutterRoot: configuration.templatesDirectory.parent);
    });

    test('generates samples', () async {
      final File inputFile =
          memoryFileSystem.file(path.join(tmpDir.absolute.path, 'snippet_in.txt'))
            ..createSync(recursive: true)
            ..writeAsStringSync(r'''
A description of the snippet.

On several lines.

```my-dart_language my-preamble
const String name = 'snippet';
```

```dart
void main() {
  print('The actual $name.');
}
```
''');
      final File outputFile =
          memoryFileSystem.file(path.join(tmpDir.absolute.path, 'snippet_out.txt'));
      final SnippetDartdocParser sampleParser = SnippetDartdocParser();
      const String sourcePath = 'packages/flutter/lib/src/widgets/foo.dart';
      const int sourceLine = 222;
      final SourceElement element = sampleParser.parseFromDartdocToolFile(
        inputFile,
        element: 'MyElement',
        template: 'template',
        startLine: sourceLine,
        sourceFile: memoryFileSystem.file(sourcePath),
        type: 'sample',
      );

      expect(element.samples, isNotEmpty);
      element.samples.first.metadata.addAll(<String, Object?>{
        'channel': 'stable',
      });
      final String code = generator.generateCode(
        element.samples.first,
        output: outputFile,
      );
      expect(code, contains('// Flutter code sample for MyElement'));
      final String html = generator.generateHtml(
        element.samples.first,
      );
      expect(html, contains('<div>HTML Bits</div>'));
      expect(html, contains('<div>More HTML Bits</div>'));
      expect(html, contains(r'print(&#39;The actual $name.&#39;);'));
      expect(html, contains('A description of the snippet.\n'));
      expect(html, isNot(contains('sample_channel=stable')));
      expect(
          html,
          contains('A description of the snippet.\n'
              '\n'
              'On several lines.{@inject-html}</div>'));
      expect(html, contains('void main() {'));

      final String outputContents = outputFile.readAsStringSync();
      expect(outputContents, contains('// Flutter code sample for MyElement'));
      expect(outputContents, contains('A description of the snippet.'));
      expect(outputContents, contains('void main() {'));
      expect(outputContents, contains("const String name = 'snippet';"));
    });

    test('generates snippets', () async {
      final File inputFile =
          memoryFileSystem.file(path.join(tmpDir.absolute.path, 'snippet_in.txt'))
            ..createSync(recursive: true)
            ..writeAsStringSync(r'''
A description of the snippet.

On several lines.

```code
void main() {
  print('The actual $name.');
}
```
''');

      final SnippetDartdocParser sampleParser = SnippetDartdocParser();
      const String sourcePath = 'packages/flutter/lib/src/widgets/foo.dart';
      const int sourceLine = 222;
      final SourceElement element = sampleParser.parseFromDartdocToolFile(
        inputFile,
        element: 'MyElement',
        startLine: sourceLine,
        sourceFile: memoryFileSystem.file(sourcePath),
        type: 'snippet',
      );
      expect(element.samples, isNotEmpty);
      element.samples.first.metadata.addAll(<String, Object>{
        'channel': 'stable',
      });
      final String code = generator.generateCode(element.samples.first);
      expect(code, contains('// A description of the snippet.'));
      final String html = generator.generateHtml(element.samples.first);
      expect(html, contains('<div>HTML Bits</div>'));
      expect(html, contains('<div>More HTML Bits</div>'));
      expect(html, contains(r'  print(&#39;The actual $name.&#39;);'));
      expect(
          html,
          contains(
              '<div class="snippet-description">{@end-inject-html}A description of the snippet.\n\n'
              'On several lines.{@inject-html}</div>\n'));
      expect(html, contains('main() {'));
    });

    test('generates dartpad samples', () async {
      final File inputFile =
          memoryFileSystem.file(path.join(tmpDir.absolute.path, 'snippet_in.txt'))
            ..createSync(recursive: true)
            ..writeAsStringSync(r'''
A description of the snippet.

On several lines.

```code
void main() {
  print('The actual $name.');
}
```
''');

      final SnippetDartdocParser sampleParser = SnippetDartdocParser();
      const String sourcePath = 'packages/flutter/lib/src/widgets/foo.dart';
      const int sourceLine = 222;
      final SourceElement element = sampleParser.parseFromDartdocToolFile(
        inputFile,
        element: 'MyElement',
        template: 'template',
        startLine: sourceLine,
        sourceFile: memoryFileSystem.file(sourcePath),
        type: 'dartpad',
      );
      expect(element.samples, isNotEmpty);
      element.samples.first.metadata.addAll(<String, Object>{
        'channel': 'stable',
      });
      final String code = generator.generateCode(element.samples.first);
      expect(code, contains('// Flutter code sample for MyElement'));
      final String html = generator.generateHtml(element.samples.first);
      expect(html, contains('<div>HTML Bits (DartPad-style)</div>'));
      expect(html, contains('<div>More HTML Bits</div>'));
      expect(
          html,
          contains(
              '<iframe class="snippet-dartpad" src="https://dartpad.dev/embed-flutter.html?split=60&run=true&sample_id=MyElement.0&sample_channel=stable"></iframe>\n'));
    });

    test('generates sample metadata', () async {
      final File inputFile =
          memoryFileSystem.file(path.join(tmpDir.absolute.path, 'snippet_in.txt'))
            ..createSync(recursive: true)
            ..writeAsStringSync(r'''
A description of the snippet.

On several lines.

```dart
void main() {
  print('The actual $name.');
}
```
''');

      final File outputFile =
          memoryFileSystem.file(path.join(tmpDir.absolute.path, 'snippet_out.dart'));
      final File expectedMetadataFile =
          memoryFileSystem.file(path.join(tmpDir.absolute.path, 'snippet_out.json'));

      final SnippetDartdocParser sampleParser = SnippetDartdocParser();
      const String sourcePath = 'packages/flutter/lib/src/widgets/foo.dart';
      const int sourceLine = 222;
      final SourceElement element = sampleParser.parseFromDartdocToolFile(
        inputFile,
        element: 'MyElement',
        template: 'template',
        startLine: sourceLine,
        sourceFile: memoryFileSystem.file(sourcePath),
        type: 'sample',
      );
      expect(element.samples, isNotEmpty);
      element.samples.first.metadata.addAll(<String, Object>{'channel': 'stable'});
      generator.generateCode(element.samples.first, output: outputFile);
      expect(expectedMetadataFile.existsSync(), isTrue);
      final Map<String, dynamic> json =
          jsonDecode(expectedMetadataFile.readAsStringSync()) as Map<String, dynamic>;
      expect(json['id'], equals('MyElement.0'));
      expect(json['channel'], equals('stable'));
      expect(json['file'], equals('snippet_out.dart'));
      expect(json['description'], equals('A description of the snippet.\n\nOn several lines.'));
      expect(json['sourcePath'], equals('packages/flutter/lib/src/widgets/foo.dart'));
    });
  });
}

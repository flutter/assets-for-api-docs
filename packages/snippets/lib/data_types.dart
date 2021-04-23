// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:args/args.dart';

/// A class to represent a line of input code, with associated line number, file
/// and element name.
class SourceLine {
  const SourceLine(
    this.text, {
    this.file,
    this.element,
    this.line = -1,
    this.startChar = -1,
    this.endChar = -1,
    this.indent = 0,
  });
  final File? file;
  final String? element;
  final int line;
  final int startChar;
  final int endChar;
  final int indent;
  final String text;

  String toStringWithColumn(int column) => '$file:$line:${column + indent}: $text';

  SourceLine copyWith({
    String? element,
    String? text,
    File? file,
    int? line,
    int? startChar,
    int? endChar,
    int? indent,
  }) {
    return SourceLine(
      text ?? this.text,
      element: element ?? this.element,
      file: file ?? this.file,
      line: line ?? this.line,
      startChar: startChar ?? this.startChar,
      endChar: endChar ?? this.endChar,
      indent: indent ?? this.indent,
    );
  }

  bool get hasFile => file != null;

  @override
  String toString() => '$file:${line == -1 ? '??' : line}: $text';
}

/// A class containing the name and contents associated with a code block inside of a
/// code sample, for named injection into a template.
class TemplateInjection {
  TemplateInjection(this.name, this.contents, {this.language = ''});
  final String name;
  final List<SourceLine> contents;
  final String language;
  Iterable<String> get stringContents =>
      contents.map<String>((SourceLine line) => line.text.trimRight());
  String get mergedContent => stringContents.join('\n');
}

/// A base class to represent a block of any kind of sample code, marked by
/// "{@tool (snippet|sample|dartdoc) ...}...{@end-tool}".
abstract class CodeSample {
  CodeSample(
    this.args,
    this.input, {
    required this.index,
    required SourceLine lineProto,
  })  : assert(args.isNotEmpty),
        _lineProto = lineProto;

  final List<String> args;
  final List<SourceLine> input;
  final SourceLine _lineProto;

  Iterable<String> get inputStrings => input.map<String>((SourceLine line) => line.text);
  String get inputAsString => inputStrings.join('\n');

  /// The index of this sample within the dardoc comment it came from.
  final int index;
  String description = '';
  String get element => start.element ?? '';
  String output = '';
  Map<String, Object?> metadata = <String, Object?>{};
  List<TemplateInjection> parts = <TemplateInjection>[];
  SourceLine get start => input.isEmpty ? _lineProto : input.first;

  String get template {
    final ArgParser parser = ArgParser();
    parser.addOption('template', defaultsTo: '');
    final ArgResults parsedArgs = parser.parse(args);
    return parsedArgs['template']! as String;
  }

  @override
  String toString() {
    final StringBuffer buf = StringBuffer('${args.join(' ')}:\n');
    for (final SourceLine line in input) {
      buf.writeln(
        '${(line.line == -1 ? '??' : line.line).toString().padLeft(4, ' ')}: ${line.text} ',
      );
    }
    return buf.toString();
  }

  String get type;
}

/// A class to represent a snippet of sample code, marked by "{@tool
/// snippet}...{@end-tool}".
///
/// Snippets are code that is not meant to be run as a complete application, but
/// rather as a code usage example.
class SnippetSample extends CodeSample {
  SnippetSample(
    List<SourceLine> input, {
    required int index,
    required SourceLine lineProto,
  })  : assumptions = <SourceLine>[],
        super(
          <String>['snippet'],
          input,
          index: index,
          lineProto: lineProto,
        );

  factory SnippetSample.combine(
    List<SnippetSample> sections, {
    required int index,
    required SourceLine lineProto,
  }) {
    final List<SourceLine> code =
        sections.expand((SnippetSample section) => section.input).toList();
    return SnippetSample(code, index: index, lineProto: lineProto);
  }

  factory SnippetSample.fromStrings(SourceLine firstLine, List<String> code, {required int index}) {
    final List<SourceLine> codeLines = <SourceLine>[];
    int startPos = firstLine.startChar;
    for (int i = 0; i < code.length; ++i) {
      codeLines.add(
        firstLine.copyWith(
          text: code[i],
          line: firstLine.line + i,
          startChar: startPos,
        ),
      );
      startPos += code[i].length + 1;
    }
    return SnippetSample(
      codeLines,
      index: index,
      lineProto: firstLine,
    );
  }

  factory SnippetSample.surround(
    String prefix,
    List<SourceLine> code,
    String postfix, {
    required int index,
  }) {
    return SnippetSample(
      <SourceLine>[
        if (prefix.isNotEmpty) SourceLine(prefix),
        ...code,
        if (postfix.isNotEmpty) SourceLine(postfix),
      ],
      index: index,
      lineProto: code.first,
    );
  }

  List<SourceLine> assumptions;

  @override
  String get template => '';

  @override
  SourceLine get start => input.firstWhere((SourceLine line) => line.file != null);

  @override
  String get type => 'snippet';
}

/// A class to represent a plain application sample in the dartdoc comments,
/// marked by `{@tool sample ...}...{@end-tool}`.
///
/// Application samples are processed separately from [SnippetSample]s, because
/// they must be injected into templates in order to be analyzed. Each
/// [ApplicationSample] represents one `{@tool sample ...}...{@end-tool}` block
/// in the source file.
class ApplicationSample extends CodeSample {
  ApplicationSample({
    List<SourceLine> input = const <SourceLine>[],
    required List<String> args,
    required int index,
    required SourceLine lineProto,
  })  : assert(args.isNotEmpty),
        super(args, input, index: index, lineProto: lineProto);

  @override
  String get type => 'sample';
}

/// A class to represent a Dartpad application sample in the dartdoc comments,
/// marked by `{@tool dartpad ...}...{@end-tool}`.
///
/// Dartpad samples are processed separately from [SnippetSample]s, because they
/// must be injected into templates in order to be analyzed. Each
/// [DartpadSample] represents one `{@tool dartpad ...}...{@end-tool}` block in
/// the source file.
class DartpadSample extends ApplicationSample {
  DartpadSample({
    List<SourceLine> input = const <SourceLine>[],
    required List<String> args,
    required int index,
    required SourceLine lineProto,
  })  : assert(args.isNotEmpty),
        super(input: input, args: args, index: index, lineProto: lineProto);

  @override
  String get type => 'dartpad';
}

/// The different types of Dart [SourceElement]s that can be found in a source file.
enum SourceElementType {
  /// A class
  classType,
  /// A field variable of a class.
  fieldType,
  /// A method of a class.
  methodType,
  /// A constructor for a class.
  constructorType,
  /// A function typedef
  typedefType,
  /// A top level (non-class) variable.
  topLevelVariableType,
  /// A function, either top level, or embedded in another function.
  functionType,
  /// An unknown type used for initialization.
  unknownType,
}

/// Converts the enun type [SourceElementType] to a human readable string.
String sourceElementTypeAsString(SourceElementType type) {
  switch (type) {
    case SourceElementType.classType:
      return 'class';
    case SourceElementType.fieldType:
      return 'field';
    case SourceElementType.methodType:
      return 'method';
    case SourceElementType.constructorType:
      return 'constructor';
    case SourceElementType.typedefType:
      return 'typedef';
    case SourceElementType.topLevelVariableType:
      return 'variable';
    case SourceElementType.functionType:
      return 'function';
    case SourceElementType.unknownType:
      return 'unknown';
  }
}

/// A class that represents a Dart element in a source file.
///
/// The element is one of the types in [SourceElementType].
class SourceElement {
  /// A factory constructor for SourceElements.
  ///
  /// This uses a factory so that the default for the `comment` and `samples`
  /// lists can be modifiable lists.
  factory SourceElement(
    SourceElementType type,
    String name,
    int startPos, {
    required File file,
    String className = '',
    List<SourceLine>? comment,
    int startLine = -1,
    List<CodeSample>? samples,
  }) {
    return SourceElement._(
      type,
      name,
      startPos,
      file: file,
      className: className,
      comment: comment ?? <SourceLine>[],
      startLine: startLine,
      samples: samples ?? <CodeSample>[],
    );
  }

  const SourceElement._(
    this.type,
    this.name,
    this.startPos, {
    required this.file,
    this.className = '',
    this.comment = const <SourceLine>[],
    this.startLine = -1,
    this.samples = const <CodeSample>[],
  });

  /// The type of the element
  final SourceElementType type;
  /// The name of the element.
  ///
  /// For example, a method called "doSomething" that is part of the class
  /// "MyClass" would have "doSomething" as its name.
  final String name;
  /// The name of the class the element belongs to, if any.
  ///
  /// This is the empty string if it isn't part of a class.
  ///
  /// For example, a method called "doSomething" that is part of the class
  /// "MyClass" would have "MyClass" as its `className`.
  final String className;
  /// The file that this [SourceElement] was parsed from.
  final File file;
  /// The character position in the file that this [SourceElement] starts at.
  final int startPos;
  /// The line in the file that the first position of [SourceElement] is on.
  final int startLine;
  /// The list of [SourceLine]s that make up the documentation comment for this
  /// [SourceElement].
  final List<SourceLine> comment;
  /// The list of [CodeSample]s that are in the documentation comment for this
  /// [SourceElement].
  ///
  /// This field will be populated by [SnippetDartdocParser.parseFromComments].
  final List<CodeSample> samples;

  /// Returns the fully qualified name of this element.
  ///
  /// For example, a method called "doSomething" that is part of the class
  /// "MyClass" would have "MyClass.doSomething" as its `elementName`.
  String get elementName => className.isEmpty ? name : '$className.$name';

  /// Returns the type of this element as a [String].
  String get typeAsString => sourceElementTypeAsString(type);

  SourceElement copyWith({
    SourceElementType? type,
    String? name,
    int? startPos,
    File? file,
    String? className,
    List<SourceLine>? comment,
    int? startLine,
    List<CodeSample>? samples,
  }) {
    return SourceElement(
      type ?? this.type,
      name ?? this.name,
      startPos ?? this.startPos,
      file: file ?? this.file,
      className: className ?? this.className,
      comment: comment ?? this.comment,
      startLine: startLine ?? this.startLine,
      samples: samples ?? this.samples,
    );
  }
}

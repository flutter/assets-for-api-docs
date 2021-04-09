// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:file/file.dart';
import 'package:pub_semver/pub_semver.dart';

import 'data_types.dart';
import 'interval_tree.dart';

class _LineNumberInterval extends Interval<num, int> {
  _LineNumberInterval(int start, int end, int line) : super(start, end, line);

  @override
  int? mergePayload(Interval<num, int> other) {
    return other.payload == -1 ? payload : other.payload;
  }
}

Iterable<List<SourceLine>> getFileComments(File file) {
  return getComments(getFileElements(file));
}

Iterable<List<SourceLine>> getComments(Iterable<SourceElement> elements) {
  return elements
      .where((SourceElement element) => element.comment.isNotEmpty)
      .map<List<SourceLine>>((SourceElement element) => element.comment);
}

Iterable<SourceElement> getFileCommentElements(File file) {
  return getCommentElements(getFileElements(file));
}

Iterable<SourceElement> getCommentElements(Iterable<SourceElement> elements) {
  return elements.where((SourceElement element) => element.comment.isNotEmpty);
}

// Reads the file content from the string, to avoid having to read it twice if
// the caller already has the content in memory.
Iterable<SourceElement> getElementsFromString(String content, File file) {
  final ParseStringResult parseResult = parseString(
      featureSet: FeatureSet.fromEnableFlags2(
        // TODO(gspencergoog): Get the version string from the flutter --version
        sdkLanguageVersion: Version(2, 12, 1),
        flags: <String>[],
      ),
      content: content);
  final _CommentVisitor<CompilationUnit> visitor = _CommentVisitor<CompilationUnit>(file);
  visitor.visitCompilationUnit(parseResult.unit);
  visitor.assignLineNumbers();
  return visitor.elements;
}

Iterable<SourceElement> getFileElements(File file) {
  final ParseStringResult parseResult = parseFile(
      featureSet: FeatureSet.fromEnableFlags2(
        // TODO(gspencergoog): Get the version string from the flutter --version
        sdkLanguageVersion: Version(2, 12, 1),
        flags: <String>[],
      ),
      path: file.absolute.path);
  final _CommentVisitor<CompilationUnit> visitor = _CommentVisitor<CompilationUnit>(file);
  visitor.visitCompilationUnit(parseResult.unit);
  visitor.assignLineNumbers();
  return visitor.elements;
}

class _CommentVisitor<T> extends RecursiveAstVisitor<T> {
  _CommentVisitor(this.file) : elements = <SourceElement>{};

  final Set<SourceElement> elements;
  String enclosingClass = '';

  File file;

  void assignLineNumbers() {
    final String contents = file.readAsStringSync();
    int lineNumber = 0;
    int startRange = 0;
    final IntervalTree<num, int> itree = IntervalTree<num, int>();
    for (int i = 0; i < contents.length; ++i) {
      if (contents[i] == '\n') {
        itree.add(_LineNumberInterval(startRange, i, lineNumber + 1));
        lineNumber++;
        startRange = i + 1;
      }
    }

    int getLineForPosition(int startChar, int endChar) {
      final IntervalTree<num, int> resultTree = IntervalTree<num, int>()
        ..add(_LineNumberInterval(startChar, endChar, -1));
      final IntervalTree<num, int> intersection = itree.intersection(resultTree);
      if (intersection.isNotEmpty) {
        return intersection.single.payload!;
      } else {
        return -1;
      }
    }

    final Set<SourceElement> removedElements = <SourceElement>{};
    final Set<SourceElement> replacedElements = <SourceElement>{};
    for (final SourceElement element in elements) {
      final List<SourceLine> newLines = <SourceLine>[];
      for (final SourceLine line in element.comment) {
        final int intervalLine = getLineForPosition(line.startChar, line.endChar);
        if (intervalLine != -1) {
          newLines.add(line.copyWith(line: intervalLine));
        } else {
          newLines.add(line);
        }
      }
      final int elementLine = getLineForPosition(element.startPos, element.startPos);
      replacedElements.add(element.copyWith(comment: newLines, startLine: elementLine));
      removedElements.add(element);
    }
    elements.removeAll(removedElements);
    elements.addAll(replacedElements);
  }

  List<SourceLine> _processComment(String element, Comment comment) {
    final List<SourceLine> result = <SourceLine>[];
    if (comment.tokens.isNotEmpty) {
      for (final Token token in comment.tokens) {
        result.add(SourceLine(
          token.toString(),
          element: element,
          file: file,
          startChar: token.charOffset,
          endChar: token.charEnd,
        ));
      }
    }
    return result;
  }

  @override
  T? visitCompilationUnit(CompilationUnit node) {
    elements.clear();
    return super.visitCompilationUnit(node);
  }

  static bool isPublic(String name) {
    return !name.startsWith('_');
  }

  static bool isInsideMethod(AstNode startNode) {
    AstNode? node = startNode.parent;
    while (node != null) {
      if (node is MethodDeclaration) {
        return true;
      }
      node = node.parent;
    }
    return false;
  }

  @override
  T? visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final VariableDeclaration declaration in node.variables.variables) {
      if (!isPublic(declaration.name.name)) {
        continue;
      }
      List<SourceLine> comment = <SourceLine>[];
      if (node.documentationComment != null && node.documentationComment!.tokens.isNotEmpty) {
        comment = _processComment(declaration.name.name, node.documentationComment!);
      }
      elements.add(
        SourceElement(
          SourceElementType.topLevelVariableType,
          declaration.name.name,
          node.beginToken.charOffset,
          file: file,
          className: enclosingClass,
          comment: comment,
        ),
      );
    }
    return super.visitTopLevelVariableDeclaration(node);
  }

  @override
  T? visitGenericTypeAlias(GenericTypeAlias node) {
    if (node.name != null && isPublic(node.name.name)) {
      List<SourceLine> comment = <SourceLine>[];
      if (node.documentationComment != null && node.documentationComment!.tokens.isNotEmpty) {
        comment = _processComment(node.name.name, node.documentationComment!);
      }
      elements.add(
        SourceElement(
          SourceElementType.typedefType,
          node.name.name,
          node.beginToken.charOffset,
          file: file,
          comment: comment,
        ),
      );
    }
    return super.visitGenericTypeAlias(node);
  }

  @override
  T? visitFieldDeclaration(FieldDeclaration node) {
    for (final VariableDeclaration declaration in node.fields.variables) {
      if (!isPublic(declaration.name.name) || !isPublic(enclosingClass)) {
        continue;
      }
      List<SourceLine> comment = <SourceLine>[];
      if (node.documentationComment != null && node.documentationComment!.tokens.isNotEmpty) {
        assert(enclosingClass.isNotEmpty);
        comment =
            _processComment('$enclosingClass.${declaration.name.name}', node.documentationComment!);
      }
      elements.add(
        SourceElement(
          SourceElementType.fieldType,
          declaration.name.name,
          node.beginToken.charOffset,
          file: file,
          className: enclosingClass,
          comment: comment,
        ),
      );
      return super.visitFieldDeclaration(node);
    }
  }

  @override
  T? visitConstructorDeclaration(ConstructorDeclaration node) {
    if (node.name != null && isPublic(node.name!.name) && isPublic(enclosingClass)) {
      List<SourceLine> comment = <SourceLine>[];
      if (node.documentationComment != null && node.documentationComment!.tokens.isNotEmpty) {
        final String element =
            '${enclosingClass.isNotEmpty ? '$enclosingClass.' : ''}${node.name!.name}';
        comment = _processComment(element, node.documentationComment!);
      }
      elements.add(
        SourceElement(
          SourceElementType.constructorType,
          node.name!.name,
          node.beginToken.charOffset,
          file: file,
          className: enclosingClass,
          comment: comment,
        ),
      );
    }
    return super.visitConstructorDeclaration(node);
  }

  @override
  T? visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.name != null && isPublic(node.name.name)) {
      List<SourceLine> comment = <SourceLine>[];
      // Skip functions that are defined inside of methods.
      if (!isInsideMethod(node)) {
        if (node.documentationComment != null && node.documentationComment!.tokens.isNotEmpty) {
          comment = _processComment(node.name.name, node.documentationComment!);
        }
        elements.add(
          SourceElement(
            SourceElementType.functionType,
            node.name.name,
            node.beginToken.charOffset,
            file: file,
            comment: comment,
          ),
        );
      }
    }
    return super.visitFunctionDeclaration(node);
  }

  @override
  T? visitMethodDeclaration(MethodDeclaration node) {
    if (node.name != null && isPublic(node.name.name) && isPublic(enclosingClass)) {
      List<SourceLine> comment = <SourceLine>[];
      if (node.documentationComment != null && node.documentationComment!.tokens.isNotEmpty) {
        assert(enclosingClass.isNotEmpty);
        comment = _processComment('$enclosingClass.${node.name.name}', node.documentationComment!);
      }
      elements.add(
        SourceElement(
          SourceElementType.methodType,
          node.name.name,
          node.beginToken.charOffset,
          file: file,
          className: enclosingClass,
          comment: comment,
        ),
      );
    }
    return super.visitMethodDeclaration(node);
  }

  @override
  T? visitClassDeclaration(ClassDeclaration node) {
    enclosingClass = node.name.name;
    if (node.name != null && !node.name.name.startsWith('_')) {
      enclosingClass = node.name.name;
      List<SourceLine> comment = <SourceLine>[];
      if (node.documentationComment != null && node.documentationComment!.tokens.isNotEmpty) {
        comment = _processComment(node.name.name, node.documentationComment!);
      }
      elements.add(
        SourceElement(
          SourceElementType.classType,
          node.name.name,
          node.beginToken.charOffset,
          file: file,
          comment: comment,
        ),
      );
    }
    final T? result = super.visitClassDeclaration(node);
    enclosingClass = '';
    return result;
  }
}

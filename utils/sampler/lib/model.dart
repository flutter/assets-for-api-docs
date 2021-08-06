// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:snippets/snippets.dart';
import 'package:watcher/watcher.dart';

/// The application model singleton that contains current application state.
class Model extends ChangeNotifier {
  Model._({
    File? workingFile,
    Directory? flutterRoot,
    Directory? dartUiRoot,
    this.filesystem = const LocalFileSystem(),
  })  : _workingFile = workingFile,
        flutterRoot = flutterRoot ?? _findFlutterRoot(),
        dartUiRoot = dartUiRoot ?? _findDartUiRoot(),
        _dartdocParser = SnippetDartdocParser(filesystem),
        _snippetGenerator = SnippetGenerator();

  static Model? _instance;

  /// Resets the instance with new parameters.
  ///
  /// Any existing data in the model will be lost.
  static void resetInstance(
      {File? workingFile,
      Directory? flutterRoot,
      Directory? dartUiRoot,
      FileSystem filesystem = const LocalFileSystem()}) {
    _instance?.dispose();
    _instance = Model._(
      workingFile: workingFile,
      flutterRoot: flutterRoot,
      dartUiRoot: dartUiRoot,
      filesystem: filesystem,
    );
  }

  /// Get the singleton instance for the model class.
  static Model get instance {
    _instance ??= Model._();
    return _instance!;
  }

  /// The [FileSystem] used to handle filesystem requests.
  final FileSystem filesystem;

  static Directory _findFlutterRoot() {
    return FlutterInformation.instance.getFlutterRoot();
  }

  static Directory _findDartUiRoot() {
    return FlutterInformation.instance
        .getFlutterRoot()
        .absolute
        .childDirectory('bin')
        .childDirectory('cache')
        .childDirectory('pkg')
        .childDirectory('sky_engine')
        .childDirectory('lib')
        .childDirectory('ui');
  }

  /// Collects the list of Flutter source files to choose from and populates the
  /// [files] member.
  Future<void> collectFiles(Iterable<Directory> directories, {String suffix = '.dart'}) async {
    files = <File>[];
    for (final Directory directory in directories) {
      final List<File> foundDartFiles = <File>[];
      await for (FileSystemEntity entity in directory.list(recursive: true)) {
        if (entity is Directory || !entity.basename.endsWith(suffix)) {
          continue;
        }
        if (entity is Link) {
          final String resolvedPath = entity.resolveSymbolicLinksSync();
          if (!(await filesystem.isFile(resolvedPath))) {
            continue;
          }
          entity = filesystem.file(resolvedPath);
        }
        assert(entity is File);
        final File file = filesystem.file(entity.absolute.path);
        final File relativePath =
            filesystem.file(path.relative(file.path, from: directory.absolute.path));
        if (path.split(relativePath.path).contains('test')) {
          continue;
        }
        foundDartFiles.add(file);
      }
      files!.addAll(foundDartFiles);
    }
    notifyListeners();
  }

  File? _workingFile;

  /// If true, response to changes in files in the filesystem is suspended.
  /// This is set when writing out updated source files to prevent races.
  bool _suspendReloads = false;
  FileWatcher? _workingFileWatcher;
  String? _workingFileContents;
  String? _workingFileDigest;

  /// Gets the current Flutter dart source file that is being worked on.
  File? get workingFile {
    return _workingFile == null
        ? null
        : filesystem.file(path.join(flutterPackageRoot.absolute.path, _workingFile!.path));
  }

  /// Gets the contents of the [workingFile] as a String.
  ///
  /// The contents are cached to avoid re-reading it all the time.
  String? get workingFileContents => _workingFileContents;

  /// Unset the current working file, and clear out any cached data.
  void clearWorkingFile({bool notify = true}) {
    if (_workingFile == null) {
      return;
    }
    _workingFile = null;
    _workingFileWatcher = null;
    _workingFileContents = null;
    _workingFileDigest = null;
    _currentSample = null;
    _currentElement = null;
    _elements = null;
    if (notify) {
      notifyListeners();
    }
  }

  String _computeDigest(String contents) {
    return md5.convert(utf8.encode(contents)).toString();
  }

  /// Re-parses the working file, and attempts to set the current sample and
  /// element to the updated sample and element, if they exist.
  Future<void> reloadWorkingFile({bool notify = true}) async {
    if (_workingFile == null) {
      assert(_workingFileWatcher == null);
      // No working file, nothing to reload.
      return;
    }
    // Only reload if the contents have actually changed.
    final String contents = await workingFile!.readAsString();
    if (_workingFileDigest != null && _computeDigest(contents) == _workingFileDigest!) {
      return;
    }
    await _loadWorkingFile(contents: contents);
    if (_currentElement != null && _elements != null) {
      // Try to find the old element.
      final Iterable<SourceElement> oldMatches = _elements!
          .where((SourceElement element) => element.elementName == _currentElement!.elementName);
      if (oldMatches.isNotEmpty) {
        _currentElement = oldMatches.first;
      } else {
        throw SnippetException(
            'Unable to find element ${_currentElement!.elementName} during reload.');
      }
    } else {
      _currentElement = null;
      _currentSample = null;
    }
    if (_currentElement != null && _currentSample != null) {
      final Iterable<CodeSample> samples = _currentElement!.samples
          .where((CodeSample sample) => sample.index == _currentSample!.index);
      if (samples.length != 1) {
        throw SnippetException(
            'Unable to find sample ${_currentSample!.index} on ${_currentElement!.elementName} during reload.');
      }
      _currentSample = samples.single;
    } else {
      _currentSample = null;
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _loadWorkingFile({String? contents}) async {
    if (_workingFile == null) {
      return;
    }
    _workingFileContents = contents ?? await workingFile!.readAsString();
    _workingFileDigest = _computeDigest(_workingFileContents!);
    _workingFileWatcher = FileWatcher(workingFile!.path);
    _workingFileWatcher!.events.listen((WatchEvent event) {
      if (!_suspendReloads) {
        reloadWorkingFile();
      }
    });
    _elements = getElementsFromString(_workingFileContents!, workingFile!);
    _dartdocParser.parseFromComments(_elements!);
    _dartdocParser.parseAndAddAssumptions(_elements!, workingFile!, silent: true);
    for (final CodeSample sample in samples) {
      _snippetGenerator.generateCode(sample, addSectionMarkers: true, includeAssumptions: true);
    }
    print('Loaded ${samples.length} samples from ${workingFile!.path}');
  }

  /// Set the current working file, resetting any cached data.
  Future<void> setWorkingFile(File value) async {
    if (_workingFile == value) {
      return;
    }
    clearWorkingFile(notify: false);
    _workingFile = value;
    reloadWorkingFile();
  }

  /// Inserts a new sample placeholder into the [currentElement], and write it
  /// out to the [workingFile].
  Future<void> insertNewSample({Type sampleType = SnippetSample, String? template}) async {
    assert(_workingFile != null, 'Working file must be set to insert a sample');

    // If reloading the file invalidates the current element (because it
    // disappeared), then throw.
    if (_currentElement == null) {
      notifyListeners();
      throw SnippetException(
          'Selected symbol no longer present in file ${workingFile ?? '<none>'}');
    }

    // Find the insertion line automatically. It is either at the end of
    // the comment block, or just before the line that has "See also:" on it, if
    // one exists.
    int? insertAfterLine;
    bool foundSeeAlso = false;
    for (final SourceLine line in _currentElement!.comment) {
      if (line.text.contains('See also:')) {
        insertAfterLine = line.line - 1;
        foundSeeAlso = true;
      }
    }

    // If there's no comment, we want to insert after the line before the
    // location of the element, to be sure to insert before any annotations.
    insertAfterLine ??= _currentElement!.comment.isNotEmpty
        ? _currentElement!.comment.last.line
        : currentElement!.startLine - 1;

    late List<String> insertedTags;
    final List<String> body = <String>[
      '///',
      '/// Replace this text with the description of this sample.',
      '///',
      '/// ```dart',
      '/// Widget build(BuildContext context) {',
      '///   // Sample code goes here.',
      '///   return const SizedBox();',
      '/// }',
      '/// ```',
      '/// {@end-tool}',
      if (foundSeeAlso) '///',
    ];

    switch (sampleType) {
      case SnippetSample:
        insertedTags = <String>[
          if (!foundSeeAlso) '///',
          '/// {@tool snippet}',
          ...body,
        ];
        break;
      case ApplicationSample:
        insertedTags = <String>[
          if (!foundSeeAlso) '///',
          '/// {@tool sample --template=$template}',
          ...body
        ];
        break;
      case DartpadSample:
        insertedTags = <String>[
          if (!foundSeeAlso) '///',
          '/// {@tool dartpad --template=$template}',
          ...body
        ];
        break;
    }

    // Get the indent needed for the new lines.
    final List<String> contents = _workingFileContents!.split('\n');
    final String indent = ' ' * getIndent(contents[insertAfterLine]);
    // Write out the new file, inserting the new tags.
    final List<String> output = contents
      ..insertAll(
        insertAfterLine,
        insertedTags.map<String>((String line) => '$indent$line'),
      );

    _suspendReloads = true;
    await workingFile!.writeAsString(output.join('\n'));

    // Now reload to parse the new sample.
    await reloadWorkingFile(notify: false);

    // If reloading the file invalidates the current element (because it
    // disappeared), then throw.
    if (_currentElement == null) {
      throw SnippetException(
          'Selected symbol no longer present in file ${workingFile ?? '<none>'}');
    }

    // Select the newly inserted sample, assuming that in the reload it was
    // found as the last sample on the current element.
    _currentSample = _currentElement!.samples.last;

    _suspendReloads = false;
    notifyListeners();
  }

  /// Get the names of all the available templates in the templates dir.
  Iterable<String> getTemplateNames() {
    return _snippetGenerator
        .getAvailableTemplates()
        .map<String>((File file) => file.basename.replaceFirst('.tmpl', ''));
  }

  /// The currently selected code sample, or null, if none is selected.
  CodeSample? get currentSample => _currentSample;
  CodeSample? _currentSample;
  set currentSample(CodeSample? value) {
    if (value != _currentSample) {
      _currentSample = value;
      notifyListeners();
    }
  }

  /// The element corresponding to the currently selected code sample.
  SourceElement? get currentElement => _currentElement;
  SourceElement? _currentElement;
  set currentElement(SourceElement? value) {
    if (value != _currentElement) {
      _currentElement = value;
      notifyListeners();
    }
  }

  /// Find the element that owns a particular sample.
  SourceElement? getElementForSample(CodeSample sample) {
    if (elements == null) {
      return null;
    }
    return elements!.where((SourceElement element) => element.samples.contains(sample)).single;
  }

  /// The list of samples available in all of the elements in the file.
  Iterable<CodeSample> get samples {
    return _elements?.expand<CodeSample>((SourceElement element) => element.samples) ??
        const <CodeSample>[];
  }

  /// The Dart elements (classes, members, etc.) defined in the [workingFile].
  Iterable<SourceElement>? get elements => _elements;
  Iterable<SourceElement>? _elements;

  /// The location of the dart:ui root, so that the examples in that root may be
  /// edited.
  Directory dartUiRoot;

  /// The location of the flutter root directory to look for files in.
  Directory flutterRoot;

  /// The location of the flutter framework package directory.
  Directory get flutterPackageRoot =>
      flutterRoot.childDirectory('packages').childDirectory('flutter');

  /// The list of source files available in the Flutter framework and dart:ui.
  ///
  /// Populated by calling [collectFiles].
  List<File>? files;

  final SnippetDartdocParser _dartdocParser;
  final SnippetGenerator _snippetGenerator;
}

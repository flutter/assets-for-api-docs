// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:path/path.dart' as path;

// Represents the locations of all of the data for snippets.
class SnippetConfiguration {
  const SnippetConfiguration({
    required this.configDirectory,
    required this.outputDirectory,
    required this.skeletonsDirectory,
    required this.templatesDirectory,
    this.filesystem = const LocalFileSystem(),
  });

  final FileSystem filesystem;

  /// This is the configuration directory for the snippets system, containing
  /// the skeletons and templates.
  final Directory configDirectory;

  /// This is where the snippets themselves will be written, in order to be
  /// uploaded to the docs site.
  final Directory outputDirectory;

  /// The directory containing the HTML skeletons to be filled out with metadata
  /// and returned to dartdoc for insertion in the output.
  final Directory skeletonsDirectory;

  /// The directory containing the code templates that can be referenced by the
  /// dartdoc.
  final Directory templatesDirectory;

  /// This makes sure that the output directory exists, and creates it if it
  /// doesn't.
  void createOutputDirectoryIfNeeded() {
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }
  }

  /// Gets the skeleton file to use for the given [SampleType] and DartPad
  /// preference.
  File getHtmlSkeletonFile(String type) {
    final String filename =
        type == 'dartpad' ? 'dartpad-sample.html' : '$type.html';
    return filesystem.file(path.join(skeletonsDirectory.path, filename));
  }
}

/// A class to compute the configuration of the snippets input and output
/// locations based in the current location of the snippets main.dart.
class FlutterRepoSnippetConfiguration extends SnippetConfiguration {
  FlutterRepoSnippetConfiguration(
      {required this.flutterRoot,
      FileSystem filesystem = const LocalFileSystem()})
      : super(
          filesystem: filesystem,
          configDirectory: _underRoot(filesystem, flutterRoot,
              const <String>['dev', 'snippets', 'config']),
          outputDirectory: _underRoot(filesystem, flutterRoot,
              const <String>['dev', 'docs', 'doc', 'snippets']),
          skeletonsDirectory: _underRoot(filesystem, flutterRoot,
              const <String>['dev', 'snippets', 'config', 'skeletons']),
          templatesDirectory: _underRoot(
            filesystem,
            flutterRoot,
            const <String>['dev', 'snippets', 'config', 'templates'],
          ),
        );

  final Directory flutterRoot;

  static Directory _underRoot(
          FileSystem fs, Directory flutterRoot, List<String> dirs) =>
      fs.directory(path.canonicalize(
          path.joinAll(<String>[flutterRoot.absolute.path, ...dirs])));
}

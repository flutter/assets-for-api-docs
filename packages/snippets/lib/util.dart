// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart' show LocalPlatform, Platform;
import 'package:process/process.dart' show ProcessManager, LocalProcessManager;
import 'package:pub_semver/pub_semver.dart';

import 'data_types.dart';

/// An exception class to allow capture of exceptions generated by the Snippets
/// package.
class SnippetException implements Exception {
  SnippetException(this.message, {this.file, this.line});
  final String message;
  final String? file;
  final int? line;

  @override
  String toString() {
    if (file != null || line != null) {
      final String fileStr = file == null ? '' : '$file:';
      final String lineStr = line == null ? '' : '$line:';
      return '$runtimeType: $fileStr$lineStr: $message';
    } else {
      return '$runtimeType: $message';
    }
  }
}

/// Gets the number of whitespace characters at the beginning of a line.
int getIndent(String line) => line.length - line.trimLeft().length;

/// Contains information about the installed Flutter repo.
class FlutterInformation {
  FlutterInformation({
    this.platform = const LocalPlatform(),
    this.processManager = const LocalProcessManager(),
    this.filesystem = const LocalFileSystem(),
  });

  final Platform platform;
  final ProcessManager processManager;
  final FileSystem filesystem;

  static FlutterInformation? _instance;

  static FlutterInformation get instance => _instance ??= FlutterInformation();

  @visibleForTesting
  static set instance(FlutterInformation? value) => _instance = value;

  Directory getFlutterRoot() {
    if (platform.environment['FLUTTER_ROOT'] != null) {
      return filesystem.directory(platform.environment['FLUTTER_ROOT']);
    }
    return getFlutterInformation()['flutterRoot'] as Directory;
  }

  Version getFlutterVersion() => getFlutterInformation()['frameworkVersion'] as Version;

  Version getDartSdkVersion() => getFlutterInformation()['dartSdkVersion'] as Version;

  Map<String, dynamic>? _cachedFlutterInformation;

  Map<String, dynamic> getFlutterInformation() {
    if (_cachedFlutterInformation != null) {
      return _cachedFlutterInformation!;
    }
    String flutterCommand;
    if (platform.environment['FLUTTER_ROOT'] != null) {
      flutterCommand = filesystem
          .directory(platform.environment['FLUTTER_ROOT'])
          .childDirectory('bin')
          .childFile('flutter')
          .absolute
          .path;
    } else {
      flutterCommand = 'flutter';
    }
    io.ProcessResult result;
    String flutterVersionJson;
    if (platform.environment['FLUTTER_VERSION'] != null) {
      flutterVersionJson = platform.environment['FLUTTER_VERSION']!;
    } else {
      try {
        result = processManager
            .runSync(<String>[flutterCommand, '--version', '--machine'], stdoutEncoding: utf8);
      } on io.ProcessException catch (e) {
        throw SnippetException(
            'Unable to determine Flutter information. Either set FLUTTER_ROOT, or place flutter command in your path.\n$e');
      }
      if (result.exitCode != 0) {
        throw SnippetException(
            'Unable to determine Flutter information, because of abnormal exit to flutter command.');
      }
      flutterVersionJson = (result.stdout as String).replaceAll(
          'Waiting for another flutter command to release the startup lock...', '');
    }
    final Map<String, dynamic> flutterVersion = json.decode(flutterVersionJson) as Map<String, dynamic>;
    if (flutterVersion['flutterRoot'] == null ||
        flutterVersion['frameworkVersion'] == null ||
        flutterVersion['dartSdkVersion'] == null) {
      throw SnippetException(
          'Flutter command output has unexpected format, unable to determine flutter root location.');
    }
    final Map<String, dynamic> info = <String, dynamic>{};
    info['flutterRoot'] = filesystem.directory(flutterVersion['flutterRoot']! as String);
    info['frameworkVersion'] = Version.parse(flutterVersion['frameworkVersion'] as String);
    final RegExpMatch? dartVersionRegex =
        RegExp(r'(?<base>[\d.]+)(?:\s+\(build (?<detail>[-.\w]+)\))?')
            .firstMatch(flutterVersion['dartSdkVersion'] as String);
    if (dartVersionRegex == null) {
      throw SnippetException(
          'Flutter command output has unexpected format, unable to parse dart SDK version ${flutterVersion['dartSdkVersion']}.');
    }
    info['dartSdkVersion'] = Version.parse(
        dartVersionRegex.namedGroup('detail') ?? dartVersionRegex.namedGroup('base')!);
    _cachedFlutterInformation = info;
    return info;
  }
}

/// Returns a marker with section arrows surrounding the given string.
///
/// Specifying `start` as false returns an ending marker instead of a starting
/// marker.
String sectionArrows(String name, {bool start = true}) {
  const int markerArrows = 8;
  final String arrows = (start ? '\u25bc' /* ▼ */ : '\u25b2' /* ▲ */) * markerArrows;
  final String marker = '//* $arrows $name $arrows (do not modify or remove section marker)';
  return '${start ? '\n//*${'*' * marker.length}\n' : '\n'}'
      '$marker'
      '${!start ? '\n//*${'*' * marker.length}\n' : '\n'}';
}

/// Injects the [injections] into the [template], while turning the
/// "description" injection into a comment.
String interpolateTemplate(
  List<TemplateInjection> injections,
  String template,
  Map<String, Object?> metadata, {
  bool addSectionMarkers = false,
  bool addCopyright = false,
}) {
  String wrapSectionMarker(Iterable<String> contents, {required String name}) {
    final String result = <String>[
      if (addSectionMarkers) sectionArrows(name, start: true),
      ...contents,
      if (addSectionMarkers) sectionArrows(name, start: false),
    ].join('\n');
    return result.isEmpty ? result : '$result\n';
  }

  return '${addCopyright ? '{{copyright}}\n\n' : ''}$template'
      .replaceAllMapped(RegExp(r'{{([^}]+)}}'), (Match match) {
    final String name = match[1]!;
    final int componentIndex =
        injections.indexWhere((TemplateInjection injection) => injection.name == name);
    if (metadata[name] != null && componentIndex == -1) {
      // If the match isn't found in the injections, then just return the
      // metadata entry.
      return wrapSectionMarker((metadata[name]! as String).split('\n'), name: name);
    }
    return wrapSectionMarker(
        componentIndex >= 0 ? injections[componentIndex].stringContents : <String>[],
        name: name);
  }).replaceAll(RegExp(r'\n\n+'), '\n\n');
}

class SampleStats {
  const SampleStats({
    this.totalSamples = 0,
    this.dartpadSamples = 0,
    this.snippetSamples = 0,
    this.applicationSamples = 0,
    this.wordCount = 0,
    this.lineCount = 0,
    this.linkCount = 0,
    this.description = '',
  });

  final int totalSamples;
  final int dartpadSamples;
  final int snippetSamples;
  final int applicationSamples;
  final int wordCount;
  final int lineCount;
  final int linkCount;
  final String description;
  bool get allOneKind =>
      totalSamples == snippetSamples ||
      totalSamples == applicationSamples ||
      totalSamples == dartpadSamples;

  @override
  String toString() {
    return description;
  }
}

Iterable<CodeSample> getSamplesInElements(Iterable<SourceElement>? elements) {
  return elements?.expand<CodeSample>((SourceElement element) => element.samples) ??
      const <CodeSample>[];
}

SampleStats getSampleStats(SourceElement element) {
  if (element.comment.isEmpty) {
    return const SampleStats();
  }
  final int total = element.sampleCount;
  if (total == 0) {
    return const SampleStats();
  }
  final int dartpads = element.dartpadSampleCount;
  final int snippets = element.snippetCount;
  final int applications = element.applicationSampleCount;
  final String sampleCount = <String>[
    if (snippets > 0) '$snippets snippet${snippets != 1 ? 's' : ''}',
    if (applications > 0) '$applications application sample${applications != 1 ? 's' : ''}',
    if (dartpads > 0) '$dartpads dartpad sample${dartpads != 1 ? 's' : ''}'
  ].join(', ');
  final int wordCount = element.wordCount;
  final int lineCount = element.lineCount;
  final int linkCount = element.referenceCount;
  final String description = <String>[
    'Documentation has $wordCount ${wordCount == 1 ? 'word' : 'words'} on ',
    '$lineCount ${lineCount == 1 ? 'line' : 'lines'}',
    if (linkCount > 0 && element.hasSeeAlso) ', ',
    if (linkCount > 0 && !element.hasSeeAlso) ' and ',
    if (linkCount > 0) 'refers to $linkCount other ${linkCount == 1 ? 'symbol' : 'symbols'}',
    if (linkCount > 0 && element.hasSeeAlso) ', and ',
    if (linkCount == 0 && element.hasSeeAlso) 'and ',
    if (element.hasSeeAlso) 'has a "See also:" section',
    '.',
  ].join('');
  return SampleStats(
    totalSamples: total,
    dartpadSamples: dartpads,
    snippetSamples: snippets,
    applicationSamples: applications,
    wordCount: wordCount,
    lineCount: lineCount,
    linkCount: linkCount,
    description: 'Has $sampleCount. $description',
  );
}

/// Exit the app with a message to stderr.
void errorExit(String message) {
  io.stderr.writeln(message);
  io.exit(1);
}

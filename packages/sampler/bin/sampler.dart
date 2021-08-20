// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' show exitCode, stderr;

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import 'package:path/path.dart' as path;
import 'package:platform/platform.dart';
import 'package:process_runner/process_runner.dart';
import 'package:snippets/snippets.dart';

ProcessRunner processRunner = ProcessRunner();

File findExecutableForPlatform(String executableName, Directory packageDirectory) {
  final FileSystem filesystem = FlutterInformation.instance.filesystem;
  switch (FlutterInformation.instance.platform.operatingSystem) {
    case 'linux':
      return filesystem.file(path.join(
        packageDirectory.path,
        'build',
        'linux',
        'x64',
        'release',
        'bundle',
        executableName,
      ));
    case 'macos':
      return filesystem.file(path.joinAll(<String>[
        packageDirectory.path,
        'build',
        'macos',
        'Build',
        'Product',
        'Release',
        '$executableName.app',
        'Contents',
        'MacOS',
        executableName,
      ]));
    case 'windows':
      return filesystem.file(path.joinAll(<String>[
        packageDirectory.path,
        'build',
        'windows',
        'runner',
        'Release',
        '$executableName.exe',
      ]));
    default:
      throw FileSystemException(
          'Unable to find $executableName on platform ${FlutterInformation.instance.platform.operatingSystem}');
  }
}

String getDigests(List<File> files) {
  final AccumulatorSink<Digest> sums = AccumulatorSink<Digest>();
  final ByteConversionSink input = sha1.startChunkedConversion(sums);
  for (final File file in files) {
    sums.add(sha1.convert(file.readAsBytesSync()));
  }
  input.close();
  return sums.events.toString();
}

String getPackageDigest(Directory packageLocation) {
  return getDigests(<File>[
    ...packageLocation
        .childDirectory('lib')
        .listSync(recursive: true)
        .where((FileSystemEntity entity) => entity is File && entity.basename.endsWith('.dart'))
        .cast<File>(),
    packageLocation.childDirectory('bin').childFile('sampler.dart'),
    packageLocation.childFile('pubspec.yaml'),
  ]);
}

Future<File?> buildExecutableIfNeeded(Directory packageLocation) async {
  final Platform platform = FlutterInformation.instance.platform;
  final Directory flutterRoot = FlutterInformation.instance.getFlutterRoot();
  final File mainLocation = packageLocation.childDirectory('lib').childFile('main.dart');
  final File flutterExe =
      flutterRoot.childDirectory('bin').childFile(platform.isWindows ? 'flutter.bat' : 'flutter');
  final File builtExecutable = findExecutableForPlatform('sampler', packageLocation);

  final File lastBuildDigestFile =
      packageLocation.childDirectory('build').childFile('package_digest');
  final String packageDigest = getPackageDigest(packageLocation);
  final String previousDigest =
      lastBuildDigestFile.existsSync() ? lastBuildDigestFile.readAsStringSync() : '';
  if (!builtExecutable.existsSync() || packageDigest != previousDigest) {
    stderr.writeln('Building sampler...');
    stderr.writeln(
        'Due to the way sampler is packaged, this may take a while (~30s) the first time.');
    final ProcessRunnerResult result = await processRunner.runProcess(<String>[
      flutterExe.absolute.path,
      'build',
      platform.operatingSystem,
      '--release',
      '--target=${mainLocation.absolute.path}',
    ], workingDirectory: packageLocation.absolute);
    if (result.exitCode != 0) {
      exitCode = result.exitCode;
      stderr.writeln('Unable to build sampler executable:\n${result.output}');
      return null;
    }
    lastBuildDigestFile.writeAsStringSync(packageDigest);
    stderr.writeln('Sampler built, running $builtExecutable');
  }
  return builtExecutable;
}

Future<void> main(List<String> args) async {
  final Platform platform = FlutterInformation.instance.platform;
  final Directory packageLocation =
      FlutterInformation.instance.filesystem.file(platform.script.toFilePath()).parent.parent;

  final File? builtExecutable = await buildExecutableIfNeeded(packageLocation);
  if (builtExecutable == null) {
    return;
  }

  final ProcessRunnerResult result = await processRunner.runProcess(<String>[
    builtExecutable.absolute.path,
    ...args,
  ], workingDirectory: packageLocation.absolute);

  exitCode = result.exitCode;
}

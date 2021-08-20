// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show exitCode, stderr;

import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:platform/platform.dart';
import 'package:process_runner/process_runner.dart';
import 'package:snippets/snippets.dart';

// These are global so that tests can modify them.
@visibleForTesting
ProcessRunner processRunner =
    ProcessRunner(processManager: FlutterInformation.instance.processManager);
@visibleForTesting
Platform platform = FlutterInformation.instance.platform;
@visibleForTesting
FileSystem filesystem = FlutterInformation.instance.filesystem;

File findExecutableForPlatform(
    String executableName, Directory packageDirectory) {
  switch (platform.operatingSystem) {
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
        'Products',
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
      throw FileSystemException('Unable to find $executableName on platform '
          '${platform.operatingSystem}');
  }
}

String getDigests(List<File> files) {
  final List<String> contents = <String>[];
  for (final File file in files) {
    contents.add(sha1.convert(file.readAsBytesSync()).toString());
  }
  return sha1.convert(contents.join('').codeUnits).toString();
}

String getPackageDigest(Directory packageLocation) {
  return getDigests(<File>[
    ...packageLocation
        .childDirectory('lib')
        .listSync(recursive: true)
        .where((FileSystemEntity entity) =>
            entity is File && entity.basename.endsWith('.dart'))
        .cast<File>(),
    packageLocation.childDirectory('bin').childFile('sampler.dart'),
    packageLocation.childFile('pubspec.yaml'),
  ]);
}

Future<void> copyDirectory(Directory source, Directory destination) async {
  await for (final FileSystemEntity entity in source.list(recursive: false)) {
    if (entity is Directory) {
      final Directory newDirectory =
          destination.absolute.childDirectory(entity.basename);
      await newDirectory.create();
      await copyDirectory(entity.absolute, newDirectory);
    } else if (entity is File) {
      await entity.copy(destination.childFile(entity.basename).path);
    }
  }
}

Future<void> copyPackageToTmpDir(
  Directory tmpDir,
  Directory packageLocation,
  String packageDigest,
  String previousDigest,
) async {
  if (tmpDir.existsSync()) {
    return;
  }
  if (previousDigest.isNotEmpty) {
    final Directory previousTmpDir = FlutterInformation
        .instance.filesystem.systemTempDirectory
        .childDirectory('sampler_build_${previousDigest.substring(0, 10)}');
    if (previousTmpDir.existsSync()) {
      try {
        previousTmpDir.deleteSync(recursive: true);
      } on FileSystemException {
        // Don't worry about failures removing the old temporary directory.
      }
    }
  }
  tmpDir.createSync(recursive: true);
  await copyDirectory(packageLocation.absolute, tmpDir.absolute);
  return;
}

Directory getTempDir(String packageDigest) {
  return filesystem.systemTempDirectory
      .childDirectory('sampler_build_${packageDigest.substring(0, 10)}');
}

Future<File?> buildExecutableIfNeeded(Directory packageLocation) async {
  final File lastBuildDigestFile = packageLocation.childFile('package_digest');
  final String packageDigest = getPackageDigest(packageLocation);
  final String previousDigest = lastBuildDigestFile.existsSync()
      ? lastBuildDigestFile.readAsStringSync()
      : '';

  // Because the flutter tool refuses to run pub get inside of a pub cache directory
  // (ok, that is actually kind of sensible), copy this package into a temp directory
  // and build it there. If the digest changes, then blow away the old temp directory
  // and build it in a new one.
  final Directory tmpDir = getTempDir(packageDigest);
  await copyPackageToTmpDir(
      tmpDir, packageLocation, packageDigest, previousDigest);
  final File builtExecutable = findExecutableForPlatform('sampler', tmpDir);
  final bool mustRebuild =
      !builtExecutable.existsSync() || packageDigest != previousDigest;
  if (mustRebuild) {
    stderr.writeln('Building sampler...');
    stderr.writeln(
        'Due to the way sampler is packaged, this may take a while (~1 min) the first time.');
  }

  // These should be initialized here, to avoid calling `flutter --version --machine`
  // too early in FlutterInformation, causing a wait before printing the build message above.
  final Directory flutterRoot = FlutterInformation.instance.getFlutterRoot();
  final File flutterExe = flutterRoot
      .childDirectory('bin')
      .childFile(platform.isWindows ? 'flutter.bat' : 'flutter');
  if (mustRebuild) {
    final File mainLocation =
        tmpDir.childDirectory('lib').childFile('main.dart');
    ProcessRunnerResult result = await processRunner.runProcess(<String>[
      flutterExe.absolute.path,
      'create',
      '--no-overwrite',
      '--project-name=sampler',
      '--org=flutter.dev',
      '--platforms=${platform.operatingSystem}',
      '.',
    ], workingDirectory: tmpDir);
    if (result.exitCode != 0) {
      exitCode = result.exitCode;
      stderr.writeln('Unable to create sampler executable:\n${result.output}');
      return null;
    }

    result = await processRunner.runProcess(<String>[
      flutterExe.absolute.path,
      'build',
      platform.operatingSystem,
      '--release',
      '--target=${mainLocation.absolute.path}',
    ], workingDirectory: tmpDir);
    if (result.exitCode != 0) {
      exitCode = result.exitCode;
      stderr.writeln('Unable to build sampler executable:\n${result.output}');
      return null;
    }
    lastBuildDigestFile.writeAsStringSync(packageDigest);
  }
  stderr.writeln('Sampler built: ${builtExecutable.path}');
  return builtExecutable;
}

Future<void> main(List<String> args) async {
  final Platform platform = FlutterInformation.instance.platform;
  final Directory packageLocation = FlutterInformation.instance.filesystem
      .file(platform.script.toFilePath())
      .parent
      .parent;

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

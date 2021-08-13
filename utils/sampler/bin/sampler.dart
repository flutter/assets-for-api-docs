// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show exitCode, stderr;

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
      throw FileSystemException('Unable to find $executableName on platform ${FlutterInformation.instance.platform.operatingSystem}');
  }
}

Future<void> main(List<String> args) async {
  final Platform platform = FlutterInformation.instance.platform;
  final Directory packageLocation =
      FlutterInformation.instance.filesystem.file(platform.script.toFilePath()).parent.parent;
  final File mainLocation = packageLocation.childDirectory('lib').childFile('main.dart');
  final Directory flutterRoot = FlutterInformation.instance.getFlutterRoot();
  final File flutterExe =
      flutterRoot.childDirectory('bin').childFile(platform.isWindows ? 'flutter.bat' : 'flutter');

  final File builtExecutable = findExecutableForPlatform('sampler', packageLocation);
  if (!builtExecutable.existsSync()) {
    stderr.writeln('Building sampler...');
    stderr.writeln('Due to the way sampler is packaged, this may take a while (~30s) the first time.');
    final ProcessRunnerResult result = await processRunner.runProcess(<String>[
      flutterExe.absolute.path,
      'build',
      platform.operatingSystem,
      '--release',
      '--target=${mainLocation.absolute.path}',
    ], workingDirectory: packageLocation.absolute);
    if (result.exitCode != 0) {
      exitCode = result.exitCode;
      return;
    }
    stderr.writeln('Sampler built, running $builtExecutable');
  }

  final ProcessRunnerResult result = await processRunner.runProcess(<String>[
    builtExecutable.absolute.path,
    ...args,
  ], workingDirectory: packageLocation.absolute);

  exitCode = result.exitCode;
}

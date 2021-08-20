// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:file/memory.dart';
import 'package:path/path.dart' as path;
import 'package:platform/platform.dart';
import 'package:process_runner/process_runner.dart';
import 'package:snippets/snippets.dart';
import 'package:snippets/util.dart';
import 'package:test/test.dart' hide TypeMatcher, isInstanceOf;

import '../bin/sampler.dart' as sampler_main;
import 'fake_process_manager.dart';

void main() {
  group('Rebuilding', () {
    late MemoryFileSystem memoryFileSystem;
    late FakeProcessManager fakeProcessManager;
    late FakePlatform fakePlatform;
    late Directory flutterRoot;
    late Directory tmpDir;
    late Directory packageRoot;
    const String testDigest = 'f92d1a923c000a00783e1e977481431eaa521c22';

    setUp(() {
      // Create a new filesystem.
      memoryFileSystem = MemoryFileSystem();
      fakeProcessManager = FakeProcessManager();
      tmpDir = memoryFileSystem.systemTempDirectory
          .createTempSync('flutter_sampler_test.');
      flutterRoot = tmpDir.absolute.childDirectory('flutter')
        ..createSync(recursive: true);
      final File flutterCommand =
          flutterRoot.childDirectory('bin').childFile('flutter');
      flutterCommand.createSync(recursive: true);
      packageRoot = tmpDir.absolute
          .childDirectory('.pub-cache')
          .childDirectory('sampler-0.1.0')
        ..createSync(recursive: true);
      final File scriptFile = packageRoot
          .childDirectory('bin')
          .childFile('sampler.dart')
        ..createSync(recursive: true);
      packageRoot.childDirectory('lib').childFile('main.dart')
        ..createSync(recursive: true)
        ..writeAsStringSync('void main() {}');
      packageRoot.childFile('pubspec.yaml')
        ..createSync(recursive: true)
        ..writeAsStringSync('''
      environment:
        sdk: ">=2.12.0 <3.0.0
      ''');
      fakePlatform = FakePlatform(
        environment: <String, String>{
          'PACKAGE_NAME': 'dart:ui',
          'LIBRARY_NAME': 'library',
          'ELEMENT_NAME': 'element',
          'FLUTTER_ROOT': flutterRoot.absolute.path,
          // The details here don't really matter other than the flutter root.
          'FLUTTER_VERSION': '''
      {
        "frameworkVersion": "2.5.0-6.0.pre.55",
        "channel": "use_snippets_pkg",
        "repositoryUrl": "git@github.com:flutter/flutter.git",
        "frameworkRevision": "fec4641e1c88923ecd6c969e2ff8a0dd12dc0875",
        "frameworkCommitDate": "2021-08-11 15:19:48 -0700",
        "engineRevision": "d8bbebed60a77b3d4fe9c840dc94dfbce159d951",
        "dartSdkVersion": "2.14.0 (build 2.14.0-393.0.dev)",
        "flutterRoot": "${flutterRoot.absolute.path}"
      }''',
        },
        script: Uri.file(scriptFile.path),
        operatingSystem: 'macos',
      );
      FlutterInformation.instance = FlutterInformation(
          filesystem: memoryFileSystem,
          processManager: fakeProcessManager,
          platform: fakePlatform);
      // Update the globals in the main with the new values.
      sampler_main.processRunner = ProcessRunner(
          processManager: FlutterInformation.instance.processManager);
      sampler_main.filesystem = FlutterInformation.instance.filesystem;
      sampler_main.platform = FlutterInformation.instance.platform;
    });

    tearDown(() {
      FlutterInformation.instance = null;
      sampler_main.processRunner = ProcessRunner(
          processManager: FlutterInformation.instance.processManager);
      sampler_main.filesystem = FlutterInformation.instance.filesystem;
      sampler_main.platform = FlutterInformation.instance.platform;
    });

    test('rebuilds on different digest', () async {
      await sampler_main.main(<String>[]);
      expect(fakeProcessManager.commands.length, equals(3));
      expect(fakeProcessManager.commands[0][0].endsWith('flutter'), isTrue);
      expect(fakeProcessManager.commands[0][1].endsWith('create'), isTrue);
      expect(fakeProcessManager.commands[1][0].endsWith('flutter'), isTrue);
      expect(fakeProcessManager.commands[1][1].endsWith('build'), isTrue);
      expect(fakeProcessManager.commands[2][0].endsWith('sampler'), isTrue);
    });

    test("doesn't rebuild on same digest", () async {
      // /.tmp_rand0/flutter_sampler_test.rand0/.pub-cache/sampler-0.1.0/package_digest
      // Create an existing digest for test files created in setUp.
      packageRoot.childFile('package_digest').writeAsStringSync(testDigest);
      memoryFileSystem.file(path.joinAll(<String>[
        memoryFileSystem.systemTempDirectory.path,
        'sampler_build_${testDigest.substring(0, 10)}',
        'build',
        'macos',
        'Build',
        'Products',
        'Release',
        'sampler.app',
        'Contents',
        'MacOS',
        'sampler',
      ]))
        ..createSync(recursive: true)
        ..writeAsStringSync('exe');
      await sampler_main.main(<String>[]);
      expect(
        fakeProcessManager.commands.length,
        equals(1),
        reason: 'Commands are:\n${fakeProcessManager.commands}',
      );
      expect(fakeProcessManager.commands[0][0].endsWith('sampler'), isTrue);
    });
  });

  group('Building', () {
    const FileSystem filesystem = LocalFileSystem();
    final Directory packageDir =
        filesystem.file(const LocalPlatform().script.toFilePath()).parent;
    Directory? tmpDir;

    tearDown(() async {
      if (tmpDir != null) {
        try {
          // Just to be sure that the tmpDir didn't end up being "/" :-)
          if (tmpDir!.basename.startsWith('sampler_build_')) {
            await tmpDir!.delete(recursive: true);
          }
          // Have to delete the package digest too.
          await packageDir.childFile('package_digest').delete();
        } on FileSystemException {
          // ignore
        }
      }
    });

    test('can build, and flutter create works with our entitlements', () async {
      final String packageDigest = sampler_main.getPackageDigest(packageDir);
      tmpDir = sampler_main.getTempDir(packageDigest);
      expect(tmpDir, isNotNull);
      expect(tmpDir!.existsSync(), isFalse);
      final File? executable =
          await sampler_main.buildExecutableIfNeeded(packageDir);
      expect(executable, isNotNull);
    }, timeout: const Timeout(Duration(minutes: 5)));
  });
}

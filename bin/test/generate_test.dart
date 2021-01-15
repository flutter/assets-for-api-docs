// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'package:process_runner/process_runner.dart';

import '../generate.dart';
import 'fake_process_manager.dart';

final String repoRoot =
    path.dirname(path.dirname(path.dirname(path.fromUri(Platform.script))));

void main() {
  group('DiagramGenerator', () {
    DiagramGenerator generator;
    Directory temporaryDirectory;
    FakeProcessManager processManager;

    setUp(() {
      processManager = FakeProcessManager((String input) {});
      temporaryDirectory = Directory.systemTemp.createTempSync('flutter_generate_test.');
      generator = DiagramGenerator(
        processRunner: ProcessRunner(processManager: processManager),
        temporaryDirectory: temporaryDirectory,
        cleanup: false,
      );
    });

    tearDown(() {
      temporaryDirectory.delete(recursive: true);
    });

    test('make sure generate generates', () async {
      final Map<FakeInvocationRecord, List<ProcessResult>> calls = <FakeInvocationRecord, List<ProcessResult>>{
        FakeInvocationRecord(
          <String>['flutter', 'devices', '--machine'],
          temporaryDirectory.path,
        ): <ProcessResult>[
          ProcessResult(0, 0, '[{"name": "linux", "id": "linux", "targetPlatform": "linux"}]', ''),
        ],
        FakeInvocationRecord(
          <String>['flutter', 'run', '--no-sound-null-safety', '-d', 'linux'],
          path.join(DiagramGenerator.projectDir, 'utils', 'diagram_generator'),
        ): <ProcessResult>[
          ProcessResult(0, 0, '', ''),
        ],
      };
      processManager.fakeResults = calls;
      await generator.generateDiagrams(<String>[], <String>[]);
      processManager.verifyCalls(calls.keys.toList());
    });
  });
}

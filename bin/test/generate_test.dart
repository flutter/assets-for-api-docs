// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:process_runner/process_runner.dart';
import 'package:test/test.dart';

import '../generate.dart';
import 'fake_process_manager.dart';

final String repoRoot = path.dirname(
  path.dirname(path.dirname(path.fromUri(Platform.script))),
);

void main() {
  group('DiagramGenerator', () {
    late DiagramGenerator generator;
    late Directory temporaryDirectory;
    late FakeProcessManager processManager;

    setUp(() {
      processManager = FakeProcessManager((String input) {});
      temporaryDirectory = Directory.systemTemp.createTempSync(
        'flutter_generate_test.',
      );
      generator = DiagramGenerator(
        processRunner: ProcessRunner(processManager: processManager),
        temporaryDirectory: temporaryDirectory,
        cleanup: false,
      );
    });

    tearDown(() {
      temporaryDirectory.delete(recursive: true);
    });

    try {
      test('make sure generate generates', () async {
        final Map<FakeInvocationRecord, List<ProcessResult>>
        calls = <FakeInvocationRecord, List<ProcessResult>>{
          FakeInvocationRecord(<String>[
            'flutter',
            'devices',
            '--machine',
          ], workingDirectory: temporaryDirectory.path): <ProcessResult>[
            ProcessResult(
              0,
              0,
              '[{"name": "linux", "id": "linux", "targetPlatform": "linux"}]',
              '',
            ),
          ],
          FakeInvocationRecord(
            <String>[
              'flutter',
              'run',
              '-d',
              'linux',
              '--dart-entrypoint-args',
              '--platform',
              '--dart-entrypoint-args',
              'linux',
              '--dart-entrypoint-args',
              '--output-dir',
              '--dart-entrypoint-args',
              temporaryDirectory.path,
            ],
            workingDirectory: path.join(
              DiagramGenerator.projectDir,
              'packages',
              'diagram_generator',
            ),
          ): <ProcessResult>[ProcessResult(0, 0, '', '')],
          FakeInvocationRecord(<String>[
            'optipng',
            '-zc1-9',
            '-zm1-9',
            '-zs0-3',
            '-f0-5',
            'output.png',
            '-out',
            path.join(DiagramGenerator.projectDir, 'assets', 'output.png'),
          ], workingDirectory: temporaryDirectory.path): <ProcessResult>[
            ProcessResult(0, 0, '', ''),
          ],
        };
        processManager.fakeResults = calls;
        // Fake an output file
        final File errorLog = File(
          path.join(temporaryDirectory.path, 'error.log'),
        );
        errorLog.writeAsString('');
        final File output = File(
          path.join(temporaryDirectory.path, 'output.png'),
        );
        output.writeAsString('');
        await generator.generateDiagrams();
        processManager.verifyCalls(calls.keys.toList());
      });
    } catch (e, s) {
      print(s);
    }
  });
}

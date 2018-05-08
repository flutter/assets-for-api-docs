// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';
import 'package:path/path.dart' as path;

import '../generate.dart';
import 'fake_process_manager.dart';

void main() {
  group('DiagramGenerator', () {
    DiagramGenerator generator;
    Directory temporaryDirectory;
    FakeProcessManager processManager;

    setUp(() {
      processManager = new FakeProcessManager();
      temporaryDirectory = Directory.systemTemp.createTempSync();
      generator = new DiagramGenerator(
        processRunner: new ProcessRunner(processManager: processManager),
        temporaryDirectory: temporaryDirectory,
        cleanup: false,
      );
    });
    test('make sure generate generates', () async {
      final String pathToMain = path.normalize(path.join(Directory.current.absolute.path, 'lib', 'main.dart'));

      final Map<String, List<ProcessResult>> calls = <String, List<ProcessResult>>{
        'flutter run $pathToMain': null,
        'adb exec-out run-as io.flutter.api.diagrams tar c -C app_flutter/diagrams .': null,
      };
      processManager.fakeResults = calls;
      await generator.generateDiagrams();
      processManager.verifyCalls(calls.keys.toList());
    });
  });
}

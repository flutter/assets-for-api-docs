// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../generate.dart';

class MockProcessRunner extends Mock implements Function {
  ProcessResult call(String executable, List<String> arguments,
      {String workingDirectory,
      Map<String, String> environment,
      bool includeParentEnvironment,
      bool runInShell,
      Encoding stdoutEncoding,
      Encoding stderrEncoding});
}

class MockProcessStarter extends Mock implements Function {
  Future<Process> call(String executable, List<String> arguments,
      {String workingDirectory,
      Map<String, String> environment,
      bool includeParentEnvironment,
      bool runInShell,
      ProcessStartMode mode});
}

class MockProcessResult extends Mock implements ProcessResult {
  @override
  dynamic stderr = '';

  @override
  dynamic stdout = '';
}

class MockProcess extends Mock implements Process {
  @override
  Stream<List<int>> stderr = new Stream<List<int>>.fromIterable(<List<int>>[<int>[1], <int>[2]]);
  @override
  Stream<List<int>> stdout = new Stream<List<int>>.fromIterable(<List<int>>[<int>[1], <int>[2]]);
}

void main() {
  group('GeneratorTests', () {
    DiagramGenerator generator;
    Directory temporaryDirectory;
    final MockProcessRunner runner = new MockProcessRunner();
    final MockProcessStarter starter = new MockProcessStarter();

    setUp(() {
      temporaryDirectory = Directory.systemTemp.createTempSync();
      when(
        runner.call(
          typed(captureAny),
          typed(captureAny),
          workingDirectory: typed(captureAny, named: 'workingDirectory'),
        ),
      ).thenReturn(new Future<MockProcessResult>.value(new MockProcessResult()));
      when(
        starter.call(
          typed(captureAny),
          typed(captureAny),
          workingDirectory: typed(captureAny, named: 'workingDirectory'),
        ),
      ).thenReturn(new Future<MockProcess>.value(new MockProcess()));
      generator = new DiagramGenerator(
        'dartFile.dart',
        part: '/route',
        processRunner: runner,
        processStarter: starter,
        temporaryDirectory: temporaryDirectory,
        cleanup: false,
      );
    });
    test('make sure generate generates', () {
      generator.generateDiagram();
    });
  });
}

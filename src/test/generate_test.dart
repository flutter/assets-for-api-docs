import "../generate.dart";
import "dart:io";
import 'package:test/test.dart';
import 'dart:async';
import 'dart:convert';
import 'package:mockito/mockito.dart';

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
  dynamic stderr = "";

  @override
  dynamic stdout = "";
}

class MockProcess extends Mock implements Process {
  @override
  Stream<List<int>> stderr = new Stream<List<int>>.fromIterable([[1],[2]]);
  @override
  Stream<List<int>> stdout = new Stream<List<int>>.fromIterable([[1],[2]]);
}

main() {
  group("GeneratorTests", () {
    DiagramGenerator generator;
    Directory tmpDir;
    MockProcessRunner runner = new MockProcessRunner();
    MockProcessStarter starter = new MockProcessStarter();

    setUp(() {
      tmpDir = Directory.systemTemp.createTempSync();
      when(
        runner.call(
          typed(captureAny),
          typed(captureAny),
          workingDirectory: typed(captureAny, named: "workingDirectory"),
        ),
      ).thenReturn(new Future<MockProcessResult>.value(new MockProcessResult()));
      when(
        starter.call(
          typed(captureAny),
          typed(captureAny),
          workingDirectory: typed(captureAny, named: "workingDirectory"),
        ),
      ).thenReturn(new Future<MockProcess>.value(new MockProcess()));
      generator = new DiagramGenerator('dartFile.dart', "/route",
          processRunner: runner, processStarter: starter, tmpDir: tmpDir, cleanup: false);
    });
    test('make sure generate generates', () {
      generator.generateDiagram();
    });
  });
}

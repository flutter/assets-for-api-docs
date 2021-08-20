// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process/process.dart';
import 'package:test/fake.dart';

class FakeProcess extends Fake implements Process {
  FakeProcess(int exitCode) {
    _stdinSink = IOSink(_stdinController.sink);
    exitCodeCompleter = Completer<int>();
    exitCodeCompleter.complete(exitCode);
    _stdoutController.close();
    _stderrController.close();
    _stdinController.close();
  }

  final StreamController<List<int>> _stdoutController =
      StreamController<List<int>>();
  final StreamController<List<int>> _stderrController =
      StreamController<List<int>>();
  final StreamController<List<int>> _stdinController =
      StreamController<List<int>>();
  late IOSink _stdinSink;
  late Completer<int> exitCodeCompleter;

  @override
  Stream<List<int>> get stdout => _stdoutController.stream;

  @override
  Stream<List<int>> get stderr => _stderrController.stream;

  @override
  IOSink get stdin => _stdinSink;

  @override
  int get pid => 1;

  @override
  Future<int> get exitCode => exitCodeCompleter.future;
}

class FakeProcessManager extends Fake implements ProcessManager {
  FakeProcessManager(
      {this.stdout = '', this.stderr = '', this.exitCode = 0, this.pid = 1});

  int runs = 0;
  List<List<String>> commands = <List<String>>[];
  String stdout;
  String stderr;
  int exitCode;
  int pid;

  @override
  Future<Process> start(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    ProcessStartMode mode = ProcessStartMode.normal,
  }) async {
    commands.add(
        command.map<String>((Object object) => object.toString()).toList());
    runs++;
    return FakeProcess(0);
  }

  @override
  ProcessResult runSync(
    List<Object> command, {
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
    Encoding stdoutEncoding = systemEncoding,
    Encoding stderrEncoding = systemEncoding,
  }) {
    commands.add(
        command.map<String>((Object object) => object.toString()).toList());
    runs++;
    return ProcessResult(pid, exitCode, stdout, stderr);
  }
}

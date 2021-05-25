// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:io' show ProcessResult;

import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:process_runner/process_runner.dart';
import 'package:snippets/snippets.dart';

void openFileBrowser(FileSystemEntity location,
    {Platform platform = const LocalPlatform(),
    ProcessManager processManager = const LocalProcessManager()}) {
  switch (platform.operatingSystem) {
    case 'linux':
      // Tries to open the system file manager using DBus and select the file.
      // Some file managers don't support selecting the file, but it will at
      // least open the directory that the file exists in.
      final ProcessRunner runner = ProcessRunner(processManager: processManager);
      runner.runProcess(<String>[
        'dbus-send',
        '--session',
        '--print-reply',
        '--dest=org.freedesktop.FileManager1',
        '/org/freedesktop/FileManager1',
        'org.freedesktop.FileManager1.ShowItems',
        'array:string:${location.absolute.path}',
        'string:""',
      ]).then((ProcessRunnerResult result) {
        if (result.exitCode != 0) {
          print('Failed to open file ${location.absolute.path}: ${result.output}');
        }
      });
      break;
    case 'macos':
      processManager.run(<String>['open', '-R', location.absolute.path]);
      break;
    case 'windows':
      processManager.run(<String>[
        'start',
        if (location is Directory) location.absolute.path else location.parent.absolute.path
      ], runInShell: true);
      break;
    default:
      throw Exception('Opening files on platform ${platform.operatingSystem} is not supported.');
  }
}

enum IdeType {
  idea,
  vscode,
}

String getIdeName(IdeType type) {
  switch (type) {
    case IdeType.idea:
      return 'IntelliJ';
    case IdeType.vscode:
      return 'VS Code';
  }
}

void openInIde(
  IdeType type,
  Directory location, {
  File? file,
  ProcessManager processManager = const LocalProcessManager(),
  Platform platform = const LocalPlatform(),
  int startLine = 0,
}) {
  switch (platform.operatingSystem) {
    case 'linux':
      switch (type) {
        case IdeType.idea:
          final List<String> cmd = <String>[
            'idea',
            location.absolute.path,
            if (file != null) '${file.absolute.path}:$startLine',
          ];
          processManager.run(cmd, runInShell: true);
          print('Launched ${cmd.join(' ')}');
          break;
        case IdeType.vscode:
          final List<String> cmd = <String>[
            'code',
            '-n',
            location.absolute.path,
            if (file != null) '--goto',
            if (file != null) '${file.absolute.path}:$startLine',
          ];
          processManager.run(cmd, runInShell: true);
          print('Launched ${cmd.join(' ')}');
          break;
      }
      break;
    case 'macos':
      switch (type) {
        case IdeType.idea:
          final ProcessResult result = processManager.runSync(<String>[
            'mdfind',
            'kMDItemCFBundleIdentifier=com.jetbrains.intellij* kind:application',
          ], stdoutEncoding: utf8);
          final Iterable<String> candidates =
              (result.stdout as String).split('\n').where((String candidate) {
            return !candidate.contains('/Application Support/');
          });
          final String appName = candidates.isNotEmpty ? candidates.first : 'IntelliJ IDEA CE';
          final List<String> command = <String>[
            'open',
            '-na',
            appName,
            '--args',
            file?.absolute.path ?? location.absolute.path,
            if (startLine != 0) '--line',
            if (startLine != 0) '$startLine',
          ];
          processManager
              .run(command, stdoutEncoding: utf8, stderrEncoding: utf8)
              .then((ProcessResult result) {
            if (result.exitCode != 0) {
              throw SnippetException(
                  'Unable to launch app $appName (${result.exitCode}): ${result.stderr}');
            }
          }).onError((Exception exception, StackTrace stackTrace) {
            throw SnippetException('Unable to launch app $appName: $exception');
          });
          break;
        case IdeType.vscode:
          final ProcessResult result = processManager.runSync(<String>[
            'mdfind',
            'kMDItemCFBundleIdentifier=com.microsoft.VSCode* kind:application',
          ], stdoutEncoding: utf8);
          final Iterable<String> candidates = (result.stdout as String).split('\n');
          final String appName = candidates.isNotEmpty ? candidates.first : 'Visual Studio Code';
          processManager.run(<String>[
            'open',
            '-na',
            appName,
            '--args',
            '-n',
            location.absolute.path,
            if (file != null) '--goto',
            if (file != null) '${file.absolute.path}:$startLine',
          ], stdoutEncoding: utf8, stderrEncoding: utf8).then((ProcessResult result) {
            if (result.exitCode != 0) {
              throw SnippetException(
                  'Unable to launch app $appName (${result.exitCode}): ${result.stderr}');
            }
          }).onError((Exception exception, StackTrace stackTrace) {
            throw SnippetException('Unable to launch app $appName: $exception');
          });
          break;
      }
      break;
    case 'windows':
      switch (type) {
        case IdeType.idea:
          processManager.run(<String>[
            'idea64.exe',
            location.absolute.path,
            if (file != null) '${file.absolute.path}:$startLine',
          ]);
          break;
        case IdeType.vscode:
          processManager.run(<String>[
            'code',
            '-n',
            location.absolute.path,
            if (file != null) '--goto',
            if (file != null) '${file.absolute.path}:$startLine',
          ]);
          break;
      }
      break;
  }
}

TextSpan codeTextSpan(BuildContext context, String text) {
  return TextSpan(
    text: text,
    style: Theme.of(context).textTheme.bodyText1!.copyWith(
      fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! + 2,
      color: Colors.indigo,
      fontFamily: 'Fira Code',
      fontFamilyFallback: <String>[
        'Courier New',
        'Lucidia Console',
        'mono',
      ],
    ),
  );
}

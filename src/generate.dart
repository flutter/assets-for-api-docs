import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

/// The type of the process runner callback.  This allows us to
/// inject a fake process runner into the DiagramGenerator for tests.
typedef ProcessResult ProcessRunner(
  String executable,
  List<String> arguments, {
  String workingDirectory,
  Map<String, String> environment,
  bool includeParentEnvironment,
  bool runInShell,
  Encoding stdoutEncoding,
  Encoding stderrEncoding,
});

/// The type of the process starter callback. This allows us to
/// inject a fake process starter into the DiagramGenerator for tests.
typedef Future<Process> ProcessStarter(
  String executable,
  List<String> arguments, {
  String workingDirectory,
  Map<String, String> environment,
  bool includeParentEnvironment,
  bool runInShell,
  ProcessStartMode mode,
});

typedef Future<Null> AsyncCallback();

/// Generates diagrams from dart programs for use in the online documentation.
///
/// Runs a dart program in the background, waits for it to indicate that it is
/// done by printing "DONE DRAWING", and then captures the display and chops it
/// up according to the shell commands output by the application.
class DiagramGenerator {
  DiagramGenerator(String dartFile, {
    String part,
    this.processRunner = Process.runSync,
    this.processStarter = Process.start,
    this.temporaryDirectory,
    this.cleanup = true,
  }) : _initialRoute = part,
       _dartPath = path.join(projectDir, dartFile),
       _diagramType = path.split(path.dirname(dartFile)).last,
       _name = path.basenameWithoutExtension(dartFile) {
    temporaryDirectory ??= Directory.systemTemp.createTempSync('api_generate_');
    print('Dart path: $_dartPath');
    if (_initialRoute != null)
      print('Initial route: $_initialRoute');
    print('Diagram type: $_diagramType');
    print('Name: $_name');
    print('Temp directory: ${temporaryDirectory.path}');
  }

  static const String flutterCommand = 'flutter';
  static const String optiPngCommand = 'optipng';

  /// Whether or not to cleanup the temporaryDirectory after generating diagrams.
  final bool cleanup;

  /// The function used to run processes to completion.
  final ProcessRunner processRunner;

  /// The function used to start processes and create a Process object.
  final ProcessStarter processStarter;

  /// The path to the dart program to be run for generating the diagram.
  final String _dartPath;

  /// The type of diagram this is, e.g. 'material' or 'animation'
  final String _diagramType;

  /// The initial route to invoke in the dart program, if any. May be null.
  final String _initialRoute;

  /// The name of this diagram, used for filenames, e.g. 'card' or 'curve'.
  /// Cropped out images will all begin with this name.
  final String _name;

  /// The temporary directory used to write screenshots and cropped out images
  /// into.
  Directory temporaryDirectory;

  static String get projectDir {
    return path.joinAll(path.split(path.fromUri(Platform.script))..removeLast());
  }

  Future<Null> generateDiagram() async {
    await _collectScreenshot();
    await _optimizeImages();
    if (cleanup) {
      await temporaryDirectory.delete(recursive: true);
    }
  }

  static const Duration timeout = const Duration(seconds: 60);

  Future<List<String>> runFlutter({
    @required List<String> args,
    @required String until,
    AsyncCallback then,
  }) async {
    final Process process = await processStarter(flutterCommand, args, workingDirectory: projectDir);
    final List<String> lines = <String>[];
    process.stdout.transform(UTF8.decoder).transform(const LineSplitter()).listen((String data) {
      lines.add(data);
    });
    process.stderr.transform(UTF8.decoder).transform(const LineSplitter()).listen((String data) {
      lines.add(data);
    });
    final DateTime startWait = new DateTime.now();
    while (!lines.any((String line) => line.contains(until))) {
      if (new DateTime.now().difference(startWait) > timeout) {
        stdout.write('\n');
        print('Timed out.');
        print('Output from application:');
        lines.forEach(print);
        exit(1);
      }
      stdout.write('\rRunning (${new DateTime.now().difference(startWait).inSeconds} seconds)....');
      await new Future<Null>.delayed(const Duration(seconds: 1));
    }
    stdout.write('\n');
    if (then != null)
      await then();
    process.kill();
    return lines;
  }

  Future<List<String>> collectRoutes() async {
    print('Collecting routes from: $_dartPath');
    final List<String> lines = await runFlutter(
      args: <String>['run', '--route=list', _dartPath],
      until: 'END',
    );
    final List<String> routes = <String>[];
    final RegExp routePattern = new RegExp(r'^I/flutter.*ROUTE: (.*)');
    for (String line in lines) {
      final Match match = routePattern.matchAsPrefix(line);
      if (match != null)
        routes.add(match.group(1));
    }
    return routes;
  }

  Future<Null> _collectScreenshot() async {
    print('Collecting image from: $_dartPath');
    // This is run in the background and later killed because running with
    // --no-resident doesn't keep producing stdout long enough before it exits
    // to write the process script for generators that rely on waiting for
    // animations to complete.
    final List<String> args = _initialRoute == null
        ? <String>['run', _dartPath]
        : <String>['run', '--route=$_initialRoute', _dartPath];
    final List<String> lines = await runFlutter(
      args: args,
      until: 'DONE DRAWING',
      then: () async {
        // Wait one more second once we see DONE DRAWING so that things have a
        // chance to calm down.
        await new Future<Null>.delayed(const Duration(seconds: 1));
        if (!_captureScreenshot(path.join(temporaryDirectory.path, 'flutter_01.png'))) {
          print('Failed to get shot.');
          exit(1);
        }
      },
    );
    _processScreenshot(lines);
  }

  bool _captureScreenshot(String outputName) {
    print('Capturing screenshot into: $outputName');
    final ProcessResult processResult = processRunner(
      flutterCommand,
      <String>['screenshot', '--out=$outputName'],
      workingDirectory: projectDir,
    );
    if (processResult.exitCode != 0) {
      print("Failed to run command '$flutterCommand screenshot --out=$outputName' in ${temporaryDirectory.path}:\n${processResult.stderr}");
      exit(1);
    }
    return true;
  }

  Future<Null> _processScreenshot(List<String> appOutput) async {
    final List<String> commands = <String>[];
    final RegExp commandPattern = new RegExp(r'^I/flutter.*COMMAND: (.*)');
    for (String data in appOutput) {
      final Match match = commandPattern.matchAsPrefix(data);
      if (match != null)
        commands.add(match.group(1));
    }
    if (commands.isNotEmpty) {
      for (String command in commands) {
        // Split command into args and get rid of any quotes around arguments,
        // since we don't need those here, but someone copy/pasting would.
        final List<String> commandArgs = command.split(' ').map((String arg) {
          final RegExp quoteRe = new RegExp(r'''['\"](.*)['\"]''');
          return quoteRe.firstMatch(arg)?.group(1) ?? arg;
        }).toList();
        final ProcessResult processResult = processRunner(
          commandArgs[0],
          commandArgs.sublist(1),
          workingDirectory: temporaryDirectory.path,
        );
        if (processResult.exitCode != 0) {
          print("Failed to run command '$command' in ${temporaryDirectory.path}:\n${processResult.stderr}");
          exit(1);
        }
      }
    } else {
      print('Unable to find any commands in the output of the generator.');
    }
  }

  Future<Null> _optimizeImages() async {
    final Directory destDir = new Directory(path.joinAll(path.split(projectDir)
      ..removeLast()
      ..add(_diagramType)));
    final List<String> images = (await temporaryDirectory.list().toList()).map((FileSystemEntity e) => e.path).toList();
    for (String imagePath in images) {
      final FileSystemEntityType type = FileSystemEntity.typeSync(imagePath);
      if (type == FileSystemEntityType.FILE &&
          path.extension(imagePath) == '.png' &&
          path.basename(imagePath).toLowerCase().startsWith(_name)) {
        final File destination = new File(path.join(destDir.path, path.basename(imagePath)));
        if (destination.existsSync())
          destination.deleteSync();
        print('Optimizing PNG file...');
        final ProcessResult processResult = processRunner(
          optiPngCommand,
          <String>['-zc1-9', '-zm1-9', '-zs0-3', '-f0-5', imagePath, '-out', destination.path],
          workingDirectory: temporaryDirectory.path,
        );
        if (processResult.exitCode != 0) {
          print('Failed to optimize $imagePath:\n${processResult.stderr}');
          exit(1);
        } else {
          print('Saved to: ${destination.path}');
        }
      }
    }
  }
}

Future<Null> main(List<String> arguments) async {
  const List<String> horizontalDiagrams = const <String>[
    'material/app_bar.dart',
  ];

  const List<String> verticalDiagrams = const <String>[
    'animation/curve.dart',
    'dart-ui/tile_mode.dart',
    'material/card.dart',
    'material/colors.dart@',
    'material/ink_response_large.dart',
    'material/ink_response_small.dart',
    'material/ink_well.dart',
    'painting/box_fit.dart',
  ];

  final ArgParser parser = new ArgParser();
  parser.addFlag(
    'horizontal',
    help: 'Select all of the "horizontal" aspect generators to be run.',
  );
  parser.addFlag(
    'vertical',
    help: 'Select all of the "vertical" aspect generators to be run.',
  );
  parser.addFlag('help', help: 'Print help.');
  parser.addFlag('keep-tmp', help: "Don't cleanup after a run (don't remove temporary directory).");
  final ArgResults flags = parser.parse(arguments);

  if (flags['help']) {
    print('generate.dart [flags] [files...]');
    print(parser.usage);
    print('If the file supports listing routes, append its name with an "@", as in "material/colors.dart@".');
    print('If no files are specified, then --horizontal and --vertical are implied.');
    exit(0);
  }

  final List<String> diagrams = <String>[];
  if (flags['horizontal'])
    diagrams.addAll(horizontalDiagrams);
  if (flags['vertical'])
    diagrams.addAll(verticalDiagrams);
  diagrams.addAll(flags.rest);

  if (diagrams.isEmpty) {
    diagrams.addAll(horizontalDiagrams);
    diagrams.addAll(verticalDiagrams);
  }

  for (String diagram in diagrams) {
    List<String> parts;
    String app;
    if (diagram.endsWith('@')) {
      app = diagram.substring(0, diagram.length - 1);
      parts = await new DiagramGenerator(app).collectRoutes();
    } else {
      app = diagram;
      parts = <String>[null];
    }
    for (String part in parts) {
      await new DiagramGenerator(app, part: part, cleanup: !flags['keep-tmp']).generateDiagram();
    }
    print('Finished $diagram\n');
  }
  exit(0);
}
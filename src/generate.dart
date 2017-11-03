import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

/// The type of the process runner callback.  This allows us to
/// inject a fake process runner into the DiagramGenerator for tests.
typedef Future<ProcessResult> ProcessRunner(String executable, List<String> arguments,
    {String workingDirectory,
    Map<String, String> environment,
    bool includeParentEnvironment,
    bool runInShell,
    Encoding stdoutEncoding,
    Encoding stderrEncoding});

/// The type of the process starter callback.  This allows us to
/// inject a fake process starter into the DiagramGenerator for tests.
typedef Future<Process> ProcessStarter(String executable, List<String> arguments,
    {String workingDirectory,
    Map<String, String> environment,
    bool includeParentEnvironment,
    bool runInShell,
    ProcessStartMode mode});

/// Generates diagrams from dart programs for use in the online documentation.
///
/// Runs a dart program in the background, waits for it to indicate that it is done by
/// printing "DONE DRAWING", and then captures the display and chops it up according to
/// the shell commands output by the application.
class DiagramGenerator {
  DiagramGenerator(String dartFile, this._initialRoute,
      {this.processRunner = Process.run,
      this.processStarter = Process.start,
      this.tmpDir,
      this.cleanup = true})
      : _dartPath = path.join(projectDir, dartFile),
        _diagramType = path.split(path.dirname(dartFile)).last,
        _name = path.basenameWithoutExtension(dartFile) {
    tmpDir ??= Directory.systemTemp.createTempSync();
    print("Dart Path: ${_dartPath}");
    print("Initial Route: ${_initialRoute}");
    print("Diagram Type: ${_diagramType}");
    print("Name: ${_name}");
    print("Temp Dir: ${tmpDir}");
  }

  static const String kFlutterCommand = 'flutter';
  static const String kOptiPngCommand = 'optipng';

  /// Whether or not to cleanup the tmpDir after generating diagrams.
  final bool cleanup;

  /// The function used to run processes to completion.
  final ProcessRunner processRunner;

  /// The function used to start processes and create a Process object.
  final ProcessStarter processStarter;

  /// The path to the dart program to be run for generating the diagram.
  final String _dartPath;

  /// The type of diagram this is, e.g. 'material' or 'animation'
  final String _diagramType;

  /// The initial route to invoke in the dart program, if any.  May be null.
  final String _initialRoute;

  /// The name of this diagram, used for filenames, e.g. 'card' or 'curve'.  Cropped out
  /// images will all begin with this name.
  final String _name;

  /// The temporary directory used to write screenshots and cropped out images into.
  Directory tmpDir;

  static String get projectDir =>
      path.joinAll(path.split(path.fromUri(Platform.script))..removeLast());

  Future<Null> generateDiagram() async {
    await _collectScreenshot();
    await _optimizeImages();
    if (cleanup) {
      await tmpDir.delete(recursive: true);
    }
  }

  Future<ProcessResult> _captureScreenshot(String outputName) async {
    print('Capturing screenshot into ${outputName}.');
    return processRunner(kFlutterCommand, ['screenshot', '--out=${outputName}'],
        workingDirectory: projectDir);
  }

  Future<Null> _collectScreenshot() async {
    print("Collecting Image from ${_dartPath}.");

    // This is run in the background and later killed because running with
    // --no-resident doesn't keep producing stdout long enough before it exits
    // to write the process script for generators that rely on waiting for
    // animations to complete.
    List<String> args = _initialRoute == null
        ? ['run', _dartPath]
        : ['run', '--route=${_initialRoute}', _dartPath];
    print("Running app ${_dartPath}.");
    Process process =
        await processStarter(kFlutterCommand, args, workingDirectory: projectDir);
    List<String> lines = [];
    process.stderr.transform(UTF8.decoder).listen((data) {
      stderr.write(data);
    });
    process.stdout.transform(UTF8.decoder).listen((data) {
      stdout.write(data);
      lines.add(data);
    });
    DateTime startWait = new DateTime.now();
    while (!lines.join('').contains("DONE DRAWING") &&
        (new DateTime.now().difference(startWait) < new Duration(seconds: 60))) {
      print("\rRunning (${new DateTime.now().difference(startWait).inSeconds} seconds).");
      await new Future.delayed(new Duration(seconds: 1));
    }

    // Wait one more second once we see DONE DRAWING so that things have a chance to calm
    // down.
    await new Future.delayed(new Duration(seconds: 1));
    print("Capturing screenshot.");
    await _captureScreenshot(path.join(tmpDir.path, 'flutter_01.png'));
    process.kill();

    // Have to join/re-split lines because the stream data comes in chunks that
    // aren't necessarily lines.
    _processScreenshot(lines.join('').split('\n'));
  }

  Future<Null> _processScreenshot(List<String> appOutput) async {
    List<String> commands = [];

    for (String data in appOutput) {
      RegExp cmdRe = new RegExp(r'^I/flutter.*COMMAND: (.*)');
      Match match = cmdRe.matchAsPrefix(data.trim());
      if (match != null) {
        commands.add(match.group(1));
      }
    }

    if (commands.isNotEmpty) {
      for (String command in commands) {
        // Split command into args and get rid of any quotes around arguments,
        // since we don't need those here, but someone copy/pasting would.
        List<String> commandArgs = command.split(' ').map((String arg) {
          final quoteRe = new RegExp(r'''['\"](.*)['\"]''');
          return quoteRe.firstMatch(arg)?.group(1) ?? arg;
        }).toList();
        Process process = await Process.start(commandArgs[0], commandArgs.sublist(1),
            workingDirectory: tmpDir.path);
        stdout.addStream(process.stdout);
        stderr.addStream(process.stderr);
        if (await process.exitCode != 0) {
          print("Failed to run command ${commandArgs}.");
        }
      }
    } else {
      print("Unable to find any commands in the output of the generator.");
    }
  }

  Future<Null> _optimizeImages() async {
    Directory destDir = new Directory(path.joinAll(path.split(projectDir)
      ..removeLast()
      ..add(_diagramType)));
    List<String> images =
        (await tmpDir.list().toList()).map((FileSystemEntity e) => e.path);
    for (String imagePath in images) {
      FileSystemEntityType type = await FileSystemEntity.type(imagePath);
      if (type == FileSystemEntityType.FILE &&
          path.extension(imagePath) == '.png' &&
          path.basename(imagePath).toLowerCase().startsWith(_name)) {
        File destination = new File(path.join(destDir.path, path.basename(imagePath)));
        if (await destination.exists()) await destination.delete();
        print("Optimizing PNG file ${imagePath} into ${destination.path}");
        Process process = await Process.start(kOptiPngCommand,
            ['-zc1-9', '-zm1-9', '-zs0-3', '-f0-5', imagePath, '-out', destination.path],
            workingDirectory: tmpDir.path);
        stdout.addStream(process.stdout);
        stderr.addStream(process.stderr);
        if (await process.exitCode != 0)
          print("Failed to convert ${imagePath}.");
        else
          print("Converted ${imagePath}");
      }
    }
  }
}

Future<Null> main(List<String> arguments) async {
  const horizontalDiagrams = const [
    'material/app_bar.dart',
    'material/card.dart',
    'material/ink_response_large.dart',
    'material/ink_response_small.dart',
    'material/ink_well.dart',
  ];

  const verticalDiagrams = const [
    'animation/curve.dart',
    'dart-ui/tile_mode.dart',
    'painting/box_fit.dart',
    'material/colors.dart@Colors.red',
    'material/colors.dart@Colors.pink',
    'material/colors.dart@Colors.purple',
    'material/colors.dart@Colors.deepPurple',
    'material/colors.dart@Colors.indigo',
    'material/colors.dart@Colors.blue',
    'material/colors.dart@Colors.lightBlue',
    'material/colors.dart@Colors.cyan',
    'material/colors.dart@Colors.teal',
    'material/colors.dart@Colors.green',
    'material/colors.dart@Colors.lightGreen',
    'material/colors.dart@Colors.lime',
    'material/colors.dart@Colors.yellow',
    'material/colors.dart@Colors.amber',
    'material/colors.dart@Colors.orange',
    'material/colors.dart@Colors.deepOrange',
    'material/colors.dart@Colors.brown',
    'material/colors.dart@Colors.blueGrey',
    'material/colors.dart@Colors.redAccent',
    'material/colors.dart@Colors.pinkAccent',
    'material/colors.dart@Colors.purpleAccent',
    'material/colors.dart@Colors.deepPurpleAccent',
    'material/colors.dart@Colors.indigoAccent',
    'material/colors.dart@Colors.blueAccent',
    'material/colors.dart@Colors.lightBlueAccent',
    'material/colors.dart@Colors.cyanAccent',
    'material/colors.dart@Colors.tealAccent',
    'material/colors.dart@Colors.greenAccent',
    'material/colors.dart@Colors.lightGreenAccent',
    'material/colors.dart@Colors.limeAccent',
    'material/colors.dart@Colors.yellowAccent',
    'material/colors.dart@Colors.amberAccent',
    'material/colors.dart@Colors.orangeAccent',
    'material/colors.dart@Colors.deepOrangeAccent',
    'material/colors.dart@Colors.grey',
    'material/colors.dart@Colors.blacks',
    'material/colors.dart@Colors.whites',
  ];

  ArgParser parser = new ArgParser();
  parser.addFlag('horizontal',
      help: 'Select all of the "horizontal" aspect generators to be run.');
  parser.addFlag('vertical',
      help: 'Select all of the "vertical" aspect generators to be run.');
  parser.addFlag('help', help: 'Print help.');
  parser.addFlag('keep_tmp', help: "Don't cleanup after a run (don't remove tmpdir).");
  ArgResults flags = parser.parse(arguments);

  if (flags['help']) {
    print(parser.usage);
    exit(0);
  }

  List<String> diagrams = [];
  if (flags['horizontal'])
    diagrams = horizontalDiagrams;
  else if (flags['vertical'])
    diagrams = verticalDiagrams;
  else
    diagrams = flags.rest;

  if (diagrams.isEmpty) {
    print(parser.usage);
    exit(-1);
  }

  for (String diagram in diagrams) {
    List<String> parts = diagram.split('@');
    String app = parts[0];
    String route = parts.length > 1 ? parts[1] : null;
    DiagramGenerator generator = new DiagramGenerator(app, route, cleanup: !flags['keep_tmp']);
    await generator.generateDiagram();
    print("Finished ${diagram}");
  }

  exit(0);
}

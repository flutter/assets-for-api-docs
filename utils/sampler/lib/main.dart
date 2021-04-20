import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sampler/new_sample.dart';
import 'package:snippets/snippets.dart';

import 'detail_view.dart';
import 'helper_widgets.dart';
import 'model.dart';
import 'new_sample.dart';
import 'utils.dart';

const String _kFileOption = 'file';
const String _kFlutterRootOption = 'flutter-root';
const String _kDartUiRootOption = 'dart-ui-root';

const String kNewSampleSelectView = '/newSampleSelectView';
const String kDetailView = '/detailView';
const String kNewSampleView = '/newSampleView';

void main(List<String> argv) {
  final ArgParser parser = ArgParser();
  parser.addOption(_kFileOption, help: 'Specifies the file to edit samples in.');
  parser.addOption(_kFlutterRootOption,
      help: 'Specifies the location of the Flutter root directory.');
  parser.addOption(_kDartUiRootOption,
      help: 'Specifies the location of the dart:ui source directory.');
  final ArgResults args = parser.parse(argv);

  const FileSystem filesystem = LocalFileSystem();

  Directory? flutterRoot;
  if (args.wasParsed(_kFlutterRootOption)) {
    flutterRoot = filesystem.directory(args[_kFlutterRootOption]! as String);
  }
  if (flutterRoot != null && !flutterRoot.existsSync()) {
    io.stderr.writeln('Supplied --$_kFlutterRootOption directory '
        '${args[_kFlutterRootOption]!} does not exist.');
    io.exit(-1);
  }

  Directory? dartUiRoot;
  if (args.wasParsed(_kDartUiRootOption)) {
    dartUiRoot = filesystem.directory(args[_kDartUiRootOption]! as String);
  }
  if (dartUiRoot != null && !dartUiRoot.existsSync()) {
    io.stderr.writeln('Supplied --$_kDartUiRootOption directory '
        '${args[_kDartUiRootOption]!} does not exist.');
    io.exit(-1);
  }

  File? workingFile;
  if (args.wasParsed(_kFileOption)) {
    workingFile = filesystem.file(args[_kFileOption]);
  }

  Model.instance = Model(
    workingFile: workingFile,
    flutterRoot: flutterRoot,
    filesystem: filesystem,
    dartUiRoot: dartUiRoot,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  static const String _title = 'Sampler';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      routes: <String, WidgetBuilder>{
        kDetailView: (BuildContext context) => const DetailView(),
        kNewSampleSelectView: (BuildContext context) =>
            const NewSampleSelect(title: 'Add a Sample'),
      },
      home: const Sampler(title: _title),
    );
  }
}

class Sampler extends StatefulWidget {
  const Sampler({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _SamplerState createState() => _SamplerState();
}

class _SamplerState extends State<Sampler> {
  bool get filesLoading => Model.instance.files == null;
  int expandedIndex = -1;
  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (Model.instance.workingFile == null) {
      Model.instance.collectFiles(
        <Directory>[
          Model.instance.flutterPackageRoot,
          Model.instance.dartUiRoot,
        ],
      );
    }
    Model.instance.addListener(_modelUpdated);
    editingController.addListener(_editingControllerChanged);
  }

  @override
  void dispose() {
    Model.instance.removeListener(_modelUpdated);
    editingController.dispose();
    super.dispose();
  }

  void _editingControllerChanged() {
    if (Model.instance.files == null) {
      return;
    }
    if (editingController.text.isEmpty ||
        !Model.instance.files!.contains(Model.instance.filesystem.file(editingController.text))) {
      Model.instance.clearWorkingFile();
    }
  }

  ExpansionPanel _createExpansionPanel(CodeSample sample, {bool isExpanded = false}) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: '${sample.type == 'dartpad' ? 'dartpad sample' : sample.type} for '),
                codeTextSpan(context, sample.start.element!),
                TextSpan(
                    text: '${sample.index != 0 ? '(${sample.index})' : ''} '
                        'at line ${sample.start.line}'),
              ],
            ),
          ),
          trailing: TextButton(
            child: const Text('SELECT'),
            onPressed: () {
              Model.instance.currentElement = Model.instance.getElementForSample(sample);
              Model.instance.currentSample = sample;
              Navigator.of(context).pushNamed(kDetailView).then((Object? result) {
                Model.instance.currentSample = null;
                Model.instance.currentElement = null;
              });
            },
          ),
        );
      },
      body: ListTile(
        title: CodePanel(code: sample.inputAsString),
      ),
      isExpanded: isExpanded,
    );
  }

  void _modelUpdated() {
    setState(() {
      // model updated, so force widget update.
    });
  }

  Iterable<File> _fileOptions(TextEditingValue value) {
    if (value.text.isEmpty || Model.instance.files == null) {
      return const Iterable<File>.empty();
    }
    if (value.text.contains(path.separator)) {
      return Model.instance.files!
          .where((File file) => file.path.toLowerCase().contains(value.text.toLowerCase()));
    }
    return Model.instance.files!
        .where((File file) => file.basename.toLowerCase().contains(value.text.toLowerCase()));
  }

  Widget _buildFileField(BuildContext context, TextEditingController textEditingController,
      FocusNode focusNode, VoidCallback onFieldSubmitted) {
    return AutocompleteField(
      focusNode: focusNode,
      textEditingController: textEditingController,
      onFieldSubmitted: onFieldSubmitted,
      hintText: 'Enter the name of a framework source file',
      trailing: textEditingController.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.highlight_remove),
              onPressed: () {
                setState(
                  () {
                    Model.instance.clearWorkingFile();
                    textEditingController.clear();
                    expandedIndex = -1;
                  },
                );
              },
            )
          : null,
    );
  }

  String _getSampleStats() {
    if (Model.instance.samples.isEmpty) {
      return 'No samples loaded.';
    }
    final int snippets = Model.instance.samples.whereType<SnippetSample>().length;
    final int applications = Model.instance.samples
        .where((CodeSample sample) => sample is ApplicationSample && sample is! DartpadSample)
        .length;
    final int dartpads = Model.instance.samples.whereType<DartpadSample>().length;
    final int total = snippets + applications + dartpads;
    final bool allOneKind = total == snippets || total == applications || total == dartpads;
    return <String>[
      if (!allOneKind)
        '${Model.instance.samples.length} sample${Model.instance.samples.length != 1 ? 's' : ''} total',
      if (snippets > 0) '$snippets snippet${snippets != 1 ? 's' : ''}',
      if (applications > 0) '$applications application sample${applications != 1 ? 's' : ''}',
      if (dartpads > 0) '$dartpads dartpad sample${dartpads != 1 ? 's' : ''}'
    ].join(', ');
  }

  @override
  Widget build(BuildContext context) {
    List<ExpansionPanel> panels = const <ExpansionPanel>[];
    Iterable<CodeSample> samples = const <CodeSample>[];
    if (Model.instance.currentSample == null) {
      samples = Model.instance.samples;
    } else {
      samples = <CodeSample>[Model.instance.currentSample!];
    }
    int index = 0;
    panels = samples.map<ExpansionPanel>(
      (CodeSample sample) {
        final ExpansionPanel result =
            _createExpansionPanel(sample, isExpanded: index == expandedIndex);
        index++;
        return result;
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: Model.instance.workingFile != null
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              tooltip: 'Add a new sample to ${Model.instance.workingFile!.basename}',
              onPressed: () {
                Model.instance.currentElement = null;
                Model.instance.currentSample = null;
                Navigator.of(context).pushNamed(kNewSampleSelectView).then((Object? result) {
                  Model.instance.currentElement = null;
                  Model.instance.currentSample = null;
                });
              },
            )
          : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (filesLoading) const CircularProgressIndicator.adaptive(value: null),
              ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsetsDirectional.only(end: 8.0),
                          child: Text('Framework File:',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                            child: Autocomplete<File>(
                          fieldViewBuilder: _buildFileField,
                          optionsBuilder: _fileOptions,
                          displayStringForOption: (File file) {
                            if (path.isWithin(
                                Model.instance.flutterRoot.path, file.absolute.path)) {
                              return path.relative(file.absolute.path,
                                  from: Model.instance.flutterRoot.absolute.path);
                            } else {
                              return file.absolute.path;
                            }
                          },
                          onSelected: (File file) {
                            expandedIndex = -1;
                            Model.instance
                                .setWorkingFile(file)
                                .onError((Exception e, StackTrace trace) {
                              if (e is! SnippetException) {
                                throw e;
                              }
                              final ScaffoldMessengerState? scaffold =
                                  ScaffoldMessenger.maybeOf(context);
                              scaffold?.showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 10),
                                  content: Text(e.toString()),
                                ),
                              );
                            });
                          },
                        )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.all(8.0),
                    child: Text(_getSampleStats(),
                        textAlign: TextAlign.center, style: Theme.of(context).textTheme.caption),
                  ),
                  ExpansionPanelList(
                    children: panels,
                    expansionCallback: (int index, bool expanded) {
                      setState(() {
                        expandedIndex = expanded ? -1 : index;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

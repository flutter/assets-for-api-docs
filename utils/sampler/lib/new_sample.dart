// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sampler/utils.dart';
import 'package:snippets/snippets.dart';

import 'helper_widgets.dart';
import 'main.dart';
import 'model.dart';

typedef _OptionDialogSubmitted = void Function(Type sampleType, String? template);

class OptionDialog extends StatefulWidget {
  const OptionDialog({Key? key, required this.onSubmitted}) : super(key: key);

  final _OptionDialogSubmitted onSubmitted;

  @override
  _OptionDialogState createState() => _OptionDialogState();
}

class _OptionDialogState extends State<OptionDialog> {
  String? selectedSampleType;
  String? selectedTemplate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Sample Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('Sample Type:'),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedSampleType,
                  onChanged: (String? value) {
                    setState(() {
                      selectedSampleType = value;
                    });
                  },
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(child: Text('dartpad'), value: 'dartpad'),
                    DropdownMenuItem<String>(child: Text('sample'), value: 'sample'),
                    DropdownMenuItem<String>(child: Text('snippet'), value: 'snippet'),
                  ],
                ),
              ),
            ],
          ),
          if (selectedSampleType == 'sample' || selectedSampleType == 'dartpad')
            Row(
              children: <Widget>[
                const Text('Template:'),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: selectedTemplate,
                    onChanged: (String? value) {
                      setState(() {
                        selectedTemplate = value;
                      });
                    },
                    items: Model.instance
                        .getTemplateNames()
                        .map<DropdownMenuItem<String>>((String name) {
                      return DropdownMenuItem<String>(child: Text(name), value: name);
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: selectedSampleType != null &&
                  (selectedTemplate != null || selectedSampleType == 'snippet')
              ? () async {
                  Type sampleType;
                  switch (selectedSampleType!) {
                    case 'dartpad':
                      sampleType = DartpadSample;
                      break;
                    case 'sample':
                      sampleType = ApplicationSample;
                      break;
                    case 'snippet':
                      sampleType = SnippetSample;
                      break;
                    default:
                      throw SnippetException('Encountered unknown sample type $selectedSampleType');
                  }
                  widget.onSubmitted(sampleType, selectedTemplate);
                }
              : null,
        ),
      ],
    );
  }
}

class NewSampleSelect extends StatefulWidget {
  const NewSampleSelect({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _NewSampleSelectState createState() => _NewSampleSelectState();
}

class _NewSampleSelectState extends State<NewSampleSelect> {
  bool get filesLoading => Model.instance.files == null;
  int expandedIndex = -1;
  TextEditingController editingController = TextEditingController();

  DialogRoute<void> _createOptionDialog(BuildContext context, SourceElement element) {
    return DialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return OptionDialog(onSubmitted: (Type sampleType, String? template) async {
          Model.instance.currentElement = element;
          await Model.instance.insertNewSample(sampleType: sampleType, template: template);
          Navigator.of(context).popAndPushNamed(kDetailView).then((Object? result) {
            // Clear the current element when returning from the detail view.
            Model.instance.currentElement = null;
          });
        });
      },
    );
  }

  ExpansionPanel _createExpansionPanel(SourceElement element, {bool isExpanded = false}) {
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          title: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: '${element.typeAsString} '),
                codeTextSpan(context, element.elementName),
                TextSpan(text: ' at line ${element.startLine}'),
              ],
            ),
          ),
          subtitle: Text('has ${element.samples.length} existing ${element.samples.length == 1 ? 'sample' : 'samples'}'),
          trailing: TextButton(
            child: const Text('ADD SAMPLE'),
            onPressed: () async {
              Navigator.of(context).push<void>(_createOptionDialog(context, element));
            },
          ),
        );
      },
      body: element.comment.isNotEmpty
          ? ListTile(
              title: CodePanel(
                code: element.comment.map<String>((SourceLine line) => line.text).join('\n'),
              ),
            )
          : const SizedBox(),
      isExpanded: isExpanded,
    );
  }

  @override
  void initState() {
    super.initState();
    if (Model.instance.workingFile == null) {
      Model.instance.listFiles(Model.instance.flutterPackageRoot).then((void _) {
        setState(() {});
      });
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

  void _modelUpdated() {
    setState(() {
      // model updated, so force widget update.
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ExpansionPanel> panels = const <ExpansionPanel>[];
    Iterable<SourceElement> elements = const <SourceElement>[];
    if (Model.instance.currentElement == null) {
      elements = Model.instance.elements!;
    } else {
      elements = <SourceElement>[Model.instance.currentElement!];
    }
    int index = 0;
    panels = elements.map<ExpansionPanel>(
      (SourceElement element) {
        final ExpansionPanel result =
            _createExpansionPanel(element, isExpanded: index == expandedIndex);
        index++;
        return result;
      },
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (filesLoading) const CircularProgressIndicator.adaptive(value: null),
              ListView(
                children: <Widget>[
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

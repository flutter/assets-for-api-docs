// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:snippets/snippets.dart';

import 'model.dart';

typedef OptionDialogSubmitted = void Function(
    Type sampleType, String? template);

/// A modal dialog that allows selection of parameters for the new sample.
class OptionDialog extends StatefulWidget {
  const OptionDialog({Key? key, required this.onSubmitted}) : super(key: key);

  final OptionDialogSubmitted onSubmitted;

  @override
  State<OptionDialog> createState() => _OptionDialogState();
}

class _OptionDialogState extends State<OptionDialog> {
  String? selectedSampleType;
  String? selectedTemplate;

  bool get okEnabled =>
      selectedSampleType != null &&
      (selectedTemplate != null || selectedSampleType == 'snippet');

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
                    DropdownMenuItem<String>(
                        child: Text('dartpad'), value: 'dartpad'),
                    DropdownMenuItem<String>(
                        child: Text('sample'), value: 'sample'),
                    DropdownMenuItem<String>(
                        child: Text('snippet'), value: 'snippet'),
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
                      return DropdownMenuItem<String>(
                          child: Text(name), value: name);
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
          onPressed: okEnabled
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
                      throw SnippetException(
                          'Encountered unknown sample type $selectedSampleType');
                  }
                  widget.onSubmitted(sampleType, selectedTemplate);
                }
              : null,
        ),
      ],
    );
  }
}

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:snippets/snippets.dart';

import 'helper_widgets.dart';
import 'model.dart';

/// The detail view that shows the details of a particular sample.
///
/// And
class DetailView extends StatefulWidget {
  const DetailView({Key? key}) : super(key: key);

  @override
  _DetailViewState createState() => _DetailViewState();
}

// Used to run export in another isolate.
Future<void> _doExport(FlutterSampleLiberator project) async {
  await project.extract(overwrite: true);
}

class _DetailViewState extends State<DetailView> {
  FlutterSampleLiberator? project;
  bool exporting = false;
  bool importing = false;

  void _extractSample() {
    setState(() {
      exporting = true;
      if (project == null) {
        final Directory outputLocation =
            Model.instance.filesystem.systemTempDirectory.createTempSync('flutter_sample.');
        project = FlutterSampleLiberator(
          Model.instance.currentElement!,
          Model.instance.currentSample!,
          location: outputLocation,
          flutterRoot: Model.instance.flutterRoot,
        );
      }
      compute(_doExport, project!).whenComplete(() {
        setState(() {
          exporting = false;
        });
      });
    });
  }

  void _reinsertIntoFrameworkFile(BuildContext context) {
    setState(() {
      if (project == null) {
        return;
      }
      importing = true;
      project!.reinsert().then((String error) {
        if (error.isEmpty) {
          return;
        }
        final ScaffoldMessengerState? scaffold = ScaffoldMessenger.maybeOf(context);
        scaffold?.showSnackBar(
          SnackBar(
            content: Text(error),
          ),
        );
      }).whenComplete(() {
        setState(() {
          importing = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Model.instance.currentSample == null) {
      return const Scaffold(body: Center(child: Text('Working sample not set.')));
    }
    final CodeSample sample = Model.instance.currentSample!;
    final String filename = sample.start.file != null
        ? path.relative(sample.start.file!.path, from: Model.instance.flutterRoot.path)
        : '<generated>';
    return Scaffold(
      appBar: AppBar(
        title: Text('${sample.element} - $filename:${sample.start.line}'),
        actions: const <Widget>[],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTabController(
          initialIndex: 0,
          length: 2,
          child: Column(
            children: <Widget>[
              DataLabel(label: 'Type of sample:', data: sample.type),
              DataLabel(
                  label: 'Sample is attached to:',
                  data: '${sample.element} starting at line ${sample.start.line}'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CodePanel(code: sample.inputAsString, color: Colors.deepPurple.shade50),
                ),
              ),
              ActionPanel(
                isBusy: exporting,
                children: <Widget>[
                  if (!exporting)
                    TextButton(
                        child: Tooltip(
                          message: 'Extract a sample from the Flutter source file',
                          child: Text(
                            project == null ? 'EXTRACT SAMPLE' : 'RE-EXTRACT SAMPLE',
                          ),
                        ),
                        onPressed: _extractSample),
                  if (project != null && !exporting)
                    OutputLocation(
                      location: project!.location,
                      file: project!.location.childDirectory('lib').childFile('main.dart'),
                    ),
                ],
              ),
              ActionPanel(
                isBusy: importing,
                children: <Widget>[
                  TextButton(
                      child: const Tooltip(message: 'Reinsert extracted, edited sample into the Flutter source file',
                        child: Text('REINSERT'),
                      ),
                      onPressed: project != null && !exporting && !importing
                          ? () => _reinsertIntoFrameworkFile(context)
                          : null),
                  const Spacer(),
                  if (sample.start.file != null)
                    OutputLocation(
                      location: FlutterInformation.instance.getFlutterRoot(),
                      file: sample.start.file!.absolute,
                      startLine: sample.start.line,
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

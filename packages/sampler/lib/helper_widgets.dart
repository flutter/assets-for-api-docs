// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:platform/platform.dart';

import 'utils.dart';

/// A label widget that shows a padded label with some bold data.
class DataLabel extends StatelessWidget {
  const DataLabel({Key? key, this.label = '', this.data = ''}) : super(key: key);

  final String label;
  final String data;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = Theme.of(context).textTheme.bodyText2!;
    return DefaultTextStyle(
      style: labelStyle,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
              child: Text(label),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
              child: Text(data, style: labelStyle.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that contains controls for managing an output file: opening it in
/// various IDEs, copying the path to the clipboard, and displaying a label for
/// it.
class OutputLocation extends StatelessWidget {
  OutputLocation({
    Key? key,
    required this.location,
    this.file,
    this.label = '',
    this.startLine = 0,
    Platform platform = const LocalPlatform(),
  })  : _fileBrowserName = _getFileBrowserName(platform),
        assert(file == null || file.absolute.path.contains(location.absolute.path),
            'Supplied file must be within location directory'),
        super(key: key);

  final Directory location;
  final File? file;
  final String label;
  final String _fileBrowserName;
  final int startLine;

  static String _getFileBrowserName(Platform platform) {
    switch (platform.operatingSystem) {
      case 'windows':
        return 'FILE EXPLORER';
      case 'macos':
        return 'FINDER';
      case 'linux':
      default:
        return 'FILE BROWSER';
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = Theme.of(context).textTheme.bodyText2!;
    final String path = file?.path ?? location.absolute.path;
    return DefaultTextStyle(
      style: labelStyle,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
                  child: Text(
                    '$label${label.isNotEmpty ? ' ' : ''}$path',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
                  child: IconButton(
                    tooltip: 'Copy path to clipboard',
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: path));
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
                  child: TextButton(
                    child: Text('OPEN IN $_fileBrowserName'),
                    onPressed: () {
                      openFileBrowser(file ?? location);
                    },
                  ),
                ),
                for (final IdeType type in IdeType.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
                    child: TextButton(
                      child: Text('OPEN IN ${getIdeName(type).toUpperCase()}'),
                      onPressed: () {
                        openInIde(type, location, file: file, startLine: startLine);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A widget that shows a list of actions in a row, with a progress indicator
/// when an action is in progress.
class ActionPanel extends StatelessWidget {
  const ActionPanel({
    Key? key,
    required this.children,
    this.isBusy = false,
  }) : super(key: key);

  final List<Widget> children;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          height: 100,
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: const ShapeDecoration(
            color: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment:
                children.length < 2 ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        ),
        if (isBusy) const CircularProgressIndicator.adaptive(value: null),
      ],
    );
  }
}

// The default Material-style Autocomplete text field.
class AutocompleteField extends StatelessWidget {
  const AutocompleteField({
    Key? key,
    required this.focusNode,
    required this.textEditingController,
    required this.onFieldSubmitted,
    this.hintText = '',
    this.trailing,
  }) : super(key: key);

  final FocusNode focusNode;

  final VoidCallback onFieldSubmitted;

  final TextEditingController textEditingController;

  final Widget? trailing;

  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: hintText,
            ),
            onFieldSubmitted: (String value) {
              onFieldSubmitted();
            },
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A widget that shows formatted Dart source code in a scrollable panel.
class CodePanel extends StatefulWidget {
  const CodePanel({Key? key, required this.code, this.color}) : super(key: key);

  final String code;
  final Color? color;

  @override
  State<CodePanel> createState() => _CodePanelState();
}

class _CodePanelState extends State<CodePanel> {
  late Map<String, TextStyle> highlightTheme;

  @override
  void initState() {
    super.initState();
    highlightTheme = Map<String, TextStyle>.from(githubTheme);
    highlightTheme['root'] = highlightTheme['root']!.copyWith(backgroundColor: Colors.transparent);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: widget.color ?? Colors.black12,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          ListTile(
            title: HighlightView(
              // The original code to be highlighted
              widget.code,
              language: 'dart',
              tabSize: 2,
              theme: highlightTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontFamily: 'Fira Code',
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget that shows monospaced text in a container.
class TextPanel extends StatelessWidget {
  const TextPanel({Key? key, required this.text}) : super(key: key);

  final String text;

  // Strips out multiple empty lines, since those can appear when the tool
  // sections are stripped out.
  String _formatText(String text) {
    return text.replaceAll(RegExp(r'(\n[ \t]*$){2,}', dotAll: true, multiLine: true), '\n');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: const ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SelectableText(
            // The original code to be highlighted
            _formatText(text),
            style: const TextStyle(
              fontFamily: 'Fira Code',
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    this.label,
    this.value,
    this.onChanged,
  }) : super(key: key);

  final Widget? label;
  final bool? value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: InkWell(
        onTap: () => onChanged?.call(!value!),
        child: Row(
          children: <Widget>[
            Checkbox(value: value, onChanged: onChanged),
            if (label != null) label!,
          ],
        ),
      ),
    );
  }
}

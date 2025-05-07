// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:diagrams/steps.dart';
import 'package:flutter/material.dart';

import '../components/brightness_toggle.dart';
import '../components/staggered_list.dart';
import 'diagram_viewer.dart';

class DiagramCatalogPage extends StatefulWidget {
  const DiagramCatalogPage({super.key});

  @override
  State<DiagramCatalogPage> createState() => _DiagramCatalogPageState();
}

class _DiagramCatalogPageState extends State<DiagramCatalogPage> {
  late final List<String> categories;
  final Map<String, List<DiagramStep>> steps = <String, List<DiagramStep>>{};

  @override
  void initState() {
    super.initState();

    final Set<String> categoriesSet = <String>{};
    for (final DiagramStep step in allDiagramSteps) {
      categoriesSet.add(step.category);
      steps.putIfAbsent(step.category, () => <DiagramStep>[]).add(step);
    }
    categories = categoriesSet.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double maxWidth = 1200.0;
        final num extraWidth = max(0, constraints.maxWidth - maxWidth);
        final double appBarPadding = extraWidth / 2;
        return Scaffold(
          appBar: AppBar(
            title: Padding(
              padding: EdgeInsets.only(left: appBarPadding),
              child: const Text('Catalog'),
            ),
            centerTitle: false,
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: appBarPadding),
                child: const BrightnessToggleButton(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: max(8, min(75, extraWidth / 2))),
              child: Center(
                child: SizedBox(
                  width: 1200,
                  child: StaggeredList(
                    minColumnWidth: 350.0,
                    children: <Widget>[
                      for (int index = 0; index < categories.length; index++)
                        CatalogTile(
                          name: categories[index],
                          steps: steps[categories[index]]!,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class CatalogTile extends StatelessWidget {
  const CatalogTile({super.key, required this.name, required this.steps});

  final String name;
  final List<DiagramStep> steps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(20.0),
            ),
            alignment: Alignment.center,
            child: Text(
              name,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          for (final DiagramStep step in steps)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: StepTile(step: step),
            ),
        ],
      ),
    );
  }
}

class StepTile extends StatelessWidget {
  const StepTile({super.key, required this.step});

  final DiagramStep step;

  static Future<void> openDiagramStepViewer(
    BuildContext context,
    DiagramStep step,
  ) async {
    final List<DiagramMetadata> diagrams = await step.diagrams;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            DiagramViewerPage(step: step, diagrams: diagrams),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text(step.runtimeType.toString()),
      trailing: step.platforms.containsAll(DiagramPlatform.values)
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (final DiagramPlatform platform in step.platforms)
                  Chip(label: Text(platform.name)),
              ],
            ),
      visualDensity: const VisualDensity(vertical: -4),
      onTap: () => openDiagramStepViewer(context, step),
    );
  }
}

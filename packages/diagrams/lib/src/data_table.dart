// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:diagram_capture/diagram_capture.dart';
import 'package:flutter/material.dart';

import 'diagram_step.dart';

class DataTableDiagram extends StatelessWidget implements DiagramMetadata {
  const DataTableDiagram(this.name);

  @override
  final String name;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints.tight(const Size(400, 240)),
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: Center(
          child: DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Age',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Role',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows: const <DataRow>[
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('Sarah')),
                  DataCell(Text('19')),
                  DataCell(Text('Student')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('Janine')),
                  DataCell(Text('43')),
                  DataCell(Text('Professor')),
                ],
              ),
              DataRow(
                cells: <DataCell>[
                  DataCell(Text('William')),
                  DataCell(Text('27')),
                  DataCell(Text('Associate Professor')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DataTableDiagramStep extends DiagramStep<DataTableDiagram> {
  DataTableDiagramStep(DiagramController controller) : super(controller);

  @override
  final String category = 'material';

  @override
  Future<List<DataTableDiagram>> get diagrams async => <DataTableDiagram>[
        const DataTableDiagram('data_table'),
      ];

  @override
  Future<File> generateDiagram(DataTableDiagram diagram) async {
    controller.builder = (BuildContext context) => diagram;
    return await controller.drawDiagramToFile(File('${diagram.name}.png'));
  }
}

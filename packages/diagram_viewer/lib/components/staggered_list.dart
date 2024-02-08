// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

/// Evenly packs children with arbitrary height, dividing them up into separate
/// columns depending on the available width.
class StaggeredList extends MultiChildRenderObjectWidget {
  const StaggeredList({
    super.key,
    required this.minColumnWidth,
    required super.children,
  });

  final double minColumnWidth;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderStaggeredList(minColumnWidth: minColumnWidth);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderStaggeredList renderObject,
  ) {
    renderObject.minColumnWidth = minColumnWidth;
  }
}

class StaggeredListParentData extends ContainerBoxParentData<RenderBox> {}

class RenderStaggeredList extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, StaggeredListParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, StaggeredListParentData> {
  RenderStaggeredList({
    required double minColumnWidth,
  }) : _minColumnWidth = minColumnWidth;

  double _minColumnWidth;

  double get minColumnWidth => _minColumnWidth;

  set minColumnWidth(double newValue) {
    if (newValue == _minColumnWidth) {
      return;
    }
    _minColumnWidth = newValue;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! StaggeredListParentData) {
      child.parentData = StaggeredListParentData();
    }
  }

  @override
  void performLayout() {
    // Calculate the number and width of each column by dividing the incoming
    // maxWidth by the minColumnWidth parameter.
    assert(
      constraints.hasBoundedWidth,
      'StaggeredList requires a bounded width',
    );
    final int columns = max(1, (constraints.maxWidth / minColumnWidth).floor());
    final double columnWidth = constraints.maxWidth / columns;

    final List<double> columnHeights = List<double>.filled(columns, 0.0);
    RenderBox? child = firstChild;
    while (child != null) {
      // Give each child the same width but an unbounded height.
      child.layout(
        BoxConstraints.tightFor(width: columnWidth),
        parentUsesSize: true,
      );

      // Find the column with the lowest height.
      int lowestIndex = 0;
      double lowestHeight = columnHeights[0];
      for (int i = 1; i < columns; i++) {
        if (columnHeights[i] < lowestHeight) {
          lowestIndex = i;
          lowestHeight = columnHeights[i];
        }
      }

      // Position the child to the end of that column and increment
      // columnHeights[lowestIndex].
      final StaggeredListParentData parentData =
          child.parentData! as StaggeredListParentData;
      parentData.offset = Offset(
        columnWidth * lowestIndex,
        columnHeights[lowestIndex],
      );
      columnHeights[lowestIndex] += child.size.height;

      child = parentData.nextSibling;
    }

    size = Size(
      constraints.maxWidth,
      columnHeights.reduce(max),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}

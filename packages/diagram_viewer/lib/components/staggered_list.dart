import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class StaggeredList extends MultiChildRenderObjectWidget {
  StaggeredList({
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
    assert(
      constraints.hasBoundedWidth,
      'StaggeredList requires a bounded width',
    );
    final int columns = max(1, (constraints.maxWidth / minColumnWidth).floor());
    final double childWidth = constraints.maxWidth / columns;
    final List<double> columnHeights = List<double>.filled(columns, 0.0);
    RenderBox? child = firstChild;
    while (child != null) {
      int lowestIndex = 0;
      double lowestHeight = columnHeights[0];
      for (int i = 1; i < columns; i++) {
        if (columnHeights[i] < lowestHeight) {
          lowestIndex = i;
          lowestHeight = columnHeights[i];
        }
      }
      child.layout(
        BoxConstraints.tightFor(width: childWidth),
        parentUsesSize: true,
      );
      final StaggeredListParentData parentData =
          child.parentData! as StaggeredListParentData;
      parentData.offset = Offset(
        childWidth * lowestIndex,
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

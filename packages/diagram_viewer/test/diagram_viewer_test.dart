// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:diagram_viewer/components/diagram_ticker_mode.dart';
import 'package:diagram_viewer/components/ticker_duration_observer.dart';
import 'package:diagram_viewer/logic/diagram_ticker_controller.dart';
import 'package:diagram_viewer/main.dart';
import 'package:diagram_viewer/pages/diagram_catalog.dart';
import 'package:diagram_viewer/pages/diagram_viewer.dart';
import 'package:diagrams/steps.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestDiagramStep extends DiagramStep {
  @override
  String get category => 'test';

  static const TestDiagram stillDiagram = TestDiagram(name: 'still');
  static const TestDiagram stillDelayedDiagram = TestDiagram(
    name: 'still_delayed',
    startAt: Duration(seconds: 2),
  );
  static const TestDiagram animatedDiagram = TestDiagram(
    name: 'animated',
    duration: Duration(seconds: 2),
  );
  static const TestDiagram animatedDelayedDiagram = TestDiagram(
    name: 'animated_delayed',
    startAt: Duration(seconds: 2),
    duration: Duration(seconds: 4),
  );

  @override
  Future<List<DiagramMetadata>> get diagrams async {
    return <DiagramMetadata>[
      stillDiagram,
      stillDelayedDiagram,
      animatedDiagram,
      animatedDelayedDiagram,
    ];
  }
}

class TestDiagram extends StatefulWidget with DiagramMetadata {
  const TestDiagram({
    super.key,
    required this.name,
    this.duration,
    this.startAt = Duration.zero,
  });

  @override
  final String name;

  @override
  final Duration? duration;

  @override
  final Duration startAt;

  @override
  State<TestDiagram> createState() => _TestDiagramState();
}

class _TestDiagramState extends State<TestDiagram> {
  final ValueNotifier<Duration> durationNotifier =
      ValueNotifier<Duration>(Duration.zero);

  @override
  Widget build(BuildContext context) {
    return TickerDurationObserver(
      notifier: durationNotifier,
      child: SizedBox.square(
        dimension: 200,
        child: Text('diagram ${widget.name}'),
      ),
    );
  }
}

void main() {
  testWidgets('Catalog shows all steps', (WidgetTester tester) async {
    await tester.pumpWidget(
      const DiagramViewerApp(home: DiagramCatalogPage()),
    );
    await tester.pumpAndSettle();
    for (final DiagramStep step in allDiagramSteps) {
      expect(
        find.widgetWithText(InkWell, step.runtimeType.toString()),
        findsWidgets,
        reason: 'Looking for ${step.runtimeType}',
      );
    }
  });

  testWidgets('Diagram viewer lists steps', (WidgetTester tester) async {
    final DiagramStep step = TestDiagramStep();
    final List<DiagramMetadata> diagrams = await step.diagrams;
    await tester.pumpWidget(
      DiagramViewerApp(
        home: DiagramViewerPage(
          step: step,
          diagrams: diagrams,
        ),
      ),
    );
    await tester.pump(const Duration(minutes: 1));
    for (final DiagramMetadata diagram in diagrams) {
      expect(
        find.widgetWithText(InkWell, diagram.name, skipOffstage: false),
        findsWidgets,
        reason: 'Looking for ${step.runtimeType}',
      );
    }
  });

  testWidgets('DiagramTickerController with still diagram',
      (WidgetTester tester) async {
    final DiagramTickerController controller = DiagramTickerController(
      diagram: TestDiagramStep.stillDiagram,
    );
    await tester.pumpWidget(
      DiagramViewerApp(
        home: DiagramTickerMode(
          controller: controller,
          child: controller.diagram,
        ),
      ),
    );
    expect(controller.elapsed.value, Duration.zero);
    expect(controller.ticking, false);
    expect(controller.selected, false);
    expect(controller.ready, false);
    expect(controller.animationDone, true);
    expect(controller.showProgress, false);

    controller.select();
    // Pump once to rebuild the TickerMode, then again to let it animate.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 1));
    expect(controller.ticking, true);
    expect(controller.selected, true);
    expect(controller.ready, true);

    controller.pause();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 1));
    expect(controller.ticking, false);
    expect(controller.ready, true);

    controller.restart();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 1));
    expect(controller.ticking, true);
    expect(controller.ready, true);

    controller.deselect();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 1));
    expect(controller.ticking, false);
    expect(controller.ready, true);
  });

  testWidgets('DiagramTickerController with still delayed diagram',
      (WidgetTester tester) async {
    final DiagramTickerController controller = DiagramTickerController(
      diagram: TestDiagramStep.stillDelayedDiagram,
    );
    await tester.pumpWidget(
      DiagramViewerApp(
        home: DiagramTickerMode(
          controller: controller,
          child: controller.diagram,
        ),
      ),
    );
    expect(controller.elapsed.value, Duration.zero);
    expect(controller.ticking, false);
    expect(controller.selected, false);
    expect(controller.ready, false);
    expect(controller.animationDone, false);
    expect(controller.showProgress, true);

    controller.select();
    // Pump once to rebuild the TickerMode, then again to let it animate.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.selected, true);
    expect(controller.ticking, true);

    await tester.pump(const Duration(seconds: 2));

    // Diagram should pause when startAt elapses
    expect(controller.ticking, false);

    expect(controller.elapsed.value, const Duration(seconds: 3));
    expect(controller.ready, true);

    controller.restart();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 1));
    expect(controller.ticking, true);
    expect(controller.ready, true);

    controller.deselect();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 1));
    expect(controller.ticking, false);
    expect(controller.ready, true);
  });

  testWidgets('DiagramTickerController with animated diagram',
      (WidgetTester tester) async {
    final DiagramTickerController controller = DiagramTickerController(
      diagram: TestDiagramStep.animatedDiagram,
    );
    await tester.pumpWidget(
      DiagramViewerApp(
        home: DiagramTickerMode(
          controller: controller,
          child: controller.diagram,
        ),
      ),
    );
    expect(controller.elapsed.value, Duration.zero);
    expect(controller.ticking, false);
    expect(controller.selected, false);
    expect(controller.ready, false);
    expect(controller.animationDone, false);
    expect(controller.showProgress, true);
    expect(controller.progress, closeTo(0.0, precisionErrorTolerance));

    controller.select();
    // Pump once to rebuild the TickerMode, then again to let it animate.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 1));
    expect(controller.ticking, true);
    expect(controller.selected, true);
    expect(controller.ready, true);
    expect(controller.progress, closeTo(0.5, precisionErrorTolerance));

    await tester.pump(const Duration(seconds: 2));

    expect(controller.animationDone, true);

    controller.pause();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 3));
    expect(controller.ticking, false);
    expect(controller.ready, true);
    expect(controller.progress, closeTo(1.0, precisionErrorTolerance));

    controller.restart();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 1));
    expect(controller.ticking, true);
    expect(controller.ready, true);
    expect(controller.progress, closeTo(0.5, precisionErrorTolerance));

    controller.deselect();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(controller.elapsed.value, const Duration(seconds: 1));
    expect(controller.ticking, false);
    expect(controller.ready, true);
    expect(controller.progress, closeTo(0.5, precisionErrorTolerance));
  });
}

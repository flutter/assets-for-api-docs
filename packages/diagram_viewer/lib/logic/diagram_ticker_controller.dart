import 'dart:async';

import 'package:diagrams/steps.dart';
import 'package:flutter/widgets.dart';

/// A controller that manages the tick state of a diagram and its progress.
class DiagramTickerController extends ChangeNotifier {
  DiagramTickerController({
    required this.diagram,
  }) {
    elapsed.addListener(_onElapsed);
  }

  final DiagramMetadata diagram;

  /// Notifier for how much time has elapsed from the diagram's perspective.
  final ValueNotifier<Duration> elapsed =
      ValueNotifier<Duration>(Duration.zero);

  /// Whether or not the TickerMode should be enabled.
  bool ticking = false;

  /// Whether or not we are waiting for setUp to finish.
  bool settingUp = false;

  /// Whether or not the diagram is ready to be used.
  bool ready = false;

  /// Whether or not the diagram is the primary one, multiple can be on screen
  /// at once.
  bool selected = false;

  /// The key to pass to the diagram, this is used to reset the state of the
  /// widget when calling [restart].
  GlobalKey diagramKey = GlobalKey();

  /// Whether or not to show the progress slider.
  bool get showProgress =>
      diagram.duration != null || diagram.startAt != Duration.zero;

  /// The total duration of the diagram's animation including the startAt for
  /// still diagrams.
  Duration get animationDuration {
    final Duration diagramDuration = diagram.duration ?? Duration.zero;
    if (diagramDuration < diagram.startAt) {
      return diagram.startAt;
    } else {
      return diagramDuration;
    }
  }

  /// The animation's progress as an interval from 0 to 1.
  double get progress {
    return (elapsed.value.inMicroseconds / animationDuration.inMicroseconds)
        .clamp(0.0, 1.0);
  }

  /// Whether or not the animation has finished, always true if the diagram
  /// is not animated.
  bool get animationDone => elapsed.value >= animationDuration || !showProgress;

  bool? _wasDone;

  void _onElapsed() {
    // If this is a still diagram and startAt elapses, pause it.
    if (ticking &&
        ready &&
        diagram.startAt != Duration.zero &&
        diagram.duration == null &&
        elapsed.value >= diagram.startAt) {
      ticking = false;
      notifyListeners();
    }

    // Notify if animationDone changes as a result of the ticker elapsing.
    final bool isDone = animationDone;
    if (isDone != _wasDone) {
      _wasDone = isDone;
      notifyListeners();
    }
  }

  Future<void> setUp() async {
    if (settingUp || ready) {
      return;
    }
    settingUp = true;
    ticking = selected;
    notifyListeners();

    // Wait a frame if the widget hasn't been built yet
    if (diagramKey.currentContext == null) {
      final Completer<void> completer = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((Duration timeStamp) {
        completer.complete();
      });
      await completer.future;
    }

    // Maybe it was disposed before we could call setUp
    if (diagramKey.currentContext == null) {
      settingUp = false;
      notifyListeners();
      return;
    }

    try {
      await diagram.setUp(diagramKey);
      ready = true;
      notifyListeners();
    } finally {
      settingUp = false;
      notifyListeners();
    }
  }

  /// Restarts the diagram by resetting its state and starting from the
  /// beginning.
  void restart() {
    diagramKey = GlobalKey();
    elapsed.value = Duration.zero;
    ready = false;
    ticking = selected;
    _wasDone = false;
    notifyListeners();
    setUp();
  }

  /// Pauses the diagram, preventing tickers from firing until [restart] is
  /// called.
  void pause() {
    if (ticking && ready) {
      ticking = false;
      notifyListeners();
    }
  }

  /// Resets this controller to its default state.
  void reset() {
    ticking = false;
    settingUp = false;
    ready = false;
    selected = false;
    diagramKey = GlobalKey();
    elapsed.value = Duration.zero;
    _wasDone = null;
    notifyListeners();
  }

  /// Selects this diagram, call this method when it becomes visible.
  void select() {
    if (selected) {
      return;
    } else {
      selected = true;
      notifyListeners();
      restart();
    }
  }

  /// De-selects this diagram, call when it's no longer visible.
  void deselect() {
    if (!selected) {
      return;
    }
    ticking = false;
    selected = false;
    notifyListeners();
  }
}

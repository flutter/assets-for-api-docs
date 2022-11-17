import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// A [WidgetController] that only accepts pointer events that are inside of
/// a specific subtree.
class SubtreeWidgetController extends LiveWidgetController {
  SubtreeWidgetController(super.binding, this.key);

  final GlobalKey key;

  void handlePointerEvent(PointerEvent event) {
    final BuildContext? context = key.currentContext;
    if (context == null) {
      return;
    }
    // Send the pointer event only if it is inside the target area.
    final RenderBox renderObject = context.findRenderObject()! as RenderBox;
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    final Offset bottomRight =
        renderObject.localToGlobal(renderObject.size.bottomRight(Offset.zero));
    if (event.position >= topLeft && event.position <= bottomRight) {
      binding.handlePointerEvent(event);
    }
  }

  @override
  Future<List<Duration>> handlePointerEventRecord(
      List<PointerEventRecord> records) {
    assert(records != null);
    assert(records.isNotEmpty);
    return TestAsyncUtils.guard<List<Duration>>(() async {
      final List<Duration> handleTimeStampDiff = <Duration>[];
      DateTime? startTime;
      for (final PointerEventRecord record in records) {
        final DateTime now = clock.now();
        startTime ??= now;
        // So that the first event is promised to receive a zero timeDiff
        final Duration timeDiff = record.timeDelay - now.difference(startTime);
        if (timeDiff.isNegative) {
          // This happens when something (e.g. GC) takes a long time during the
          // processing of the events.
          // Flush all past events
          handleTimeStampDiff.add(-timeDiff);
          record.events.forEach(handlePointerEvent);
        } else {
          await Future<void>.delayed(timeDiff);
          handleTimeStampDiff.add(
            // Recalculating the time diff for getting exact time when the event
            // packet is sent. For a perfect Future.delayed like the one in a
            // fake async this new diff should be zero.
            clock.now().difference(startTime) - record.timeDelay,
          );
          record.events.forEach(handlePointerEvent);
        }
      }
      return handleTimeStampDiff;
    });
  }
}

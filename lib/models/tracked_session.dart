import 'time_category.dart';

/// A single completed time-tracking session.
///
/// `duration` is stored explicitly (not derived from endTime-startTime)
/// because a session can include paused time — the wall-clock span
/// from start to end is NOT the same as the actual active tracking
/// time once pause/resume is involved.
class TrackedSession {
  final String activityName;
  final TimeCategory category;
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;

  const TrackedSession({
    required this.activityName,
    required this.category,
    required this.startTime,
    required this.endTime,
    required this.duration,
  });
}
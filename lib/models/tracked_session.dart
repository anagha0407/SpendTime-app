import 'time_category.dart';

/// A single completed time-tracking session.
class TrackedSession {
  final String activityName;
  final TimeCategory category;
  final DateTime startTime;
  final DateTime endTime;

  const TrackedSession({
    required this.activityName,
    required this.category,
    required this.startTime,
    required this.endTime,
  });

  Duration get duration => endTime.difference(startTime);
}
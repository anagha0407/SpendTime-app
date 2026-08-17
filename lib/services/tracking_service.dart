import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/time_category.dart';
import '../models/tracked_session.dart';

/// Holds all time-tracking state in memory for the current app run.
///
/// This is a ChangeNotifier — part of the Flutter SDK, not an
/// external package — so widgets can rebuild on changes using
/// AnimatedBuilder, without Provider/Riverpod/Bloc.
class TrackingService extends ChangeNotifier {
  TrackingService() {
    _seedInitialSessions();
  }

  // Active session state
  String? _activeActivityName;
  TimeCategory? _activeCategory;
  DateTime? _activeStartTime;
  Timer? _timer;

  // Completed sessions, most recent first
  final List<TrackedSession> _completedSessions = [];

  bool get isTracking => _activeStartTime != null;
  String? get activeActivityName => _activeActivityName;
  TimeCategory? get activeCategory => _activeCategory;

  /// Elapsed time of the active session, recalculated from real clock
  /// time rather than an incrementing counter, so it can't drift.
  Duration get elapsed {
    if (_activeStartTime == null) return Duration.zero;
    return DateTime.now().difference(_activeStartTime!);
  }

  List<TrackedSession> get completedSessions =>
      List.unmodifiable(_completedSessions);

  /// Today's total = all completed sessions + whatever is running now.
  Duration get todayTotal {
    final completedTotal = _completedSessions.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.duration,
    );
    return completedTotal + elapsed;
  }

  /// Starts a new session. Silently does nothing if one is already
  /// running or the name is empty — this is what stops a second
  /// timer from ever starting.
  void start(String activityName, TimeCategory category) {
    if (isTracking) return;
    final trimmedName = activityName.trim();
    if (trimmedName.isEmpty) return;

    _activeActivityName = trimmedName;
    _activeCategory = category;
    _activeStartTime = DateTime.now();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });

    notifyListeners();
  }

  /// Stops the active session and stores it as a completed one.
  void stop() {
    if (!isTracking) return;

    final session = TrackedSession(
      activityName: _activeActivityName!,
      category: _activeCategory!,
      startTime: _activeStartTime!,
      endTime: DateTime.now(),
    );
    _completedSessions.insert(0, session);

    _timer?.cancel();
    _timer = null;
    _activeActivityName = null;
    _activeCategory = null;
    _activeStartTime = null;

    notifyListeners();
  }

  /// A few realistic seeded sessions so Recent Activity / today's
  /// total aren't empty on a fresh app launch.
  void _seedInitialSessions() {
    final now = DateTime.now();
    _completedSessions.addAll([
      TrackedSession(
        activityName: 'Flutter Course',
        category: TimeCategory.study,
        startTime: now.subtract(const Duration(hours: 1, minutes: 45)),
        endTime: now.subtract(const Duration(hours: 1)),
      ),
      TrackedSession(
        activityName: 'Client Meeting',
        category: TimeCategory.work,
        startTime: now.subtract(const Duration(hours: 3, minutes: 30)),
        endTime: now.subtract(const Duration(hours: 3)),
      ),
      TrackedSession(
        activityName: 'Evening Run',
        category: TimeCategory.exercise,
        startTime: now.subtract(const Duration(hours: 5, minutes: 25)),
        endTime: now.subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
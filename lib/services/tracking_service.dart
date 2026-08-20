import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/lap.dart';
import '../models/time_category.dart';
import '../models/tracked_session.dart';

/// Holds all time-tracking state in memory for the current app run.
///
/// Elapsed time is tracked as: accumulated active duration from all
/// PREVIOUS running segments, plus (if currently running) time since
/// the CURRENT segment started. Pausing "closes" a segment into the
/// accumulated total; resuming opens a new segment. This is what
/// makes pause/resume/stop all report accurate active time, with
/// paused time never counted.
class TrackingService extends ChangeNotifier {
  TrackingService() {
    _seedInitialSessions();
  }

  // Active session identity — set on start(), cleared on stop()/reset().
  String? _activeActivityName;
  TimeCategory? _activeCategory;
  DateTime? _sessionStartTime; // original start time, kept for history display

  // Elapsed-time bookkeeping.
  Duration _accumulatedDuration = Duration.zero;
  DateTime? _currentSegmentStart; // null while paused
  bool _isPaused = false;

  Timer? _timer;
  final List<Lap> _laps = [];
  final List<TrackedSession> _completedSessions = [];

  bool get isTracking => _activeActivityName != null;
  bool get isPaused => _isPaused;
  String? get activeActivityName => _activeActivityName;
  TimeCategory? get activeCategory => _activeCategory;
  List<Lap> get laps => List.unmodifiable(_laps);

  /// Active elapsed time for the current session — excludes any time
  /// spent paused. Recalculated from real clock time (not an
  /// incrementing counter), so it can't drift.
  Duration get elapsed {
    if (!isTracking) return Duration.zero;
    if (_isPaused || _currentSegmentStart == null) return _accumulatedDuration;
    return _accumulatedDuration + DateTime.now().difference(_currentSegmentStart!);
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

  /// Starts a new session. Does nothing if one is already active
  /// (running or paused) or the name is empty.
  void start(String activityName, TimeCategory category) {
    if (isTracking) return;
    final trimmedName = activityName.trim();
    if (trimmedName.isEmpty) return;

    _activeActivityName = trimmedName;
    _activeCategory = category;
    _sessionStartTime = DateTime.now();
    _accumulatedDuration = Duration.zero;
    _currentSegmentStart = DateTime.now();
    _isPaused = false;
    _laps.clear();

    _startTicking();
    notifyListeners();
  }

  /// Pauses the active session. Elapsed time is frozen at exactly its
  /// current value — it will not advance again until resume().
  void pause() {
    if (!isTracking || _isPaused) return;

    _accumulatedDuration += DateTime.now().difference(_currentSegmentStart!);
    _currentSegmentStart = null;
    _isPaused = true;
    _stopTicking();
    notifyListeners();
  }

  /// Resumes a paused session from exactly where it left off.
  void resume() {
    if (!isTracking || !_isPaused) return;

    _currentSegmentStart = DateTime.now();
    _isPaused = false;
    _startTicking();
    notifyListeners();
  }

  /// Records a lap at the current elapsed time. Only valid while
  /// actively running (not paused) — does not pause/stop anything.
  void lap() {
    if (!isTracking || _isPaused) return;

    _laps.add(Lap(number: _laps.length + 1, elapsedAtLap: elapsed));
    notifyListeners();
  }

  /// Stops the current session and discards it WITHOUT creating a
  /// completed session/history entry. Returns to the initial state.
  void reset() {
    if (!isTracking) return;

    _stopTicking();
    _clearActiveState();
    notifyListeners();
  }

  /// Stops the active session and stores it as a completed one.
  /// The stored duration is active tracking time only — any paused
  /// time is excluded.
  void stop() {
    if (!isTracking) return;

    final activeDuration = elapsed; // paused time already excluded
    final session = TrackedSession(
      activityName: _activeActivityName!,
      category: _activeCategory!,
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      duration: activeDuration,
    );
    _completedSessions.insert(0, session);

    _stopTicking();
    _clearActiveState();
    notifyListeners();
  }

  void _clearActiveState() {
    _activeActivityName = null;
    _activeCategory = null;
    _sessionStartTime = null;
    _accumulatedDuration = Duration.zero;
    _currentSegmentStart = null;
    _isPaused = false;
    _laps.clear();
  }

  void _startTicking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  void _stopTicking() {
    _timer?.cancel();
    _timer = null;
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
        duration: const Duration(minutes: 45),
      ),
      TrackedSession(
        activityName: 'Client Meeting',
        category: TimeCategory.work,
        startTime: now.subtract(const Duration(hours: 3, minutes: 30)),
        endTime: now.subtract(const Duration(hours: 3)),
        duration: const Duration(minutes: 30),
      ),
      TrackedSession(
        activityName: 'Evening Run',
        category: TimeCategory.exercise,
        startTime: now.subtract(const Duration(hours: 5, minutes: 25)),
        endTime: now.subtract(const Duration(hours: 5)),
        duration: const Duration(minutes: 25),
      ),
    ]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
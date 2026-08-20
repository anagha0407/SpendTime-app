import 'package:flutter/material.dart';

import '../models/tracked_session.dart';
import '../models/expense.dart';
import '../services/tracking_service.dart';
import '../services/expense_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/session_history_tile.dart';
import '../widgets/expense_tile.dart';

/// Internal helper pairing a history entry (session or expense) with
/// the timestamp used to sort it, and the widget used to display it.
///
/// Not a shared model — this is display-only grouping for this screen.
class _HistoryEntry {
  final DateTime time;
  final Widget tile;

  const _HistoryEntry({
    required this.time,
    required this.tile,
  });
}

/// Shows completed time-tracking sessions and saved expenses together,
/// grouped by day (newest day first, newest entry first within a day).
class HistoryScreen extends StatelessWidget {
  final TrackingService trackingService;
  final ExpenseService expenseService;

  const HistoryScreen({
    super.key,
    required this.trackingService,
    required this.expenseService,
  });

  /// Strips the time component so entries can be grouped by calendar day.
  DateTime _dateOnly(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
  }

  String _dayLabel(DateTime day) {
    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    if (day == today) return 'Today';
    if (day == yesterday) return 'Yesterday';

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${day.day} ${months[day.month - 1]} ${day.year}';
  }

  /// Combines sessions and expenses into day groups, each internally
  /// sorted newest-first, with the groups themselves newest-day-first.
  List<MapEntry<DateTime, List<_HistoryEntry>>> _groupByDay(
    List<TrackedSession> sessions,
    List<Expense> expenses,
    ExpenseService expenseService,
  ) {
    final Map<DateTime, List<_HistoryEntry>> grouped = {};

    for (final session in sessions) {
      final day = _dateOnly(session.startTime);

      grouped.putIfAbsent(day, () => []).add(
            _HistoryEntry(
              time: session.startTime,
              tile: SessionHistoryTile(session: session),
            ),
          );
    }

    for (final expense in expenses) {
      final day = _dateOnly(expense.date);

      grouped.putIfAbsent(day, () => []).add(
            _HistoryEntry(
              time: expense.date,
              tile: ExpenseTile(
                expense: expense,
                expenseService: expenseService,
              ),
            ),
          );
    }

    // Sort entries within each day, newest first.
    for (final entries in grouped.values) {
      entries.sort(
        (a, b) => b.time.compareTo(a.time),
      );
    }

    // Sort the days themselves, newest first.
    final sortedDays = grouped.entries.toList()
      ..sort(
        (a, b) => b.key.compareTo(a.key),
      );

    return sortedDays;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          // Rebuild whenever a session completes or an expense is added.
          animation: Listenable.merge([
            trackingService,
            expenseService,
          ]),
          builder: (context, _) {
            final dayGroups = _groupByDay(
              trackingService.completedSessions,
              expenseService.expenses,
              expenseService,
            );

            if (dayGroups.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No history yet',
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tracked sessions and expenses will show up here.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final dayGroup in dayGroups) ...[
                    Text(
                      _dayLabel(dayGroup.key),
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 8),
                    ...dayGroup.value.map(
                      (entry) => entry.tile,
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
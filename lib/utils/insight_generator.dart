import '../models/expense.dart';
import '../models/time_category.dart';
import '../models/tracked_session.dart';

/// How an insight should be visually treated — the widget layer maps
/// this to an icon/color, keeping this file free of UI concerns.
enum InsightTone { positive, negative, neutral, warning }

/// One generated, human-readable insight.
class GeneratedInsight {
  final String text;
  final InsightTone tone;

  const GeneratedInsight({required this.text, required this.tone});
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

String _formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours == 0) return '${minutes}m';
  return '${hours}h ${minutes}m';
}

const List<String> _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime date) => '${date.day} ${_months[date.month - 1]}';

bool _isWeekend(DateTime date) =>
    date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

/// The last 7 calendar days including today, oldest first.
List<DateTime> _last7Days() {
  final today = _dateOnly(DateTime.now());
  return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
}

/// Generates rule-based insights purely from real data. Each rule is
/// self-guarded: it only produces a sentence when the data actually
/// supports the claim, otherwise it silently produces nothing.
List<GeneratedInsight> generateInsights({
  required List<Expense> expenses,
  required List<TrackedSession> sessions,
}) {
  final insights = <GeneratedInsight>[];
  final today = _dateOnly(DateTime.now());
  final yesterday = today.subtract(const Duration(days: 1));

  // ============= SPENDING =============

  Map<ExpenseCategory, double>? expenseByCategory;
  double expenseTotal = 0;
  if (expenses.isNotEmpty) {
    expenseByCategory = {};
    for (final e in expenses) {
      expenseByCategory[e.category] =
          (expenseByCategory[e.category] ?? 0) + e.amount;
      expenseTotal += e.amount;
    }
  }

  // ---- 1. Highest spending category ----
  // Only meaningful when 2+ categories have spending and there's a
  // clear (non-tied) leader.
  List<MapEntry<ExpenseCategory, double>>? sortedExpenseCategories;
  if (expenseByCategory != null && expenseByCategory.length >= 2) {
    sortedExpenseCategories = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedExpenseCategories[0].value > sortedExpenseCategories[1].value) {
      insights.add(
        GeneratedInsight(
          text:
              '${sortedExpenseCategories[0].key.label} is your highest '
              'spending category.',
          tone: InsightTone.neutral,
        ),
      );

      // ---- 2. Spending concentration/pattern ----
      // Only claim "concentration" when the leader clearly dominates
      // (>=50% of total) — otherwise spending is fairly spread out
      // and no concentration claim is supportable.
      final share = sortedExpenseCategories[0].value / expenseTotal;
      if (share >= 0.5) {
        insights.add(
          GeneratedInsight(
            text:
                '${sortedExpenseCategories[0].key.label} makes up '
                '${(share * 100).round()}% of your total spending.',
            tone: InsightTone.neutral,
          ),
        );
      } else if (expenseByCategory.length >= 3) {
        // With enough categories, note when spending is instead
        // spread fairly evenly (no category over ~35%).
        final maxShare = sortedExpenseCategories
            .map((e) => e.value / expenseTotal)
            .reduce((a, b) => a > b ? a : b);
        if (maxShare < 0.35) {
          insights.add(
            const GeneratedInsight(
              text: 'Your spending is fairly spread across categories, '
                  'without one dominating.',
              tone: InsightTone.neutral,
            ),
          );
        }
      }
    }
  }

  // ---- Unusually high spending day ----
  // Needs enough spread of data (3+ distinct days) so "average" and
  // "unusual" both mean something.
  Map<DateTime, double>? expenseByDay;
  if (expenses.isNotEmpty) {
    expenseByDay = {};
    for (final e in expenses) {
      final day = _dateOnly(e.date);
      expenseByDay[day] = (expenseByDay[day] ?? 0) + e.amount;
    }
    if (expenseByDay.length >= 3) {
      final average = expenseTotal / expenseByDay.length;
      final sortedDays = expenseByDay.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final highest = sortedDays.first;

      if (average > 0 && highest.value >= average * 1.5) {
        insights.add(
          GeneratedInsight(
            text:
                'You spent ₹${highest.value.toStringAsFixed(2)} on '
                '${_formatDate(highest.key)} — well above your daily '
                'average of ₹${average.toStringAsFixed(2)}.',
            tone: InsightTone.warning,
          ),
        );
      }
    }
  }

  // ---- 5a. Weekday vs weekend spending ----
  // Only compared when there's real data on both sides — at least 2
  // distinct weekday dates AND 2 distinct weekend dates — so a
  // single weekend outing can't skew the claim.
  if (expenseByDay != null && expenseByDay.length >= 4) {
    final weekendDays =
        expenseByDay.keys.where(_isWeekend).toList();
    final weekdayDays =
        expenseByDay.keys.where((d) => !_isWeekend(d)).toList();

    if (weekendDays.length >= 2 && weekdayDays.length >= 2) {
      final weekendAvg =
          weekendDays.fold<double>(0, (s, d) => s + expenseByDay![d]!) /
              weekendDays.length;
      final weekdayAvg =
          weekdayDays.fold<double>(0, (s, d) => s + expenseByDay![d]!) /
              weekdayDays.length;

      // Require a meaningfully large gap (>=20%) before calling it a
      // pattern, not just normal day-to-day variation.
      if (weekendAvg > weekdayAvg * 1.2) {
        insights.add(
          const GeneratedInsight(
            text: 'You tend to spend more on weekends than on weekdays.',
            tone: InsightTone.neutral,
          ),
        );
      } else if (weekdayAvg > weekendAvg * 1.2) {
        insights.add(
          const GeneratedInsight(
            text: 'You tend to spend more on weekdays than on weekends.',
            tone: InsightTone.neutral,
          ),
        );
      }
    }
  }

  // ---- Today vs yesterday: spending ----
  // Only compared when both days actually have expense entries —
  // comparing against a day with zero data isn't a fair comparison.
  if (expenses.any((e) => _dateOnly(e.date) == today) &&
      expenses.any((e) => _dateOnly(e.date) == yesterday)) {
    final todayTotal = expenses
        .where((e) => _dateOnly(e.date) == today)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final yesterdayTotal = expenses
        .where((e) => _dateOnly(e.date) == yesterday)
        .fold<double>(0, (sum, e) => sum + e.amount);

    if (todayTotal != yesterdayTotal) {
      final spentMore = todayTotal > yesterdayTotal;
      insights.add(
        GeneratedInsight(
          text: spentMore
              ? 'You spent more today than yesterday.'
              : 'You spent less today than yesterday.',
          tone: spentMore ? InsightTone.negative : InsightTone.positive,
        ),
      );
    }
  }

  // ============= TIME TRACKING =============

  Map<TimeCategory, Duration>? timeByCategory;
  Duration timeTotal = Duration.zero;
  if (sessions.isNotEmpty) {
    timeByCategory = {};
    for (final s in sessions) {
      timeByCategory[s.category] =
          (timeByCategory[s.category] ?? Duration.zero) + s.duration;
      timeTotal += s.duration;
    }
  }

  // ---- 3. Most tracked time category (+ share) ----
  if (timeByCategory != null && timeByCategory.length >= 2) {
    final sortedTimeCategories = timeByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedTimeCategories[0].value > sortedTimeCategories[1].value) {
      insights.add(
        GeneratedInsight(
          text:
              'You spent most of your tracked time on '
              '${sortedTimeCategories[0].key.label}.',
          tone: InsightTone.neutral,
        ),
      );

      final share =
          sortedTimeCategories[0].value.inMinutes / timeTotal.inMinutes;
      if (share >= 0.5) {
        insights.add(
          GeneratedInsight(
            text:
                '${sortedTimeCategories[0].key.label} accounts for '
                '${(share * 100).round()}% of your tracked time.',
            tone: InsightTone.neutral,
          ),
        );
      }

      // Direct comparison between the top two, only when the gap is
      // large enough (>=10 minutes) to be worth stating.
      final diff = sortedTimeCategories[0].value - sortedTimeCategories[1].value;
      if (diff.inMinutes >= 10) {
        insights.add(
          GeneratedInsight(
            text:
                'You spent ${_formatDuration(diff)} more on '
                '${sortedTimeCategories[0].key.label} than '
                '${sortedTimeCategories[1].key.label}.',
            tone: InsightTone.neutral,
          ),
        );
      }
    }
  }

  // ---- 4. Tracking consistency across recent days ----
  // Only evaluated once there's at least 3 distinct days of tracking
  // history overall — otherwise "consistency" isn't a fair judgment
  // to make yet (e.g. day 1 of using the app).
  if (sessions.isNotEmpty) {
    final allTrackedDays =
        sessions.map((s) => _dateOnly(s.startTime)).toSet();

    if (allTrackedDays.length >= 3) {
      final last7 = _last7Days();
      final daysTrackedInLast7 =
          last7.where((day) => allTrackedDays.contains(day)).length;

      if (daysTrackedInLast7 >= 5) {
        insights.add(
          GeneratedInsight(
            text:
                'You\'ve tracked time on $daysTrackedInLast7 of the last '
                '7 days — great consistency!',
            tone: InsightTone.positive,
          ),
        );
      } else if (daysTrackedInLast7 <= 2) {
        insights.add(
          GeneratedInsight(
            text:
                'You\'ve only tracked time on $daysTrackedInLast7 of the '
                'last 7 days. Try to track a little more consistently.',
            tone: InsightTone.warning,
          ),
        );
      }
    }
  }

  // ---- 5b. Average session length ----
  // Only surfaced with a reasonable sample size (5+ sessions) so one
  // unusually long/short session doesn't define the "average" claim.
  if (sessions.length >= 5) {
    final avgMinutes = timeTotal.inMinutes / sessions.length;
    insights.add(
      GeneratedInsight(
        text:
            'Your average tracking session is about '
            '${avgMinutes.round()} minutes.',
        tone: InsightTone.neutral,
      ),
    );
  }

  // ---- Today vs yesterday: tracked time ----
  if (sessions.any((s) => _dateOnly(s.startTime) == today) &&
      sessions.any((s) => _dateOnly(s.startTime) == yesterday)) {
    final todayTotal = sessions
        .where((s) => _dateOnly(s.startTime) == today)
        .fold<Duration>(Duration.zero, (sum, s) => sum + s.duration);
    final yesterdayTotal = sessions
        .where((s) => _dateOnly(s.startTime) == yesterday)
        .fold<Duration>(Duration.zero, (sum, s) => sum + s.duration);

    if (todayTotal != yesterdayTotal) {
      final trackedMore = todayTotal > yesterdayTotal;
      insights.add(
        GeneratedInsight(
          text: trackedMore
              ? 'You tracked more time today than yesterday.'
              : 'You tracked less time today than yesterday.',
          tone: trackedMore ? InsightTone.positive : InsightTone.neutral,
        ),
      );
    }
  }

  return insights;
}
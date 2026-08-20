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

  // ---- Highest spending category ----
  // Only meaningful when 2+ categories have spending and there's a
  // clear (non-tied) leader.
  if (expenses.isNotEmpty) {
    final Map<ExpenseCategory, double> byCategory = {};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    if (byCategory.length >= 2) {
      final sorted = byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (sorted[0].value > sorted[1].value) {
        insights.add(
          GeneratedInsight(
            text: '${sorted[0].key.label} is your highest spending category.',
            tone: InsightTone.neutral,
          ),
        );
      }
    }
  }

  // ---- Dominant tracked-time category + comparison ----
  if (sessions.isNotEmpty) {
    final Map<TimeCategory, Duration> byCategory = {};
    for (final s in sessions) {
      byCategory[s.category] =
          (byCategory[s.category] ?? Duration.zero) + s.duration;
    }
    if (byCategory.length >= 2) {
      final sorted = byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (sorted[0].value > sorted[1].value) {
        insights.add(
          GeneratedInsight(
            text:
                'You spent most of your tracked time on ${sorted[0].key.label}.',
            tone: InsightTone.neutral,
          ),
        );

        // Only surface the numeric comparison when the gap is at
        // least 10 minutes — otherwise "more" is barely meaningful.
        final diff = sorted[0].value - sorted[1].value;
        if (diff.inMinutes >= 10) {
          insights.add(
            GeneratedInsight(
              text:
                  'You spent ${_formatDuration(diff)} more on '
                  '${sorted[0].key.label} than ${sorted[1].key.label}.',
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
  if (expenses.isNotEmpty) {
    final Map<DateTime, double> byDay = {};
    for (final e in expenses) {
      final day = _dateOnly(e.date);
      byDay[day] = (byDay[day] ?? 0) + e.amount;
    }
    if (byDay.length >= 3) {
      final total = byDay.values.fold<double>(0, (sum, v) => sum + v);
      final average = total / byDay.length;
      final sortedDays = byDay.entries.toList()
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
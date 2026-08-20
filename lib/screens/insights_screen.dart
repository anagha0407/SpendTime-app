import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/time_category.dart';
import '../models/tracked_session.dart';
import '../services/expense_service.dart';
import '../services/tracking_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/insight_generator.dart';
import '../widgets/category_distribution_chart.dart';
import '../widgets/daily_trend_chart.dart';
import '../widgets/expense_category_row.dart';
import '../widgets/generated_insight_tile.dart';
import '../widgets/insight_stat_card.dart';

/// Insights tab: summary statistics, charts, and personalized insights
/// derived from the existing TrackingService and ExpenseService.
///
/// Read-only — never mutates either service.
class InsightsScreen extends StatelessWidget {
  final TrackingService trackingService;
  final ExpenseService expenseService;

  const InsightsScreen({
    super.key,
    required this.trackingService,
    required this.expenseService,
  });

  // Fixed display colors for expense categories, scoped to this
  // screen only — ExpenseCategory itself has no color of its own.
  static const Map<ExpenseCategory, Color> _expenseCategoryColors = {
    ExpenseCategory.food: AppColors.primary,
    ExpenseCategory.travel: AppColors.secondary,
    ExpenseCategory.shopping: Color(0xFFFFA726),
    ExpenseCategory.bills: Color(0xFFEF5350),
    ExpenseCategory.entertainment: Color(0xFFAB47BC),
    ExpenseCategory.education: Color(0xFF26A69A),
    ExpenseCategory.other: AppColors.textSecondary,
  };

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);

    if (hours == 0) {
      return '${minutes}m';
    }

    return '${hours}h ${minutes}m';
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static const List<String> _weekdayShort = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Last 7 calendar days (oldest to newest), used as the x-axis
  /// for both trend charts.
  List<DateTime> _last7Days() {
    final today = _dateOnly(DateTime.now());

    return List.generate(
      7,
      (i) => today.subtract(Duration(days: 6 - i)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          // Rebuild when a session completes or an expense is added.
          animation: Listenable.merge([
            trackingService,
            expenseService,
          ]),
          builder: (context, _) {
            final expenses = expenseService.expenses;
            final sessions = trackingService.completedSessions;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Insights',
                    style: AppTextStyles.headline,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Understand your spending and time patterns',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---------------- For You ----------------

                  Text(
                    'For You',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 12),
                  _buildGeneratedInsightsSection(
                    expenses,
                    sessions,
                  ),
                  const SizedBox(height: 24),

                  // ---------------- Spending Overview ----------------

                  Text(
                    'Spending Overview',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 12),
                  if (expenses.isEmpty)
                    _buildEmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'No expenses yet',
                      message:
                          'Add an expense to start seeing your spending insights.',
                    )
                  else
                    _buildSpendingSection(expenses),

                  const SizedBox(height: 24),

                  // ---------------- Time Overview ----------------

                  Text(
                    'Time Overview',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 12),
                  if (sessions.isEmpty)
                    _buildEmptyState(
                      icon: Icons.timer_outlined,
                      title: 'No tracked time yet',
                      message:
                          'Start a tracking session to see your time insights.',
                    )
                  else
                    _buildTimeSection(sessions),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------- Generated Insights ----------------

  Widget _buildGeneratedInsightsSection(
    List<Expense> expenses,
    List<TrackedSession> sessions,
  ) {
    final insights = generateInsights(
      expenses: expenses,
      sessions: sessions,
    );

    if (insights.isEmpty) {
      return _buildEmptyState(
        icon: Icons.auto_awesome_rounded,
        title: 'Keep tracking to unlock personalized insights.',
        message:
            'Add more expenses and tracking sessions to see patterns here.',
      );
    }

    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: insights
            .map(
              (insight) => GeneratedInsightTile(
                insight: insight,
              ),
            )
            .toList(),
      ),
    );
  }

  // ---------------- Spending ----------------

  Widget _buildSpendingSection(List<Expense> expenses) {
    final total = expenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );

    final distinctDays = expenses
        .map((e) => _dateOnly(e.date))
        .toSet();

    final avgDaily = total / distinctDays.length;

    final Map<ExpenseCategory, double> byCategory = {};

    for (final e in expenses) {
      byCategory[e.category] =
          (byCategory[e.category] ?? 0) + e.amount;
    }

    final sortedCategories = byCategory.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    final topCategory = sortedCategories.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InsightStatCard(
                label: 'Total Spending',
                icon: Icons.account_balance_wallet_rounded,
                color: AppColors.primary,
                value: '₹${total.toStringAsFixed(2)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InsightStatCard(
                label: 'Avg. Daily Spending',
                icon: Icons.calendar_today_rounded,
                color: AppColors.secondary,
                value: '₹${avgDaily.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InsightStatCard(
          label: 'Most Spending Category',
          icon: Icons.pie_chart_rounded,
          color: const Color(0xFFFFA726),
          value: topCategory.key.label,
        ),
        const SizedBox(height: 20),

        Text(
          'Spending Distribution',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 12),
        _cardWrapper(
          child: CategoryDistributionChart(
            segments: sortedCategories
                .map(
                  (entry) => ChartSegment(
                    label: entry.key.label,
                    value: entry.value,
                    color: _expenseCategoryColors[entry.key]!,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Category Breakdown',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 4),
        _cardWrapper(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          child: Column(
            children: sortedCategories
                .map(
                  (entry) => ExpenseCategoryRow(
                    category: entry.key,
                    amount: entry.value,
                    shareOfTotal:
                        total == 0 ? 0 : entry.value / total,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Spending Trend',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 12),
        if (distinctDays.length < 2)
          _buildEmptyState(
            icon: Icons.show_chart_rounded,
            title: 'Not enough data for a trend yet',
            message:
                'Add expenses on more than one day to see a trend.',
          )
        else
          _buildSpendingTrendChart(expenses),
      ],
    );
  }

  Widget _buildSpendingTrendChart(List<Expense> expenses) {
    final days = _last7Days();

    final values = days.map((day) {
      return expenses
          .where(
            (e) => _dateOnly(e.date) == day,
          )
          .fold<double>(
            0,
            (sum, e) => sum + e.amount,
          );
    }).toList();

    final labels = days
        .map(
          (day) => _weekdayShort[day.weekday - 1],
        )
        .toList();

    return _cardWrapper(
      child: DailyTrendChart(
        dayLabels: labels,
        values: values,
        barColor: AppColors.primary,
      ),
    );
  }

  // ---------------- Time ----------------

  Widget _buildTimeSection(List<TrackedSession> sessions) {
    final totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + s.duration,
    );

    final Map<TimeCategory, Duration> byCategory = {};

    for (final s in sessions) {
      final category = s.category;
      final duration = s.duration;

      byCategory[category] =
          (byCategory[category] ?? Duration.zero) + duration;
    }

    final sortedCategories = byCategory.entries.toList()
      ..sort(
        (a, b) => b.value.compareTo(a.value),
      );

    final topCategory = sortedCategories.first;

    final distinctDays = sessions
        .map(
          (s) => _dateOnly(s.startTime),
        )
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: InsightStatCard(
                label: 'Total Tracked Time',
                icon: Icons.timer_rounded,
                color: AppColors.primary,
                value: _formatDuration(totalDuration),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InsightStatCard(
                label: 'Most Productive Category',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFFEF5350),
                value: topCategory.key.label,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'Time Distribution',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 12),
        _cardWrapper(
          child: CategoryDistributionChart(
            segments: sortedCategories
                .map(
                  (entry) => ChartSegment(
                    label: entry.key.label,
                    value: entry.value.inMinutes.toDouble(),
                    color: entry.key.color,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),

        Text(
          'Time Tracking Trend',
          style: AppTextStyles.title,
        ),
        const SizedBox(height: 12),
        if (distinctDays.length < 2)
          _buildEmptyState(
            icon: Icons.show_chart_rounded,
            title: 'Not enough data for a trend yet',
            message:
                'Complete tracking sessions on more than one day to see a trend.',
          )
        else
          _buildTimeTrendChart(sessions),
      ],
    );
  }

  Widget _buildTimeTrendChart(List<TrackedSession> sessions) {
    final days = _last7Days();

    final values = days.map((day) {
      final totalMinutes = sessions
          .where(
            (s) => _dateOnly(s.startTime) == day,
          )
          .fold<int>(
            0,
            (sum, s) => sum + s.duration.inMinutes,
          );

      return totalMinutes.toDouble();
    }).toList();

    final labels = days
        .map(
          (day) => _weekdayShort[day.weekday - 1],
        )
        .toList();

    return _cardWrapper(
      child: DailyTrendChart(
        dayLabels: labels,
        values: values,
        barColor: AppColors.secondary,
      ),
    );
  }

  // ---------------- Shared ----------------

  Widget _cardWrapper({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.background,
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.background,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 40,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
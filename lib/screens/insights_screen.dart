import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/time_category.dart';
import '../services/expense_service.dart';
import '../services/tracking_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/insight_stat_card.dart';
import '../widgets/expense_category_row.dart';

/// Insights tab: summary statistics derived from the existing
/// TrackingService and ExpenseService. Read-only — never mutates
/// either service.
class InsightsScreen extends StatelessWidget {
  final TrackingService trackingService;
  final ExpenseService expenseService;

  const InsightsScreen({
    super.key,
    required this.trackingService,
    required this.expenseService,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          // Rebuild when a session completes or an expense is added.
          animation: Listenable.merge([trackingService, expenseService]),
          builder: (context, _) {
            final expenses = expenseService.expenses;
            final sessions = trackingService.completedSessions;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Insights', style: AppTextStyles.headline),
                  const SizedBox(height: 4),
                  Text(
                    'Understand your spending and time patterns',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Spending Overview', style: AppTextStyles.title),
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

                  Text('Time Overview', style: AppTextStyles.title),
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

  // ---------------- Spending ----------------

  Widget _buildSpendingSection(List<Expense> expenses) {
    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

    final distinctDays =
        expenses.map((e) => _dateOnly(e.date)).toSet().length;
    final avgDaily = total / distinctDays;

    final Map<ExpenseCategory, double> byCategory = {};
    for (final e in expenses) {
      byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
    }
    final sortedCategories = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = sortedCategories.first;

    // Weekly trend: spending in the last 7 days vs the 7 days before that.
    final now = DateTime.now();
    final startOfThisWeek = _dateOnly(now).subtract(const Duration(days: 6));
    final startOfLastWeek =
        startOfThisWeek.subtract(const Duration(days: 7));

    final thisWeekTotal = expenses
        .where((e) => !_dateOnly(e.date).isBefore(startOfThisWeek))
        .fold<double>(0, (sum, e) => sum + e.amount);
    final lastWeekTotal = expenses
        .where(
          (e) =>
              !_dateOnly(e.date).isBefore(startOfLastWeek) &&
              _dateOnly(e.date).isBefore(startOfThisWeek),
        )
        .fold<double>(0, (sum, e) => sum + e.amount);

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

        Text('Category Breakdown', style: AppTextStyles.title),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.background, width: 1.5),
          ),
          child: Column(
            children: sortedCategories
                .map(
                  (entry) => ExpenseCategoryRow(
                    category: entry.key,
                    amount: entry.value,
                    shareOfTotal: total == 0 ? 0 : entry.value / total,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),

        Text('Recent Trend', style: AppTextStyles.title),
        const SizedBox(height: 12),
        _buildTrendCard(thisWeekTotal, lastWeekTotal),
      ],
    );
  }

  /// Shows spending over the last 7 days, and a comparison to the
  /// previous 7 days only when there is data for that earlier period
  /// (otherwise a trend comparison would be misleading).
  Widget _buildTrendCard(double thisWeekTotal, double lastWeekTotal) {
    String? trendText;
    IconData trendIcon = Icons.trending_flat_rounded;
    Color trendColor = AppColors.textSecondary;

    if (lastWeekTotal > 0) {
      final change = ((thisWeekTotal - lastWeekTotal) / lastWeekTotal) * 100;
      if (change > 0) {
        trendText = 'Up ${change.toStringAsFixed(0)}% vs last week';
        trendIcon = Icons.trending_up_rounded;
        trendColor = AppColors.error;
      } else if (change < 0) {
        trendText = 'Down ${change.abs().toStringAsFixed(0)}% vs last week';
        trendIcon = Icons.trending_down_rounded;
        trendColor = AppColors.success;
      } else {
        trendText = 'Same as last week';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(trendIcon, color: trendColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 7 days: ₹${thisWeekTotal.toStringAsFixed(2)}',
                  style: AppTextStyles.body,
                ),
                if (trendText != null) ...[
                  const SizedBox(height: 2),
                  Text(trendText, style: AppTextStyles.caption),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Time ----------------

  Widget _buildTimeSection(List sessions) {
    final totalDuration = sessions.fold<Duration>(
      Duration.zero,
      (sum, s) => sum + (s.duration as Duration),
    );

    final Map<TimeCategory, Duration> byCategory = {};
    for (final s in sessions) {
      final category = s.category as TimeCategory;
      final duration = s.duration as Duration;
      byCategory[category] = (byCategory[category] ?? Duration.zero) + duration;
    }
    final topCategory = byCategory.entries.reduce(
      (a, b) => a.value >= b.value ? a : b,
    );

    return Row(
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
    );
  }

  // ---------------- Shared empty state ----------------

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
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.title, textAlign: TextAlign.center),
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
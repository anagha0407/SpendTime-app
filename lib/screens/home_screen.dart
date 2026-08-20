import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../services/tracking_service.dart';
import '../services/expense_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/budget_dialog.dart';
import '../widgets/active_session_card.dart';
import '../widgets/activity_tile.dart';
import '../widgets/budget_card.dart';
import '../widgets/category_tile.dart';
import '../widgets/expense_list_section.dart';
import '../widgets/overview_card.dart';
import 'tracking_screen.dart';
import 'add_expense_screen.dart';

/// SpendTime dashboard/home screen. Reflects live TrackingService and
/// ExpenseService state.
class HomeScreen extends StatelessWidget {
  final TrackingService trackingService;
  final ExpenseService expenseService;

  const HomeScreen({
    super.key,
    required this.trackingService,
    required this.expenseService,
  });

  String _formattedDate() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final now = DateTime.now();
    final weekday = weekdays[now.weekday - 1];
    return '$weekday, ${months[now.month - 1]} ${now.day}';
  }

  void _openTrackingScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TrackingScreen(trackingService: trackingService),
      ),
    );
  }

  void _openAddExpenseScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(expenseService: expenseService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          // Listen to BOTH services, so Home rebuilds whether a
          // tracking session changes or an expense/budget changes.
          animation: Listenable.merge([trackingService, expenseService]),
          builder: (context, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SpendTime', style: AppTextStyles.headline),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome back — here\'s how your day looks.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(_formattedDate(), style: AppTextStyles.caption),
                  const SizedBox(height: 20),

                  if (trackingService.isTracking) ...[
                    ActiveSessionCard(
                      activityName: trackingService.activeActivityName!,
                      category: trackingService.activeCategory!,
                      elapsed: trackingService.elapsed,
                      isPaused: trackingService.isPaused,
                      onTap: () => _openTrackingScreen(context),
                    ),
                    const SizedBox(height: 20),
                  ],

                  OverviewCard(
                    total: trackingService.todayTotal,
                    goal: const Duration(hours: 8),
                  ),
                  const SizedBox(height: 24),

                  BudgetCard(
                    expenseService: expenseService,
                    onEditBudget: () =>
                        showSetBudgetDialog(context, expenseService),
                  ),
                  const SizedBox(height: 24),

                  Text('Categories', style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  ...MockData.categories.map(
                    (category) => CategoryTile(category: category),
                  ),
                  const SizedBox(height: 16),

                  Text('Recent Activity', style: AppTextStyles.title),
                  const SizedBox(height: 8),
                  if (trackingService.completedSessions.isEmpty)
                    Text(
                      'No sessions yet — start tracking to see them here.',
                      style: AppTextStyles.caption,
                    )
                  else
                    ...trackingService.completedSessions.map(
                      (session) => ActivityTile(session: session),
                    ),
                  const SizedBox(height: 16),

                  ExpenseListSection(expenseService: expenseService),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: trackingService.isTracking
                          ? null
                          : () => _openTrackingScreen(context),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        trackingService.isTracking
                            ? 'Tracking in progress'
                            : 'Start Tracking',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openAddExpenseScreen(context),
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('Add Expense'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
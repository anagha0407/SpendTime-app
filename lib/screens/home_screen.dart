import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/overview_card.dart';
import '../widgets/category_tile.dart';
import '../widgets/activity_tile.dart';

/// SpendTime dashboard/home screen.
/// All data shown here is mock data from MockData for now.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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

              // Today's overview
              OverviewCard(
                total: MockData.todayTotal,
                goal: MockData.todayGoal,
              ),
              const SizedBox(height: 24),

              // Categories
              Text('Categories', style: AppTextStyles.title),
              const SizedBox(height: 8),
              ...MockData.categories.map(
                (category) => CategoryTile(category: category),
              ),
              const SizedBox(height: 16),

              // Recent activity
              Text('Recent Activity', style: AppTextStyles.title),
              const SizedBox(height: 8),
              ...MockData.recentActivities.map(
                (activity) => ActivityTile(activity: activity),
              ),
              const SizedBox(height: 8),

              // Primary action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Placeholder for future tracking feature.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tracking coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Tracking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../models/category_time.dart';
import '../models/recent_activity.dart';
import '../theme/app_colors.dart';

/// Static mock data for the dashboard.
///
/// This file is the single place that fakes a data source. When real
/// persistence/API is added later, screens should get this data from
/// a service/provider instead — the models above stay the same.
class MockData {
  MockData._();

  static const Duration todayTotal = Duration(hours: 5, minutes: 42);
  static const Duration todayGoal = Duration(hours: 8);

  static const List<CategoryTime> categories = [
    CategoryTime(
      name: 'Study',
      icon: Icons.menu_book_rounded,
      duration: Duration(hours: 2, minutes: 15),
      percentage: 0.40,
      color: AppColors.primary,
    ),
    CategoryTime(
      name: 'Work',
      icon: Icons.work_rounded,
      duration: Duration(hours: 1, minutes: 50),
      percentage: 0.32,
      color: AppColors.secondary,
    ),
    CategoryTime(
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      duration: Duration(minutes: 40),
      percentage: 0.12,
      color: Color(0xFFFFA726),
    ),
    CategoryTime(
      name: 'Exercise',
      icon: Icons.fitness_center_rounded,
      duration: Duration(minutes: 35),
      percentage: 0.10,
      color: Color(0xFFEF5350),
    ),
    CategoryTime(
      name: 'Other',
      icon: Icons.more_horiz_rounded,
      duration: Duration(minutes: 22),
      percentage: 0.06,
      color: AppColors.textSecondary,
    ),
  ];

  static const List<RecentActivity> recentActivities = [
    RecentActivity(
      title: 'Flutter Course',
      category: 'Study',
      duration: Duration(minutes: 45),
      timeAgo: '1h ago',
    ),
    RecentActivity(
      title: 'Client Meeting',
      category: 'Work',
      duration: Duration(minutes: 30),
      timeAgo: '3h ago',
    ),
    RecentActivity(
      title: 'Evening Run',
      category: 'Exercise',
      duration: Duration(minutes: 25),
      timeAgo: '5h ago',
    ),
    RecentActivity(
      title: 'YouTube',
      category: 'Entertainment',
      duration: Duration(minutes: 20),
      timeAgo: '6h ago',
    ),
  ];
}
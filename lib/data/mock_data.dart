import 'package:flutter/material.dart';
import '../models/category_time.dart';
import '../theme/app_colors.dart';

/// Static mock data for the category breakdown chart only.
///
/// Recent activity and today's total are now real, derived from
/// TrackingService — see lib/services/tracking_service.dart.
class MockData {
  MockData._();

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
}
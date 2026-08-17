import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum TimeCategory {
  study,
  work,
  entertainment,
  exercise,
  other,
}

extension TimeCategoryDisplay on TimeCategory {
  String get label {
    switch (this) {
      case TimeCategory.study:
        return 'Study';
      case TimeCategory.work:
        return 'Work';
      case TimeCategory.entertainment:
        return 'Entertainment';
      case TimeCategory.exercise:
        return 'Exercise';
      case TimeCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TimeCategory.study:
        return Icons.menu_book_rounded;
      case TimeCategory.work:
        return Icons.work_rounded;
      case TimeCategory.entertainment:
        return Icons.movie_rounded;
      case TimeCategory.exercise:
        return Icons.fitness_center_rounded;
      case TimeCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TimeCategory.study:
        return AppColors.primary;
      case TimeCategory.work:
        return AppColors.secondary;
      case TimeCategory.entertainment:
        return const Color(0xFFFFA726);
      case TimeCategory.exercise:
        return const Color(0xFFEF5350);
      case TimeCategory.other:
        return AppColors.textSecondary;
    }
  }
}
import 'package:flutter/material.dart';
import '../models/category_time.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Row showing one time category with an icon, duration, and progress bar.
class CategoryTile extends StatelessWidget {
  final CategoryTime category;

  const CategoryTile({super.key, required this.category});

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(category.name, style: AppTextStyles.body),
                    Text(
                      _formatDuration(category.duration),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: category.percentage,
                    minHeight: 6,
                    backgroundColor: AppColors.background,
                    valueColor: AlwaysStoppedAnimation<Color>(category.color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
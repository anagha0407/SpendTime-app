import 'package:flutter/material.dart';
import '../models/recent_activity.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Row showing one recent activity entry.
class ActivityTile extends StatelessWidget {
  final RecentActivity activity;

  const ActivityTile({super.key, required this.activity});

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text(
                  '${activity.category} • ${activity.timeAgo}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(activity.duration),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
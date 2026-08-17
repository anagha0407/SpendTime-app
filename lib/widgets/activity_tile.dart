import 'package:flutter/material.dart';
import '../models/tracked_session.dart';
import '../models/time_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Row showing one completed tracked session.
class ActivityTile extends StatelessWidget {
  final TrackedSession session;

  const ActivityTile({super.key, required this.session});

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  String _timeAgo(DateTime endTime) {
    final diff = DateTime.now().difference(endTime);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: session.category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              session.category.icon,
              color: session.category.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.activityName, style: AppTextStyles.body),
                const SizedBox(height: 2),
                Text(
                  '${session.category.label} • ${_timeAgo(session.endTime)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(session.duration),
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
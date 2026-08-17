import 'package:flutter/material.dart';
import '../models/time_category.dart';
import '../theme/app_text_styles.dart';

/// Compact card shown on Home while a session is actively running.
/// Tapping it opens the full tracking screen.
class ActiveSessionCard extends StatelessWidget {
  final String activityName;
  final TimeCategory category;
  final Duration elapsed;
  final VoidCallback onTap;

  const ActiveSessionCard({
    super.key,
    required this.activityName,
    required this.category,
    required this.elapsed,
    required this.onTap,
  });

  String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:'
        '${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: category.color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: category.color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking now',
                    style: AppTextStyles.caption.copyWith(
                      color: category.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$activityName • ${category.label}',
                    style: AppTextStyles.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatElapsed(elapsed),
              style: AppTextStyles.title.copyWith(color: category.color),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/insight_generator.dart';

/// Displays one generated insight as a row with an icon that reflects
/// its tone (positive/negative/neutral/warning).
class GeneratedInsightTile extends StatelessWidget {
  final GeneratedInsight insight;

  const GeneratedInsightTile({super.key, required this.insight});

  IconData get _icon {
    switch (insight.tone) {
      case InsightTone.positive:
        return Icons.thumb_up_alt_rounded;
      case InsightTone.negative:
        return Icons.trending_up_rounded;
      case InsightTone.warning:
        return Icons.warning_amber_rounded;
      case InsightTone.neutral:
        return Icons.insights_rounded;
    }
  }

  Color get _color {
    switch (insight.tone) {
      case InsightTone.positive:
        return AppColors.success;
      case InsightTone.negative:
        return AppColors.error;
      case InsightTone.warning:
        return const Color(0xFFFFA726);
      case InsightTone.neutral:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(insight.text, style: AppTextStyles.body),
            ),
          ),
        ],
      ),
    );
  }
}
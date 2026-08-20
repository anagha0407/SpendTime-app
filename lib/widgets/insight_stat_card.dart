import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// A single stat card for the Insights screen.
///
/// Shows [value] when data exists. When [value] is null, shows
/// [emptyText] instead so we never display a misleading "0" or
/// fabricated number where no real data exists yet.
class InsightStatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String? value;
  final String emptyText;

  const InsightStatCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    this.emptyText = 'No data yet',
  });

  @override
  Widget build(BuildContext context) {
    final hasData = value != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 4),
          Text(
            hasData ? value! : emptyText,
            style: hasData
                ? AppTextStyles.title
                : AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
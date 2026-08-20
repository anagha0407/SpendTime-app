import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// One slice of a category distribution chart. This is a view-only
/// struct for rendering — not a data model, and not persisted anywhere.
class ChartSegment {
  final String label;
  final double value;
  final Color color;

  const ChartSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// A single stacked horizontal bar showing how a total is split across
/// categories, with a legend (color dot + label + percentage) below it.
class CategoryDistributionChart extends StatelessWidget {
  final List<ChartSegment> segments;

  const CategoryDistributionChart({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    final nonZero = segments.where((s) => s.value > 0).toList();
    final total = nonZero.fold<double>(0, (sum, s) => sum + s.value);

    if (nonZero.isEmpty || total <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            height: 20,
            child: Row(
              children: nonZero.map((segment) {
                // flex must be a positive int, scaled from the share
                // of the total so every segment stays visible.
                final flex = ((segment.value / total) * 1000)
                    .round()
                    .clamp(1, 1000);
                return Expanded(
                  flex: flex,
                  child: Container(color: segment.color),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: nonZero.map((segment) {
            final percentage = (segment.value / total) * 100;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: segment.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${segment.label} ${percentage.toStringAsFixed(0)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
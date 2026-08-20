import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// A simple day-by-day bar chart. Each bar's height is proportional
/// to its value relative to the highest value in the set — no
/// external chart library needed for this.
class DailyTrendChart extends StatelessWidget {
  final List<String> dayLabels; // e.g. ['Mon', 'Tue', ...]
  final List<double> values; // same length as dayLabels
  final Color barColor;

  const DailyTrendChart({
    super.key,
    required this.dayLabels,
    required this.values,
    required this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          // A tiny minimum height keeps zero-value days visible as a
          // thin sliver rather than disappearing completely.
          final heightFactor = maxValue <= 0
              ? 0.02
              : (values[i] / maxValue).clamp(0.02, 1.0);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 90,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: heightFactor,
                        child: Container(
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(dayLabels[i], style: AppTextStyles.caption),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
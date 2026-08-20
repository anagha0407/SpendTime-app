import 'package:flutter/material.dart';
import '../models/lap.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Row showing one recorded lap: lap number and total elapsed time
/// at the moment it was recorded.
class LapRow extends StatelessWidget {
  final Lap lap;

  const LapRow({super.key, required this.lap});

  String _formatElapsed(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:'
        '${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Lap ${lap.number}', style: AppTextStyles.body),
          Text(
            _formatElapsed(lap.elapsedAtLap),
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
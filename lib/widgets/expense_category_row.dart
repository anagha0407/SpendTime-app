import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// One row in the category-wise spending breakdown: category name,
/// amount spent, and a progress bar showing its share of total spend.
class ExpenseCategoryRow extends StatelessWidget {
  final ExpenseCategory category;
  final double amount;
  final double shareOfTotal; // 0.0 - 1.0

  const ExpenseCategoryRow({
    super.key,
    required this.category,
    required this.amount,
    required this.shareOfTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.label, style: AppTextStyles.body),
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: shareOfTotal,
              minHeight: 6,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
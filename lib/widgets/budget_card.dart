import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Displays the current month's budget, amount spent, amount
/// remaining, and a progress indicator. Shows a clean "set a budget"
/// prompt when no budget has been set for the current month yet.
class BudgetCard extends StatelessWidget {
  final ExpenseService expenseService;
  final VoidCallback onEditBudget;

  const BudgetCard({
    super.key,
    required this.expenseService,
    required this.onEditBudget,
  });

  String _money(double amount) => '₹${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final budget = expenseService.currentMonthBudget;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: budget == null
          ? _buildNoBudgetState()
          : _buildBudgetSummary(budget),
    );
  }

  Widget _buildNoBudgetState() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No budget set for this month', style: AppTextStyles.body),
              const SizedBox(height: 2),
              Text(
                'Set a budget to track your spending.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onEditBudget,
          child: const Text('Set Budget'),
        ),
      ],
    );
  }

  Widget _buildBudgetSummary(double budget) {
    final spent = expenseService.currentMonthSpent;
    final remaining = budget - spent;
    final isOverBudget = remaining < 0;

    // Guard against division-by-zero (budget of exactly 0) and clamp
    // so the progress bar never overflows past 100%, even when
    // spending exceeds the budget.
    final progress = budget <= 0 ? 0.0 : (spent / budget).clamp(0.0, 1.0);
    final progressPercentText = budget <= 0
        ? '0%'
        : '${((spent / budget) * 100).toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Monthly Budget', style: AppTextStyles.title),
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 18),
              color: AppColors.textSecondary,
              onPressed: onEditBudget,
              tooltip: 'Edit budget',
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(_money(budget), style: AppTextStyles.headline.copyWith(fontSize: 26)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spent', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    _money(spent),
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Remaining', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    isOverBudget
                        ? '- ${_money(remaining.abs())}'
                        : _money(remaining),
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOverBudget ? AppColors.error : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(
              isOverBudget ? AppColors.error : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isOverBudget
              ? 'Over budget by ${_money(remaining.abs())} ($progressPercentText used)'
              : '$progressPercentText used',
          style: AppTextStyles.caption.copyWith(
            color: isOverBudget ? AppColors.error : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
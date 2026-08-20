import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'expense_tile.dart';

/// Sort orders available for the Recent Expenses list.
enum ExpenseSortOption { newestFirst, oldestFirst, highestAmount, lowestAmount }

extension ExpenseSortOptionLabel on ExpenseSortOption {
  String get label {
    switch (this) {
      case ExpenseSortOption.newestFirst:
        return 'Newest first';
      case ExpenseSortOption.oldestFirst:
        return 'Oldest first';
      case ExpenseSortOption.highestAmount:
        return 'Highest amount';
      case ExpenseSortOption.lowestAmount:
        return 'Lowest amount';
    }
  }
}

/// Displays ExpenseService's expenses with category filter and sort
/// controls. This widget only changes what is DISPLAYED — it never
/// mutates ExpenseService.expenses, and edit/delete (via ExpenseTile)
/// keep operating on the real underlying expense, filtered view or not.
class ExpenseListSection extends StatefulWidget {
  final ExpenseService expenseService;

  const ExpenseListSection({super.key, required this.expenseService});

  @override
  State<ExpenseListSection> createState() => _ExpenseListSectionState();
}

class _ExpenseListSectionState extends State<ExpenseListSection> {
  ExpenseCategory? _selectedCategory; // null means "All"
  ExpenseSortOption _selectedSort = ExpenseSortOption.newestFirst;

  /// Returns a new filtered + sorted list. The source list from
  /// ExpenseService is never modified.
  List<Expense> _filteredAndSorted(List<Expense> source) {
    final filtered = _selectedCategory == null
        ? List<Expense>.from(source)
        : source.where((e) => e.category == _selectedCategory).toList();

    switch (_selectedSort) {
      case ExpenseSortOption.newestFirst:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case ExpenseSortOption.oldestFirst:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case ExpenseSortOption.highestAmount:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case ExpenseSortOption.lowestAmount:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return filtered;
  }

  Widget _buildSortButton() {
    return PopupMenuButton<ExpenseSortOption>(
      initialValue: _selectedSort,
      onSelected: (value) => setState(() => _selectedSort = value),
      itemBuilder: (context) {
        return ExpenseSortOption.values.map((option) {
          final isSelected = option == _selectedSort;
          return PopupMenuItem(
            value: option,
            child: Row(
              children: [
                Icon(
                  Icons.check,
                  size: 16,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                const SizedBox(width: 8),
                Text(option.label),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.background, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sort_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(_selectedSort.label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final options = <ExpenseCategory?>[null, ...ExpenseCategory.values];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((category) {
        final isSelected = category == _selectedCategory;
        final label = category == null ? 'All' : category.label;

        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedCategory = category),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: BorderSide(color: AppColors.background),
          labelStyle: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allExpenses = widget.expenseService.expenses;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Expenses', style: AppTextStyles.title),
            if (allExpenses.isNotEmpty) _buildSortButton(),
          ],
        ),
        const SizedBox(height: 8),

        if (allExpenses.isEmpty)
          Text('No expenses yet', style: AppTextStyles.caption)
        else ...[
          _buildFilterChips(),
          const SizedBox(height: 12),
          Builder(
            builder: (context) {
              final displayed = _filteredAndSorted(allExpenses);
              if (displayed.isEmpty) {
                return Text(
                  'No expenses match this filter',
                  style: AppTextStyles.caption,
                );
              }
              return Column(
                children: displayed
                    .map(
                      (expense) => ExpenseTile(
                        expense: expense,
                        expenseService: widget.expenseService,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared confirmation dialog for deleting an expense.
/// Returns true if the user confirmed, false (or null->false) if
/// they cancelled or dismissed the dialog.
Future<bool> showDeleteExpenseDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text(
          'Are you sure you want to delete this expense? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      );
    },
  );

  return confirmed ?? false;
}
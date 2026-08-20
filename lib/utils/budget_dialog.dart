import 'package:flutter/material.dart';
import '../services/expense_service.dart';

/// Shows a dialog for setting/updating the current month's budget.
/// Pre-fills the existing budget amount if one is already set.
Future<void> showSetBudgetDialog(
  BuildContext context,
  ExpenseService expenseService,
) async {
  final currentBudget = expenseService.currentMonthBudget;
  final controller = TextEditingController(
    text: currentBudget != null ? currentBudget.toStringAsFixed(2) : '',
  );
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: '₹ ',
              hintText: '0.00',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter a budget amount';
              }
              final amount = double.tryParse(value.trim());
              if (amount == null || amount <= 0) {
                return 'Enter a valid amount';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              final amount = double.parse(controller.text.trim());
              expenseService.setBudgetForMonth(DateTime.now(), amount);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
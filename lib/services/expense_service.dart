import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ExpenseService extends ChangeNotifier {
  final List<Expense> _expenses = [];

  // The single key we store all expenses under in SharedPreferences.
  static const String _storageKey = 'expenses';

  List<Expense> get expenses => List.unmodifiable(_expenses);

  /// Reads any previously saved expenses from disk.
  /// Call this once, right after creating the ExpenseService.
  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList(_storageKey);

    if (savedList == null) {
      // Nothing saved yet (first ever launch) — nothing to load.
      return;
    }

    _expenses.clear();
    for (final jsonString in savedList) {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      _expenses.add(Expense.fromJson(map));
    }

    notifyListeners();
  }

  void addExpense({
    required double amount,
    required ExpenseCategory category,
    required DateTime date,
    required String description,
  }) {
    final expense = Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amount: amount,
      category: category,
      date: date,
      description: description.trim(),
    );

    _expenses.insert(0, expense);
    notifyListeners();

    // Persist in the background so the UI isn't blocked waiting on disk.
    _saveExpenses();
  }

  /// Replaces an existing expense (matched by id) with updated values.
  /// Does nothing if no expense with that id exists.
  void updateExpense(Expense updatedExpense) {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index == -1) return;

    _expenses[index] = updatedExpense;
    notifyListeners();
    _saveExpenses();
  }

  /// Removes the expense with the given id, if it exists.
  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    _saveExpenses();
  }

  /// Writes the full current expense list to SharedPreferences.
  /// Each expense is stored as its own JSON string, all inside one
  /// List<String> saved under a single key.
  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _expenses.map((expense) {
      return jsonEncode(expense.toJson());
    }).toList();

    await prefs.setStringList(_storageKey, jsonList);
  }
}
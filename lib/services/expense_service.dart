import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ExpenseService extends ChangeNotifier {
  final List<Expense> _expenses = [];

  // The single key we store all expenses under in SharedPreferences.
  static const String _storageKey = 'expenses';

  // Monthly budgets, keyed by "yyyy-MM" (e.g. "2026-08"), stored
  // under a single separate SharedPreferences key so each calendar
  // month has its own independent budget.
  final Map<String, double> _monthlyBudgets = {};
  static const String _budgetStorageKey = 'monthly_budgets';

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

  // ==================== Monthly Budget ====================

  /// Turns a date into its "yyyy-MM" month key, e.g. 2026-08-21 -> "2026-08".
  String _monthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// The budget set for the given month, or null if none was set.
  double? getBudgetForMonth(DateTime month) {
    return _monthlyBudgets[_monthKey(month)];
  }

  /// The budget for the current calendar month, or null if unset.
  double? get currentMonthBudget => getBudgetForMonth(DateTime.now());

  /// Sets (or updates) the budget for the given month.
  Future<void> setBudgetForMonth(DateTime month, double amount) async {
    _monthlyBudgets[_monthKey(month)] = amount;
    notifyListeners();
    await _saveBudgets();
  }

  /// Sum of all expenses whose date falls within the given month.
  double spentInMonth(DateTime month) {
    return _expenses
        .where(
          (e) => e.date.year == month.year && e.date.month == month.month,
        )
        .fold<double>(0, (sum, e) => sum + e.amount);
  }

  /// Total spent so far in the current calendar month.
  double get currentMonthSpent => spentInMonth(DateTime.now());

  /// Reads all saved monthly budgets from disk.
  /// Call this once, alongside loadExpenses(), at app startup.
  Future<void> loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_budgetStorageKey);

    if (jsonString == null) {
      // No budgets saved yet — nothing to load.
      return;
    }

    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    _monthlyBudgets.clear();
    map.forEach((key, value) {
      _monthlyBudgets[key] = (value as num).toDouble();
    });

    notifyListeners();
  }

  /// Writes all monthly budgets to SharedPreferences as one JSON object,
  /// e.g. {"2026-08": 10000.0, "2026-09": 12000.0}.
  Future<void> _saveBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_budgetStorageKey, jsonEncode(_monthlyBudgets));
  }
}
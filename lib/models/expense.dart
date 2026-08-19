enum ExpenseCategory {
  food,
  travel,
  shopping,
  bills,
  entertainment,
  education,
  other,
}

extension ExpenseCategoryDisplay on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.other:
        return 'Other';
    }
  }
}

class Expense {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String description;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  /// Converts this expense into a simple Map of basic types
  /// (String, num), which can then be turned into a JSON string.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name, // enum -> plain string, e.g. "food"
      'date': date.toIso8601String(), // DateTime -> plain string
      'description': description,
    };
  }

  /// Rebuilds an Expense from a Map that was decoded from JSON.
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.byName(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
    );
  }
}
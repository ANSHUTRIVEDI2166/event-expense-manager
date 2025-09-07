class Event {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String venue;
  final String organizer;
  final List<Expense> expenses;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.venue,
    required this.organizer,
    List<Expense>? expenses,
  }) : expenses = expenses ?? [];

  double get totalExpenses {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String vendorName;
  final String category;
  final DateTime date;
  final String? description;
  final String? receipt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.vendorName,
    required this.category,
    required this.date,
    this.description,
    this.receipt,
  });
}

class ExpenseCategory {
  static const List<String> categories = [
    'Venue',
    'Food & Beverages',
    'Decoration',
    'Sound & Lighting',
    'Entertainment',
    'Transportation',
    'Marketing',
    'Security',
    'Photography',
    'Others',
  ];
}

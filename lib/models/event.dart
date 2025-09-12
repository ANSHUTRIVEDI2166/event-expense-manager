class Event {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String venue;
  final String organizer;
  // Note: We remove the 'expenses' list from the main Event model for now.
  // Expenses will be fetched separately for each event to keep the logic clean.
  // We will also re-calculate totalExpenses based on real-time data.

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.venue,
    required this.organizer,
  });

  // --- NEW: Factory constructor to create an Event from a map (JSON) ---
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      venue: json['venue'],
      organizer: json['organizer'],
    );
  }
}

// The Expense model is now more aligned with the 'expense_requests' table.
class Expense {
  final String id;
  final String title;
  final double amount;
  final String vendorName;
  final String category;
  final DateTime date;
  final String? description;
  final String? receiptUrl; // Changed from 'receipt' to 'receiptUrl'
  final String status; // New field for tracking approval status

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.vendorName,
    required this.category,
    required this.date,
    required this.status,
    this.description,
    this.receiptUrl,
  });

  // --- NEW: Factory constructor for Expense ---
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      // The amount from Supabase might be a String or number, so we parse robustly.
      amount: double.parse(json['amount'].toString()),
      vendorName: json['vendor_name'],
      category: json['category'],
      date:
          DateTime.parse(json['created_at']), // Using created_at for simplicity
      status: json['status'],
      description: json['description'],
      receiptUrl: json['receipt_url'],
    );
  }
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

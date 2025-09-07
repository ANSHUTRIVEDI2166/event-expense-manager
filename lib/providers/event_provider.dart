import 'package:flutter/material.dart';
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  final List<Event> _events = [];
  final List<Expense> _allExpenses = [];

  List<Event> get events => _events;
  List<Expense> get allExpenses => _allExpenses;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void updateEvent(Event updatedEvent) {
    final index = _events.indexWhere((event) => event.id == updatedEvent.id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  void deleteEvent(String eventId) {
    _events.removeWhere((event) => event.id == eventId);
    _allExpenses.removeWhere((expense) => expense.id.startsWith(eventId));
    notifyListeners();
  }

  void addExpenseToEvent(String eventId, Expense expense) {
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex != -1) {
      _events[eventIndex].expenses.add(expense);
      _allExpenses.add(expense);
      notifyListeners();
    }
  }

  void deleteExpense(String eventId, String expenseId) {
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex != -1) {
      _events[eventIndex].expenses.removeWhere(
        (expense) => expense.id == expenseId,
      );
      _allExpenses.removeWhere((expense) => expense.id == expenseId);
      notifyListeners();
    }
  }

  List<Expense> getExpensesForEvent(String eventId) {
    final event = _events.firstWhere((event) => event.id == eventId);
    return event.expenses;
  }

  double getTotalExpensesForEvent(String eventId) {
    final event = _events.firstWhere((event) => event.id == eventId);
    return event.totalExpenses;
  }

  double get totalBudget {
    return _allExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}

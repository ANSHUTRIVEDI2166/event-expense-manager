import 'package:flutter/material.dart';
import '../providers/supabase_service.dart';
import '../models/event.dart';
import 'request_expense_screen.dart'; // Updated import

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final SupabaseService _supabaseService = SupabaseService();

  // Function to refresh the expenses list (still useful for after adding expense)
  void _refreshExpenses() {
    // This method is kept for compatibility but may not be needed with streams
    setState(() {});
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
            'Are you sure you want to delete "${widget.event.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _supabaseService.deleteEvent(widget.event.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Go back to previous screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting event: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.event.name),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            FutureBuilder<bool>(
              future: _supabaseService.canUserDeleteEvent(widget.event.id),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteConfirmation(context),
                    tooltip: 'Delete Event',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Info Card (displays instantly)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Event Details',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                            Icons.event, 'Event Name', widget.event.name),
                        _buildInfoRow(Icons.description, 'Description',
                            widget.event.description),
                        _buildInfoRow(Icons.calendar_today, 'Date',
                            _formatDate(widget.event.date)),
                        _buildInfoRow(
                            Icons.location_on, 'Venue', widget.event.venue),
                        _buildInfoRow(
                            Icons.person, 'Organizer', widget.event.organizer),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Expenses Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Expenses',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RequestExpenseScreen(eventId: widget.event.id),
                          ),
                        );
                        // When we return from the request screen, refresh the list
                        _refreshExpenses();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // StreamBuilder for the Expenses List
                StreamBuilder<List<Expense>>(
                  stream: _supabaseService
                      .getExpensesForEventStream(widget.event.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    final expenses = snapshot.data;
                    if (expenses == null || expenses.isEmpty) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No expenses submitted yet.'),
                      ));
                    }

                    final totalApprovedExpenses = expenses
                        .where((exp) => exp.status == 'approved')
                        .fold(0.0, (sum, item) => sum + item.amount);

                    return Column(
                      children: [
                        // Budget Summary Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Approved Expenses:',
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                  '₹${totalApprovedExpenses.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Expenses List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return _buildExpenseCard(context, expense);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }

  // --- Helper Widgets ---

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(expense.status),
          child: Icon(_getStatusIcon(expense.status),
              color: Colors.white, size: 20),
        ),
        title: Text(expense.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
            'Status: ${expense.status[0].toUpperCase()}${expense.status.substring(1)}'),
        trailing: Text(
          '₹${expense.amount.toStringAsFixed(2)}',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}

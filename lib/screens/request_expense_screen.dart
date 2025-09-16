import 'package:flutter/material.dart';
import '../models/event.dart';
import '../providers/supabase_service.dart';

class RequestExpenseScreen extends StatefulWidget {
  final String eventId;
  const RequestExpenseScreen({super.key, required this.eventId});

  @override
  State<RequestExpenseScreen> createState() => _RequestExpenseScreenState();
}

class _RequestExpenseScreenState extends State<RequestExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = ExpenseCategory.categories.first;
  DateTime _selectedDate = DateTime.now();
  // Removed receipt image logic
  bool _isLoading = false;

  final SupabaseService _supabaseService = SupabaseService();
  // Removed image picker

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _vendorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Removed pickReceipt method

  Future<void> _submitRequest() async {
    // Removed receipt image validation
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _supabaseService.createExpenseRequest(
          eventId: widget.eventId,
          title: _titleController.text,
          amount: double.parse(_amountController.text),
          vendorName: _vendorController.text,
          category: _selectedCategory,
          date: _selectedDate,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          // Removed receiptImage
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Expense request submitted successfully!'),
              backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error submitting request: $e'),
              backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now());
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Request Expense'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      labelText: 'Expense Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title)),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter title' : null),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                      labelText: 'Amount (₹)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.currency_rupee)),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(v) == null) {
                      return 'Enter a valid number';
                    }
                    if (double.parse(v) <= 0) {
                      return 'Amount must be > 0';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _vendorController,
                  decoration: const InputDecoration(
                      labelText: 'Vendor Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store)),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Please enter vendor' : null),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category)),
                  items: ExpenseCategory.categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!)),
              const SizedBox(height: 16),
              ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Expense Date'),
                  subtitle: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _selectDate,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300))),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description)),
                  maxLines: 3),
              const SizedBox(height: 16),
              // Receipt upload UI removed
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Submit Request',
                          style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }
}

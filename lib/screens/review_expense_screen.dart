import 'package:flutter/material.dart';
import '../models/event.dart';
import '../providers/supabase_service.dart';

class ReviewExpenseScreen extends StatefulWidget {
  final Expense expense;
  const ReviewExpenseScreen({super.key, required this.expense});

  @override
  State<ReviewExpenseScreen> createState() => _ReviewExpenseScreenState();
}

class _ReviewExpenseScreenState extends State<ReviewExpenseScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final _rejectionReasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _approveRequest() async {
    setState(() => _isLoading = true);
    try {
      await _supabaseService.updateExpenseStatus(widget.expense.id, 'approved');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Expense Approved'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectRequest() async {
    final reason = await _showRejectionDialog();
    if (reason == null || reason.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _supabaseService.updateExpenseStatus(widget.expense.id, 'rejected',
          reason: reason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Expense Rejected'), backgroundColor: Colors.red));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _showRejectionDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Expense'),
        content: TextField(
          controller: _rejectionReasonController,
          decoration:
              const InputDecoration(hintText: 'Reason for rejection...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, _rejectionReasonController.text),
              child: const Text('Reject')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Review: ${widget.expense.title}'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.expense.receiptUrl != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.expense.receiptUrl!,
                        fit: BoxFit.cover,
                        height: 250,
                        loadingBuilder: (context, child, progress) {
                          return progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                _buildDetailRow('Title', widget.expense.title),
                _buildDetailRow(
                    'Amount', '₹${widget.expense.amount.toStringAsFixed(2)}'),
                _buildDetailRow('Vendor', widget.expense.vendorName),
                _buildDetailRow('Category', widget.expense.category),
                if (widget.expense.description != null &&
                    widget.expense.description!.isNotEmpty)
                  _buildDetailRow('Description', widget.expense.description!),
                const SizedBox(height: 40),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton.icon(
                              onPressed: _approveRequest,
                              icon: const Icon(Icons.check),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12)))),
                      const SizedBox(width: 16),
                      Expanded(
                          child: ElevatedButton.icon(
                              onPressed: _rejectRequest,
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12)))),
                    ],
                  ),
              ],
            ),
          ),
        ));
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

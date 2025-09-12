// lib/models/expense.dart

class Expense {
  final String id;
  final String eventId;
  final String requesterId;
  final String title;
  final double amount;
  final String vendorName;
  final String category;
  final String? description;
  final String receiptUrl;
  final String status;
  final DateTime createdAt;
  final String? rejectionReason;
  final String? approverId;
  final DateTime? processedAt;

  Expense({
    required this.id,
    required this.eventId,
    required this.requesterId,
    required this.title,
    required this.amount,
    required this.vendorName,
    required this.category,
    this.description,
    required this.receiptUrl,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
    this.approverId,
    this.processedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      requesterId: json['requester_id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      vendorName: json['vendor_name'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      receiptUrl: json['receipt_url'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
      rejectionReason: json['rejection_reason'] as String?,
      approverId: json['approver_id'] as String?,
      processedAt: json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'requester_id': requesterId,
      'title': title,
      'amount': amount,
      'vendor_name': vendorName,
      'category': category,
      'description': description,
      'receipt_url': receiptUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'rejection_reason': rejectionReason,
      'approver_id': approverId,
      'processed_at': processedAt?.toIso8601String(),
    };
  }
}

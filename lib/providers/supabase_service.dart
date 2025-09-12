import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/expense.dart'; // ✅ Added missing Expense import
import '../main.dart'; // Import main.dart to access the global supabase client

class SupabaseService {
  // This class now uses the global 'supabase' variable from main.dart

  // --- User Profile Functions ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('profiles')
        .select('role, full_name')
        .eq('id', userId)
        .single();
    return response;
  }

  // --- Event Functions ---
  Future<List<Event>> getEvents() async {
    final userId = supabase.auth.currentUser!.id;
    final eventMemberships = await supabase
        .from('event_members')
        .select('event_id')
        .eq('user_id', userId);

    final eventIds =
        eventMemberships.map((e) => e['event_id'] as String).toList();

    if (eventIds.isEmpty) return [];

    // ✅ FIXED: use inFilter instead of in_
    final eventsData =
        await supabase.from('events').select().inFilter('id', eventIds);

    return eventsData.map((data) => Event.fromJson(data)).toList();
  }

  Future<void> createEvent(Event event) async {
    final userId = supabase.auth.currentUser!.id;
    final insertedEvent = await supabase
        .from('events')
        .insert({
          'name': event.name,
          'description': event.description,
          'date': event.date.toIso8601String(),
          'venue': event.venue,
          'organizer': event.organizer,
          'creator_id': userId,
        })
        .select()
        .single();

    final eventId = insertedEvent['id'];
    await supabase
        .from('event_members')
        .insert({'event_id': eventId, 'user_id': userId, 'role': 'organizer'});
  }

  // --- Expense Functions ---
  Future<List<Expense>> getExpensesForEvent(String eventId) async {
    final response = await supabase
        .from('expense_requests')
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: false);

    return response.map<Expense>((data) => Expense.fromJson(data)).toList();
  }

  Future<void> createExpenseRequest({
    required String eventId,
    required String title,
    required double amount,
    required String vendorName,
    required String category,
    required DateTime date,
    String? description,
    required File receiptImage,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final fileExtension = receiptImage.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    final filePath = '$eventId/$fileName';

    // ✅ FIXED: added fileOptions to upload
    await supabase.storage.from('receipts').upload(
          filePath,
          receiptImage,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final receiptUrl = supabase.storage.from('receipts').getPublicUrl(filePath);

    await supabase.from('expense_requests').insert({
      'event_id': eventId,
      'requester_id': userId,
      'title': title,
      'amount': amount,
      'vendor_name': vendorName,
      'category': category,
      'created_at': date.toIso8601String(),
      'description': description,
      'receipt_url': receiptUrl,
      'status': 'pending',
    });
  }

  Future<List<Expense>> getPendingRequests() async {
    final userId = supabase.auth.currentUser!.id;
    final eventMemberships = await supabase
        .from('event_members')
        .select('event_id')
        .eq('user_id', userId);

    final eventIds =
        eventMemberships.map((e) => e['event_id'] as String).toList();

    if (eventIds.isEmpty) return [];

    // ✅ FIXED: use inFilter instead of in_
    final response = await supabase
        .from('expense_requests')
        .select()
        .eq('status', 'pending')
        .inFilter('event_id', eventIds)
        .order('created_at', ascending: true);

    return response.map<Expense>((data) => Expense.fromJson(data)).toList();
  }

  Future<void> updateExpenseStatus(String expenseId, String status,
      {String? reason}) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('expense_requests').update({
      'status': status,
      'rejection_reason': reason,
      'approver_id': userId,
      'processed_at': DateTime.now().toIso8601String(),
    }).eq('id', expenseId);
  }
}

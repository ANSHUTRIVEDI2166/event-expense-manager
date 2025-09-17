// Removed unused imports
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
    // Get user role
    final profile = await supabase
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .single();
    final role = profile != null ? profile['role'] : null;

    if (role == 'counselor') {
      // Counselors see all events
      final eventsData = await supabase.from('events').select();
      return eventsData.map((data) => Event.fromJson(data)).toList();
    } else {
      // Students see only their member events
      final eventMemberships = await supabase
          .from('event_members')
          .select('event_id')
          .eq('user_id', userId);
      final eventIds =
          eventMemberships.map((e) => e['event_id'] as String).toList();
      if (eventIds.isEmpty) return [];
      final eventsData =
          await supabase.from('events').select().inFilter('id', eventIds);
      return eventsData.map((data) => Event.fromJson(data)).toList();
    }
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

    // Add all counselors as event members
    final counselors =
        await supabase.from('profiles').select('id').eq('role', 'counselor');
    if (counselors != null && counselors is List) {
      for (final counselor in counselors) {
        await supabase.from('event_members').insert({
          'event_id': eventId,
          'user_id': counselor['id'],
          'role': 'counselor'
        });
      }
    }
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
    // Removed receiptImage parameter
  }) async {
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('expense_requests').insert({
      'event_id': eventId,
      'requester_id': userId,
      'title': title,
      'amount': amount,
      'vendor_name': vendorName,
      'category': category,
      'created_at': date.toIso8601String(),
      // 'description': removed
      // 'receipt_url': removed
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

  // Stream for the Counsellor's pending requests dashboard
  Stream<List<Expense>> getPendingRequestsStream() {
    // This stream listens for any changes on the 'expense_requests' table
    return supabase
        .from('expense_requests')
        .stream(primaryKey: ['id']) // The primary key of the table is required
        .eq('status', 'pending') // We only care about pending requests
        .order('created_at', ascending: true)
        .map((listOfMaps) {
          // When new data arrives, convert it from a list of maps to a list of Expense objects
          return listOfMaps
              .map<Expense>((map) => Expense.fromJson(map))
              .toList();
        });
  }

  // Stream for the list of expenses on the Event Details screen
  Stream<List<Expense>> getExpensesForEventStream(String eventId) {
    return supabase
        .from('expense_requests')
        .stream(primaryKey: ['id'])
        .eq('event_id', eventId) // Filter for the specific event
        .order('created_at', ascending: false)
        .map((listOfMaps) =>
            listOfMaps.map<Expense>((map) => Expense.fromJson(map)).toList());
  }
}

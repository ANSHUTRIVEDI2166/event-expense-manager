import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../providers/supabase_service.dart';
import 'event_details_screen.dart';
import 'add_event_screen.dart';
import 'review_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  // We use a single future that will be re-triggered by setState
  late Future<void> _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    // This function can be used to load all necessary data for the screen
    await _supabaseService.getUserProfile();
    await _supabaseService.getEvents();
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (error) {
      // Handle error, maybe show a snackbar
    }
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: FutureBuilder(
        future: _supabaseService.getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final userRole = snapshot.data?['role'];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadDataFuture = _loadData();
              });
            },
            child: CustomScrollView(
              slivers: [
                if (userRole == 'counsellor')
                  SliverToBoxAdapter(child: _buildCounsellorDashboard()),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('My Events',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ),
                EventsList(), // Using the Sliver version
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventScreen()),
          );
          setState(() {
            _loadDataFuture = _loadData();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCounsellorDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text('Pending Approvals',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 150,
          child: StreamBuilder<List<Expense>>(
            stream: _supabaseService.getPendingRequestsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final requests = snapshot.data;
              if (snapshot.hasError || requests == null || requests.isEmpty) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('No pending requests.'),
                ));
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  return _buildPendingRequestCard(requests[index]);
                },
              );
            },
          ),
        ),
        const Divider(height: 32, indent: 16, endIndent: 16),
      ],
    );
  }

  Widget _buildPendingRequestCard(Expense request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () async {
          final refreshed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                  builder: (context) => ReviewExpenseScreen(expense: request)));
          if (refreshed == true) {
            setState(() {});
          }
        },
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('Amount: ₹${request.amount.toStringAsFixed(2)}'),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Tap to review', style: TextStyle(color: Colors.blue)),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventsList extends StatelessWidget {
  final SupabaseService _supabaseService = SupabaseService();

  EventsList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Event>>(
      future: _supabaseService.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
              child: Center(child: Text('Error: ${snapshot.error}')));
        }
        final events = snapshot.data;
        if (events == null || events.isEmpty) {
          return const SliverToBoxAdapter(
              child:
                  Center(child: Text('You are not part of any events yet.')));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildEventCard(context, events[index]),
              );
            },
            childCount: events.length,
          ),
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, Event event) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.event, color: Colors.white)),
        title: Text(event.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Date: ${_formatDate(event.date)}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(event: event)));
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

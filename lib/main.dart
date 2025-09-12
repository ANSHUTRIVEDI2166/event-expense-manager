import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
        'https://exzlabbbedpbmvgzoanm.supabase.co', // Make sure your URL is correct
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV4emxhYmJiZWRwYm12Z3pvYW5tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc2ODk5ODcsImV4cCI6MjA3MzI2NTk4N30.LkH3X5abF_hVcp2BapKiAgeszTP8akIyJRK9hXwx-rI', // Make sure your Key is correct
  );

  runApp(const CulturalEventApp());
}

final supabase = Supabase.instance.client;

class CulturalEventApp extends StatelessWidget {
  const CulturalEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cultural Event Manager',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      // The SplashScreen is now the permanent home, and it will decide what to show.
      home: const SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        // Ensure AppBar respects safe areas
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      // The SplashScreen is now the permanent home, and it will decide what to show.
      home: const SplashScreen(),
    );
  }
}

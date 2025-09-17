import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // To access the global supabase client
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to authentication changes
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 1. While waiting for the initial auth state, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // 2. Check if a user is logged in.
        final session = snapshot.data?.session;
        if (session != null) {
          // If there is a session, the user is logged in. Show the HomeScreen.
          return const HomeScreen();
        } else {
          // If there is no session, the user is logged out. Show the LoginScreen.
          return const LoginScreen();
        }
      },
    );
  }
}

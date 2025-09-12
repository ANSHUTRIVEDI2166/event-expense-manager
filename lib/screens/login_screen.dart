import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart'; // To access the global supabase client

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- SIGN UP FUNCTION ---
  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        _showSnackBar(
            'Success! Please check your email for a confirmation link.');
        _emailController.clear();
        _passwordController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) _showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        _showSnackBar('An unexpected error occurred.', isError: true);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // --- SIGN IN FUNCTION ---
  Future<void> _signIn() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) return;

    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // The session listener in SplashScreen will handle navigation,
      // but we can also navigate manually here.
    } on AuthException catch (error) {
      if (mounted) _showSnackBar(error.message, isError: true);
    } catch (error) {
      if (mounted) {
        _showSnackBar('An unexpected error occurred.', isError: true);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // --- HELPER FOR SHOWING SNACKBARS ---
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // --- EMAIL FIELD ---
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // --- PASSWORD FIELD ---
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // --- BUTTONS ---
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _signIn,
                          child: const Text('Sign In'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _signUp,
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

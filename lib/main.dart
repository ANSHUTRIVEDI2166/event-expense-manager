import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/event_provider.dart';

void main() {
  runApp(const CulturalEventApp());
}

class CulturalEventApp extends StatelessWidget {
  const CulturalEventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EventProvider(),
      child: MaterialApp(
        title: 'Cultural Event Manager',
        theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
        home: const HomeScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const EraApp());
}

class EraApp extends StatelessWidget {
  const EraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Era',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFFFFFFFF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFFFFF),
          secondary: Color(0xFFE0E0E0),
          surface: Color(0xFF0A0A0A),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}
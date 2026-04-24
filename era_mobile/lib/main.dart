import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
        scaffoldBackgroundColor: const Color(0xFF080808),
        primaryColor: const Color(0xFFC9A84C),
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFC9A84C),
          secondary: const Color(0xFFC9A84C),
          surface: const Color(0xFF1A1A1A),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
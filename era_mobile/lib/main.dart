import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  runApp(EraApp(isLoggedIn: token != null));
}

class EraApp extends StatelessWidget {
  final bool isLoggedIn;
  const EraApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Era',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080808),
        primaryColor: const Color(0xFFC9A84C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC9A84C),
          secondary: Color(0xFFC9A84C),
          surface: Color(0xFF1A1A1A),
        ),
      ),
      home: isLoggedIn ? const HomeScreen() : const AuthScreen(),
    );
  }
}
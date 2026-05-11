import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool loading = false;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;

  Future<void> submit() async {
    setState(() { loading = true; error = null; });

    final url = isLogin ? '$baseUrl/auth/login' : '$baseUrl/auth/register';
    final body = isLogin
        ? {'username': usernameController.text, 'email': '', 'password': passwordController.text}
        : {'username': usernameController.text, 'email': emailController.text, 'password': passwordController.text};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // TODO: save token to storage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() { error = data['detail'] ?? 'Something went wrong'; });
      }
    } catch (e) {
      setState(() { error = 'Error: $e'; });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('era.', style: TextStyle(
                color: Color(0xFFC9A84C),
                fontSize: 48,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              )),
              const SizedBox(height: 8),
              Text(isLogin ? 'Welcome back.' : 'Start your era.',
                  style: const TextStyle(color: Colors.white54, fontSize: 16)),
              const SizedBox(height: 48),
              if (error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),
              _input('Username', usernameController),
              if (!isLogin) ...[
                const SizedBox(height: 16),
                _input('Email', emailController),
              ],
              const SizedBox(height: 16),
              _input('Password', passwordController, obscure: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => setState(() { isLogin = !isLogin; error = null; }),
                child: Center(
                  child: Text(
                    isLogin ? "Don't have an account? Sign up" : 'Already have an account? Sign in',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
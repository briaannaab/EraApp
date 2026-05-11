import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF080808),
      body: Center(
        child: Text('Discover — Coming Soon 👑',
            style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
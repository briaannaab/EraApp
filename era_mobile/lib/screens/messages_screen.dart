import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF080808),
      body: Center(
        child: Text('Messages — Coming Soon 👑',
            style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
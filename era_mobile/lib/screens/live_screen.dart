import 'package:flutter/material.dart';

class LiveScreen extends StatelessWidget {
  final String channelName;
  final bool isBroadcaster;

  const LiveScreen({
    super.key,
    required this.channelName,
    this.isBroadcaster = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0008),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0008),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Live', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sensors, color: Color(0xFFFF3B5C), size: 64),
            SizedBox(height: 16),
            Text('Live streaming coming soon',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Available in the iOS app',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

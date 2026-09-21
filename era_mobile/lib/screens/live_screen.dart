import 'package:flutter/material.dart';
import 'live_stream_screen.dart';
import '../services/auth_service.dart';

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
    return LiveStreamScreen(
      username: channelName.isNotEmpty ? channelName : (AuthService.username ?? ''),
      isHost: isBroadcaster,
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:livekit_client/livekit_client.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class LiveStreamScreen extends StatefulWidget {
  final String username; // streamer's username
  final bool isHost;

  const LiveStreamScreen({
    super.key,
    required this.username,
    required this.isHost,
  });

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  Room? _room;
  LocalVideoTrack? _localVideo;
  LocalAudioTrack? _localAudio;
  bool _isConnected = false;
  bool _isMuted = false;
  bool _cameraOff = false;
  List<dynamic> viewers = [];
  final commentController = TextEditingController();
  List<Map<String, String>> comments = [];

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    try {
      final endpoint = widget.isHost
          ? '${apiService.baseUrl}/streaming/stream/start/${widget.username}'
          : '${apiService.baseUrl}/streaming/stream/join/${widget.username}?viewer=${AuthService.username ?? 'guest'}';

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final url = data['url'];

        final room = Room();
        await room.connect(url, token);

        if (widget.isHost) {
          _localVideo = await LocalVideoTrack.createCameraTrack();
          _localAudio = await LocalAudioTrack.create();
          await room.localParticipant?.publishVideoTrack(_localVideo!);
          await room.localParticipant?.publishAudioTrack(_localAudio!);
        }

        setState(() {
          _room = room;
          _isConnected = true;
        });
      }
    } catch (e) {
      print('Stream connection error: $e');
    }
  }

  Future<void> _disconnect() async {
    if (widget.isHost) {
      await http.post(
        Uri.parse('${apiService.baseUrl}/streaming/stream/stop/${widget.username}'),
      );
    }
    await _room?.disconnect();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _room?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video background
            if (_isConnected && widget.isHost && _localVideo != null)
              VideoTrackRenderer(_localVideo!)
            else if (!_isConnected)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else
              Container(color: Colors.black),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),

            // Top bar
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Live badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('LIVE',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 8),
                  Text('@${widget.username}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  // Viewers count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, color: Colors.white54, size: 14),
                        const SizedBox(width: 4),
                        Text('${_room?.remoteParticipants.length ?? 0}',
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _disconnect,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Comments
            Positioned(
              bottom: 80,
              left: 16,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: comments.take(5).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '@${c['username']} ',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        TextSpan(
                          text: c['text'],
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ),
            ),

            // Host controls
            if (widget.isHost)
              Positioned(
                right: 16,
                bottom: 100,
                child: Column(
                  children: [
                    _controlBtn(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      onTap: () async {
                        await _localAudio?.mute();
                        setState(() => _isMuted = !_isMuted);
                      },
                    ),
                    const SizedBox(height: 12),
                    _controlBtn(
                      icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                      onTap: () async {
                        if (_cameraOff) {
                          await _localVideo?.unmute();
                        } else {
                          await _localVideo?.mute();
                        }
                        setState(() => _cameraOff = !_cameraOff);
                      },
                    ),

                  ],
                ),
              ),

            // Comment input
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'say something...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          setState(() {
                            comments.add({
                              'username': AuthService.username ?? 'viewer',
                              'text': text,
                            });
                            commentController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// Helper to access baseUrl
final _apiServiceInstance = _ApiServiceHelper();
_ApiServiceHelper get apiService => _apiServiceInstance;

class _ApiServiceHelper {
  String get baseUrl => 'https://backend-divine-snowflake-3457.fly.dev';
}

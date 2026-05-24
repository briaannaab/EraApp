import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'comments_screen.dart';

const Map<String, Map<String, dynamic>> vibeThemes = {
  'peaceful': {
    'label': 'Peaceful',
    'emoji': '🌊',
    'gradient': [Color(0xFF0A2A3A), Color(0xFF0A1A2A)],
    'accent': Color(0xFF4ECDC4),
    'description': 'A calm space to breathe and slow down.',
  },
  'healing': {
    'label': 'Healing',
    'emoji': '🌿',
    'gradient': [Color(0xFF0A2A1A), Color(0xFF0A1A0A)],
    'accent': Color(0xFF6BCB77),
    'description': 'You are safe here. Gentle content only.',
  },
  'inspired': {
    'label': 'Inspired',
    'emoji': '✨',
    'gradient': [Color(0xFF2A1A0A), Color(0xFF1A0A00)],
    'accent': Color(0xFFFFFFFF),
    'description': 'Fuel your fire. Big ideas welcome.',
  },
  'energized': {
    'label': 'Energized',
    'emoji': '🔥',
    'gradient': [Color(0xFF2A0A0A), Color(0xFF1A0000)],
    'accent': Color(0xFFFF6B35),
    'description': 'High energy. Let\'s go.',
  },
  'quiet': {
    'label': 'Quiet',
    'emoji': '🌙',
    'gradient': [Color(0xFF0A0A2A), Color(0xFF05051A)],
    'accent': Color(0xFF8B9FFF),
    'description': 'Late night thoughts. No noise.',
  },
  'safe': {
    'label': 'Safe',
    'emoji': '🕊️',
    'gradient': [Color(0xFF1A0A2A), Color(0xFF0A0515)],
    'accent': Color(0xFFC084FC),
    'description': 'A bully-free zone. You belong here.',
  },
  'grounded': {
    'label': 'Grounded',
    'emoji': '🙏',
    'gradient': [Color(0xFF1A1A0A), Color(0xFF0A0A05)],
    'accent': Color(0xFFD4A96A),
    'description': 'Mindful. Present. Connected.',
  },
  'motivated': {
  'label': 'Motivated',
  'emoji': '💪',
  'gradient': [Color(0xFF2A1A0A), Color(0xFF1A0A00)],
  'accent': Color(0xFFFF9500),
  'description': 'Push through. You\'ve got this.',
},
'creative': {
  'label': 'Creative',
  'emoji': '🎨',
  'gradient': [Color(0xFF1A0A2A), Color(0xFF0A001A)],
  'accent': Color(0xFFE040FB),
  'description': 'Create freely. No limits here.',
},
'bold': {
  'label': 'Bold',
  'emoji': '🔥',
  'gradient': [Color(0xFF2A0A00), Color(0xFF1A0000)],
  'accent': Color(0xFFFF3B5C),
  'description': 'Be unapologetically you.',
},
'chill': {
  'label': 'Chill',
  'emoji': '🌊',
  'gradient': [Color(0xFF001A2A), Color(0xFF00101A)],
  'accent': Color(0xFF4FC3F7),
  'description': 'Slow down. Just breathe.',
},
};

class VibeScreen extends StatefulWidget {
  final String vibe;
  const VibeScreen({super.key, required this.vibe});

  @override
  State<VibeScreen> createState() => _VibeScreenState();
}

class _VibeScreenState extends State<VibeScreen> {
  List<dynamic> posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVibePosts();
  }

  Future<void> loadVibePosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts/vibe/${widget.vibe}'));
    setState(() {
      posts = response.statusCode == 200 ? jsonDecode(response.body) : [];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = vibeThemes[widget.vibe] ?? vibeThemes['peaceful']!;
    final gradient = theme['gradient'] as List<Color>;
    final accent = theme['accent'] as Color;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios, color: accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${theme['emoji']}  ${theme['label']}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Text(
                  theme['description'] as String,
                  style: TextStyle(color: accent.withOpacity(0.7), fontSize: 13),
                ),
              ),
              // Feed
              Expanded(
                child: loading
                    ? Center(child: CircularProgressIndicator(color: accent))
                    : posts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(theme['emoji'] as String, style: const TextStyle(fontSize: 64)),
                                const SizedBox(height: 16),
                                Text(
                                  'No posts here yet.\nBe the first to set this vibe.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: accent.withOpacity(0.6), fontSize: 15),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              final username = (post['username'] ?? 'unknown') as String;
                              return Container(
                                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: accent.withOpacity(0.15)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => ProfileScreen(username: username))),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundColor: accent.withOpacity(0.2),
                                            child: Text(username[0].toUpperCase(),
                                                style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 10),
                                          Text('@$username',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(post['content'] ?? '',
                                        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
                                    if (post['media_url'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.network(post['media_url'],
                                              fit: BoxFit.cover, width: double.infinity, height: 200),
                                        ),
                                      ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await ApiService.likePost(post['id']);
                                            loadVibePosts();
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.favorite_border, color: accent, size: 18),
                                              const SizedBox(width: 4),
                                              Text('${post['likes'] ?? 0}',
                                                  style: TextStyle(color: accent, fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        GestureDetector(
                                          onTap: () => showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => CommentsScreen(post: post),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.comment_outlined, color: accent.withOpacity(0.7), size: 18),
                                              const SizedBox(width: 4),
                                              Text('Comment',
                                                  style: TextStyle(color: accent.withOpacity(0.7), fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
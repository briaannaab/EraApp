import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'vibe_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final searchController = TextEditingController();
  List<dynamic> creators = [];
  List<dynamic> allPosts = [];
  bool loading = true;
  int selectedTab = 0;

  final List<Map<String, dynamic>> vibes = [
    {'label': 'Peaceful', 'emoji': '🌊', 'color': const Color(0xFF1A3A4A)},
    {'label': 'Healing', 'emoji': '🌿', 'color': const Color(0xFF1A2A1A)},
    {'label': 'Inspired', 'emoji': '🔥', 'color': const Color(0xFF2A1A0A)},
    {'label': 'Energized', 'emoji': '⚡', 'color': const Color(0xFF3A1A1A)},
    {'label': 'Quiet', 'emoji': '🌙', 'color': const Color(0xFF1A1A3A)},
    {'label': 'Safe', 'emoji': '🏠', 'color': const Color(0xFF2A1A3A)},
    {'label': 'Grounded', 'emoji': '✨', 'color': const Color(0xFF2A2A1A)},
    {'label': 'Unbothered', 'emoji': '🖤', 'color': const Color(0xFF1A1A1A)},
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final posts = await ApiService.getPosts();
      final usersResponse = await http.get(
        Uri.parse('https://eraapp-production.up.railway.app/users/'),
      );
      final users = usersResponse.statusCode == 200
          ? jsonDecode(usersResponse.body) as List
          : [];
      if (mounted) {
        setState(() {
          allPosts = posts;
          creators = users;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: const Text('discover.',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1)),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _tab('People', 0),
                  _tab('Vibes', 1),
                  _tab('Posts', 2),
                ],
              ),
            ),

            Container(height: 1, color: const Color(0xFF111111)),

            // Content
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : selectedTab == 0
                      ? _peopleTab()
                      : selectedTab == 1
                          ? _vibesTab()
                          : _postsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final isActive = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.white : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white24,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _peopleTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (creators.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No users yet',
                  style: TextStyle(color: Colors.white38)),
            ),
          )
        else
          ...creators.take(20).map((creator) {
            final username = (creator['username'] ?? 'unknown') as String;
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(username: username))),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Color(0xFF0A0A0A)))),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF1A1A1A),
                      child: Text(
                        username.isNotEmpty
                            ? username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@$username',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(creator['bio'] ?? 'Era member',
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Follow',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _vibesTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: vibes.length,
      itemBuilder: (context, index) {
        final vibe = vibes[index];
        return GestureDetector(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VibeScreen(
                      vibe: vibe['label']
                          .toString()
                          .toLowerCase()))),
          child: Container(
            decoration: BoxDecoration(
              color: vibe['color'] as Color,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(vibe['emoji'] as String,
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(vibe['label'] as String,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _postsTab() {
    if (allPosts.isEmpty) {
      return const Center(
        child: Text('No posts yet',
            style: TextStyle(color: Colors.white38)),
      );
    }
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: allPosts.length,
      itemBuilder: (context, index) {
        final post = allPosts[index];
        return Container(
          color: const Color(0xFF0A0A0A),
          child: post['media_url'] != null
              ? Image.network(post['media_url'],
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(
                      child: Icon(Icons.image_outlined,
                          color: Colors.white12, size: 20)))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(post['content'] ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 9)),
                  ),
                ),
        );
      },
    );
  }
}

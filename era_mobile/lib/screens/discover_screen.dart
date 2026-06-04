import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'vibe_screen.dart';

const String baseUrl = 'https://eraapp-production.up.railway.app';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  final searchController = TextEditingController();
  List<dynamic> allPosts = [];
  List<dynamic> filteredPosts = [];
  List<dynamic> creators = [];
  List<dynamic> filteredUsers = [];
  bool loading = true;
  bool isSearching = false;
  late TabController _tabController;

  final List<Map<String, dynamic>> vibes = [
    {'label': 'Peaceful', 'emoji': '🌊', 'color': const Color(0xFF1A3A4A)},
    {'label': 'Healing', 'emoji': '🌿', 'color': const Color(0xFF1A2A1A)},
    {'label': 'Inspired', 'emoji': '🔥', 'color': const Color(0xFF2A1A0A)},
    {'label': 'Energized', 'emoji': '⚡', 'color': const Color(0xFF3A1A1A)},
    {'label': 'Quiet', 'emoji': '🌙', 'color': const Color(0xFF1A1A3A)},
    {'label': 'Safe', 'emoji': '🏠', 'color': const Color(0xFF2A1A3A)},
    {'label': 'Grounded', 'emoji': '✨', 'color': const Color(0xFF2A2A1A)},
    {'label': 'Unbothered', 'emoji': '🖤', 'color': const Color(0xFF1A1A1A)},
    {'label': 'Elevated', 'emoji': '💫', 'color': const Color(0xFF1A2A3A)},
    {'label': 'Raw', 'emoji': '🖤', 'color': const Color(0xFF2A1A2A)},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final posts = await ApiService.getPosts();
      final usersResponse = await http.get(Uri.parse('$baseUrl/users/'));
      final users = usersResponse.statusCode == 200 ? jsonDecode(usersResponse.body) : [];
      setState(() {
        allPosts = posts;
        filteredPosts = posts;
        creators = users;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void search(String query) {
    setState(() {
      isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        filteredPosts = allPosts;
        filteredUsers = [];
      } else {
        filteredPosts = allPosts.where((post) {
          final content = (post['content'] ?? '').toLowerCase();
          final username = (post['username'] ?? '').toLowerCase();
          return content.contains(query.toLowerCase()) ||
              username.contains(query.toLowerCase());
        }).toList();
        filteredUsers = creators.where((user) {
          final username = (user['username'] ?? '').toLowerCase();
          return username.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 200) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('discover.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: searchController,
                      onChanged: search,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'search people, vibes, topics...',
                        hintStyle: const TextStyle(color: Colors.white24),
                        prefixIcon: const Icon(Icons.search, color: Colors.white24),
                        filled: true,
                        fillColor: const Color(0xFF0F0F0F),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs
              if (!isSearching) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF111111))),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 1.5,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white24,
                    labelStyle: const TextStyle(fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'PEOPLE'),
                      Tab(text: 'VIBES'),
                      Tab(text: 'POSTS'),
                    ],
                  ),
                ),
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _peopleTab(),
                            _vibesTab(),
                            _postsTab(),
                          ],
                        ),
                ),
              ] else ...[
                Expanded(child: _searchResults()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _peopleTab() {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black,
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Featured creator card
          if (creators.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('✦  featured creator',
                      style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFF1A1A1A),
                        backgroundImage: creators[0]['profile_picture_url'] != null
                            ? NetworkImage(creators[0]['profile_picture_url'])
                            : null,
                        child: creators[0]['profile_picture_url'] == null
                            ? Text((creators[0]['username'] ?? '?')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@${creators[0]['username']}',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                            Text(creators[0]['bio'] ?? 'Era member',
                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                            builder: (context) => ProfileScreen(username: creators[0]['username']))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Follow',
                              style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _statItem('${creators[0]['post_count'] ?? 0}', 'posts'),
                      const SizedBox(width: 20),
                      _statItem('${creators[0]['followers'] ?? 0}', 'followers'),
                      const SizedBox(width: 20),
                      _statItem('✦', 'aura'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // People to follow
          const Text('people you might know',
              style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...creators.skip(1).take(10).map((creator) {
            final username = creator['username'] ?? 'unknown';
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProfileScreen(username: username))),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF0A0A0A)))),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF1A1A1A),
                      backgroundImage: creator['profile_picture_url'] != null
                          ? NetworkImage(creator['profile_picture_url'])
                          : null,
                      child: creator['profile_picture_url'] == null
                          ? Text(username[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@$username',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                          Text(creator['bio'] ?? 'Era member',
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Follow',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _statItem(String num, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(num, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _vibesTab() {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black,
      onRefresh: loadData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Tap a vibe to explore posts from people feeling the same way right now.',
              style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.6)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) => VibeScreen(vibe: vibe['label'].toString().toLowerCase()))),
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
                      Text(vibe['emoji'] as String, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(vibe['label'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _postsTab() {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black,
      onRefresh: loadData,
      child: allPosts.isEmpty
          ? const Center(child: Text('No posts yet', style: TextStyle(color: Colors.white38)))
          : GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProfileScreen(username: post['username']))),
                  child: Container(
                    color: const Color(0xFF0A0A0A),
                    child: post['media_url'] != null
                        ? Image.network(post['media_url'], fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Center(
                                child: Icon(Icons.image_outlined, color: Colors.white12, size: 20)))
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Text(post['content'] ?? '',
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white38, fontSize: 9)),
                            ),
                          ),
                  ),
                );
              },
            ),
    );
  }

  Widget _searchResults() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (filteredUsers.isNotEmpty) ...[
          const Text('PEOPLE', style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...filteredUsers.map((user) {
            final username = user['username'] ?? 'unknown';
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ProfileScreen(username: username))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF1A1A1A),
                      child: Text(username[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@$username', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          Text(user['bio'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 12),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text('View', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
        if (filteredPosts.isNotEmpty) ...[
          const Text('POSTS', style: TextStyle(color: Colors.white24, fontSize: 9, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...filteredPosts.map((post) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1A1A1A),
                  child: Text((post['username'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('@${post['username']}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(post['content'] ?? '',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
        if (filteredUsers.isEmpty && filteredPosts.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.search_off, color: Colors.white12, size: 48),
                  SizedBox(height: 12),
                  Text('No results found', style: TextStyle(color: Colors.white24, fontSize: 15)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

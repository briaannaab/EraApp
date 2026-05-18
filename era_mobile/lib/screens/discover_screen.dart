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
  List<dynamic> allPosts = [];
  List<dynamic> filteredPosts = [];
  List<dynamic> creators = [];
  List<dynamic> trending = [];
  List<dynamic> filteredUsers = [];
  bool loading = true;
  bool isSearching = false;

  final List<Map<String, dynamic>> vibes = [
    {'label': 'Peaceful', 'color': const Color(0xFF1A3A4A)},
    {'label': 'Healing', 'color': const Color(0xFF1A2A1A)},
    {'label': 'Inspired', 'color': const Color(0xFF2A1A0A)},
    {'label': 'Energized', 'color': const Color(0xFF3A1A1A)},
    {'label': 'Quiet', 'color': const Color(0xFF1A1A3A)},
    {'label': 'Safe', 'color': const Color(0xFF2A1A3A)},
    {'label': 'Grounded', 'color': const Color(0xFF2A2A1A)},
    {'label': 'Motivated', 'color': const Color(0xFF2A1A4A)},
    {'label': 'Creative', 'color': const Color(0xFF3A1A2A)},
    {'label': 'Bold', 'color': const Color(0xFF4A2A1A)},
    {'label': 'Chill', 'color': const Color(0xFF1A2A4A)},
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final posts = await ApiService.getPosts();
    final usersResponse = await http.get(Uri.parse('$baseUrl/users/'));
    final trendingResponse = await http.get(Uri.parse('$baseUrl/posts/trending'));
    final users = usersResponse.statusCode == 200 ? jsonDecode(usersResponse.body) : [];
    final trendingData = trendingResponse.statusCode == 200 ? jsonDecode(trendingResponse.body) : [];
    setState(() {
      allPosts = posts;
      filteredPosts = posts;
      creators = users;
      trending = trendingData;
      loading = false;
    });
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0008),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Discover',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5)),
                          const SizedBox(height: 16),
                          TextField(
                            controller: searchController,
                            onChanged: search,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search people, topics, etc.',
                              hintStyle: const TextStyle(color: Colors.white38),
                              prefixIcon: const Icon(Icons.search, color: Colors.white38),
                              filled: true,
                              fillColor: const Color(0xFF1A0A1A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isSearching) ...[
                    // Users results
                    if (filteredUsers.isNotEmpty)
                      SliverToBoxAdapter(
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Text('People',
                              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
                        ),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = filteredUsers[index];
                          final username = (user['username'] ?? 'unknown') as String;
                          return GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ProfileScreen(username: username))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: const Color(0xFF2A1A4A),
                                    child: Text(username[0].toUpperCase(),
                                        style: const TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('@$username',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        Text(user['bio'] ?? 'Era member',
                                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[800],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('View',
                                        style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: filteredUsers.length,
                      ),
                    ),
                    // Posts results
                    if (filteredPosts.isNotEmpty)
                      SliverToBoxAdapter(
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                          child: Text('Posts',
                              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
                        ),
                      ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = filteredPosts[index];
                          final username = (post['username'] ?? 'unknown') as String;
                          return GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ProfileScreen(username: username))),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: const BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Color(0xFF1A0A1A)))),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF2A1A4A),
                                    child: Text(username[0].toUpperCase(),
                                        style: const TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('@$username',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                        Text(post['content'] ?? '',
                                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                                            maxLines: 2, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: filteredPosts.length,
                      ),
                    ),
                    if (filteredUsers.isEmpty && filteredPosts.isEmpty)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                const Icon(Icons.search_off, color: Colors.white24, size: 48),
                                const SizedBox(height: 12),
                                const Text('No results found',
                                    style: TextStyle(color: Colors.white38, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ] else ...[

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Trending Now',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('See all', style: TextStyle(color: Colors.purple[300], fontSize: 13)),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: trending.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Text('No trending tags yet — start posting with hashtags!',
                                  style: TextStyle(color: Colors.white38, fontSize: 12)),
                            )
                          : SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: trending.length,
                                itemBuilder: (context, index) {
                                  final item = trending[index];
                                  return Container(
                                    width: 110,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.purple.withOpacity(0.4),
                                          Colors.black.withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(item['tag'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13)),
                                          const SizedBox(height: 4),
                                          Text('${item['posts']} posts',
                                              style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Recommended Creators',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('See all', style: TextStyle(color: Colors.purple[300], fontSize: 13)),
                          ],
                        ),
                      ),
                    ),

                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final creator = creators[index];
                          final username = (creator['username'] ?? 'unknown') as String;
                          return GestureDetector(
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ProfileScreen(username: username))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFF2A1A4A),
                                    child: Text(username[0].toUpperCase(),
                                        style: const TextStyle(
                                            color: Color(0xFFC9A84C),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(username,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        Text(
                                          creator['bio'] ?? 'Creator',
                                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple[800],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Follow',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: creators.length > 5 ? 5 : creators.length,
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Explore by Vibe',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('See all', style: TextStyle(color: Colors.purple[300], fontSize: 13)),
                          ],
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: vibes.length,
                          itemBuilder: (context, index) {
                            final vibe = vibes[index];
                            final vibeName = (vibe['label'] as String).toLowerCase();
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VibeScreen(vibe: vibeName),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: vibe['color'] as Color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    vibe['label'] as String,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ],
              ),
      ),
    );
  }
}
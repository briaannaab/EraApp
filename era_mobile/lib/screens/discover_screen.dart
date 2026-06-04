import 'dart:convert';
import 'dart:math';
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

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  final searchController = TextEditingController();
  List<dynamic> allPosts = [];
  List<dynamic> filteredPosts = [];
  List<dynamic> creators = [];
  List<dynamic> filteredUsers = [];
  bool loading = true;
  bool isSearching = false;
  String selectedVibe = 'all';

  final List<Map<String, dynamic>> vibes = [
    {'label': 'All', 'emoji': '✦', 'color': Colors.transparent, 'tint': const Color(0xFF000000)},
    {'label': 'Peaceful', 'emoji': '🌊', 'color': const Color(0xFF1A3A4A), 'tint': const Color(0xFF00101A)},
    {'label': 'Healing', 'emoji': '🌿', 'color': const Color(0xFF1A2A1A), 'tint': const Color(0xFF001A00)},
    {'label': 'Inspired', 'emoji': '🔥', 'color': const Color(0xFF2A1A0A), 'tint': const Color(0xFF1A0A00)},
    {'label': 'Energized', 'emoji': '⚡', 'color': const Color(0xFF3A1A1A), 'tint': const Color(0xFF1A0000)},
    {'label': 'Quiet', 'emoji': '🌙', 'color': const Color(0xFF1A1A3A), 'tint': const Color(0xFF00001A)},
    {'label': 'Safe', 'emoji': '🏠', 'color': const Color(0xFF2A1A3A), 'tint': const Color(0xFF0A001A)},
    {'label': 'Grounded', 'emoji': '✨', 'color': const Color(0xFF2A2A1A), 'tint': const Color(0xFF0A0A00)},
    {'label': 'Unbothered', 'emoji': '🖤', 'color': const Color(0xFF1A1A1A), 'tint': const Color(0xFF000000)},
  ];

  Color get currentTint {
    final vibe = vibes.firstWhere(
        (v) => v['label'].toString().toLowerCase() == selectedVibe,
        orElse: () => vibes[0]);
    return vibe['tint'] as Color;
  }

  Color get currentVibeColor {
    final vibe = vibes.firstWhere(
        (v) => v['label'].toString().toLowerCase() == selectedVibe,
        orElse: () => vibes[0]);
    return vibe['color'] as Color;
  }

  List<dynamic> get displayPosts {
    if (selectedVibe == 'all') return allPosts;
    return allPosts.where((p) =>
        (p['vibe'] ?? '').toString().toLowerCase() == selectedVibe).toList();
  }

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
          filteredPosts = posts;
          creators = users;
          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [currentTint, Colors.black],
            stops: const [0.0, 0.4],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('discover.',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1)),
                      GestureDetector(
                        onTap: () {
                          setState(() => isSearching = !isSearching);
                          if (!isSearching) {
                            searchController.clear();
                            filteredUsers = [];
                            filteredPosts = allPosts;
                          }
                        },
                        child: Icon(
                          isSearching ? Icons.close : Icons.search,
                          color: Colors.white38,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search field
                if (isSearching) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: TextField(
                      controller: searchController,
                      onChanged: search,
                      autofocus: true,
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
                  ),
                ] else ...[
                  // Vibe filter row
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 34,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vibes.length,
                      itemBuilder: (context, index) {
                        final vibe = vibes[index];
                        final label = vibe['label'].toString();
                        final isActive = selectedVibe == label.toLowerCase();
                        final vibeColor = vibe['color'] as Color;
                        return GestureDetector(
                          onTap: () => setState(
                              () => selectedVibe = label.toLowerCase()),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isActive
                                    ? (vibeColor == Colors.transparent
                                        ? Colors.white
                                        : vibeColor.withOpacity(0.8))
                                    : Colors.white.withOpacity(0.1),
                              ),
                              borderRadius: BorderRadius.circular(20),
                              color: isActive
                                  ? vibeColor.withOpacity(0.2)
                                  : Colors.transparent,
                            ),
                            child: Text(
                              '${vibe['emoji']} $label',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.white38,
                                fontSize: 11,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Post count
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Text(
                      selectedVibe == 'all'
                          ? '${allPosts.length} posts · ${creators.length} people in your orbit'
                          : '${displayPosts.length} ${selectedVibe} posts',
                      style: TextStyle(
                        color: selectedVibe == 'all'
                            ? Colors.white24
                            : currentVibeColor.withOpacity(0.5),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Content
                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : isSearching
                          ? _searchResults()
                          : _moodBoard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _moodBoard() {
    final posts = displayPosts;
    return Column(
      children: [
        Expanded(
          child: posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome,
                          color: Colors.white12, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        selectedVibe == 'all'
                            ? 'No posts yet'
                            : 'No $selectedVibe posts yet',
                        style: const TextStyle(
                            color: Colors.white24, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : _buildMasonryGrid(posts),
        ),

        // People orbit strip
        if (creators.isNotEmpty && !isSearching)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF0A0A0A))),
            ),
            child: Row(
              children: [
                ...creators.take(5).map((creator) {
                  final username = creator['username'] ?? '?';
                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(username: username))),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1A1A1A),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          username.isNotEmpty
                              ? username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  selectedVibe == 'all'
                      ? 'in your orbit'
                      : '$selectedVibe together',
                  style: TextStyle(
                    color: selectedVibe == 'all'
                        ? Colors.white24
                        : currentVibeColor.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMasonryGrid(List<dynamic> posts) {
    final random = Random(42);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: posts.take(12).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final post = entry.value;
          // Vary card sizes
          final sizes = [
            const Size(150, 180),
            const Size(110, 110),
            const Size(110, 150),
            const Size(150, 110),
            const Size(230, 80),
            const Size(110, 90),
          ];
          final size = sizes[index % sizes.length];
          return _moodCard(post, size);
        }).toList(),
      ),
    );
  }

  Widget _moodCard(Map<String, dynamic> post, Size size) {
    final username = post['username'] ?? '?';
    final vibe = post['vibe'];
    final vibeData = vibe != null
        ? vibes.firstWhere(
            (v) => v['label'].toString().toLowerCase() == vibe.toString(),
            orElse: () => vibes[0])
        : null;
    final cardColor = vibeData != null && vibeData['color'] != Colors.transparent
        ? (vibeData['color'] as Color).withOpacity(0.3)
        : const Color(0xFF0D0D0D);

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileScreen(username: username))),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Media
              if (post['media_url'] != null)
                Image.network(
                  post['media_url'],
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(color: cardColor),
                ),

              // Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('@$username',
                        style: TextStyle(
                            color: vibeData != null
                                ? (vibeData['color'] as Color).withOpacity(0.8)
                                : Colors.white38,
                            fontSize: 8,
                            fontWeight: FontWeight.w700)),
                    if (post['content'] != null &&
                        post['content'].toString().isNotEmpty)
                      Text(
                        post['content'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            height: 1.3),
                      ),
                    if (vibe != null)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: vibeData != null
                              ? (vibeData['color'] as Color).withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${vibeData?['emoji'] ?? '✦'} $vibe',
                          style: TextStyle(
                              color: vibeData != null
                                  ? (vibeData['color'] as Color)
                                  : Colors.white38,
                              fontSize: 7),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchResults() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (filteredUsers.isNotEmpty) ...[
          const Text('PEOPLE',
              style: TextStyle(
                  color: Colors.white24, fontSize: 9, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...filteredUsers.map((user) {
            final username = user['username'] ?? 'unknown';
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(username: username))),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF1A1A1A),
                      child: Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
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
                                  fontWeight: FontWeight.w600)),
                          Text(user['bio'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('View',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
        if (filteredPosts.isNotEmpty) ...[
          const Text('POSTS',
              style: TextStyle(
                  color: Colors.white24, fontSize: 9, letterSpacing: 2)),
          const SizedBox(height: 12),
          ...filteredPosts.map((post) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF1A1A1A),
                      child: Text(
                        (post['username'] ?? '?')[0].toUpperCase(),
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
                          Text('@${post['username']}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                          Text(post['content'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
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
                  Text('No results found',
                      style:
                          TextStyle(color: Colors.white24, fontSize: 15)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

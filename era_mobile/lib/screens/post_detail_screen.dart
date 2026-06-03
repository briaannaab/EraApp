import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'comments_screen.dart';
import 'profile_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final List<Map<String, dynamic>>? allPosts;
  final int initialIndex;

  const PostDetailScreen({
    super.key,
    required this.post,
    this.allPosts,
    this.initialIndex = 0,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PageController _pageController;
  late int currentIndex;
  late List<Map<String, dynamic>> posts;
  final String currentUser = AuthService.username ?? AuthService.username ?? 'briaannaab';

  @override
  void initState() {
    super.initState();
    posts = widget.allPosts ?? [widget.post];
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: posts.length,
        onPageChanged: (index) => setState(() => currentIndex = index),
        itemBuilder: (context, index) {
          final post = posts[index];
          return _PostDetailCard(
            post: post,
            currentUser: currentUser,
            onDeleted: () {
              setState(() => posts.removeAt(index));
              if (posts.isEmpty) Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}

class _PostDetailCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final String currentUser;
  final VoidCallback onDeleted;

  const _PostDetailCard({
    required this.post,
    required this.currentUser,
    required this.onDeleted,
  });

  @override
  State<_PostDetailCard> createState() => _PostDetailCardState();
}

class _PostDetailCardState extends State<_PostDetailCard> {
  late Map<String, dynamic> post;

  @override
  void initState() {
    super.initState();
    post = Map<String, dynamic>.from(widget.post);
  }

  @override
  Widget build(BuildContext context) {
    final username = (post['username'] ?? 'unknown') as String;
    final hasMedia = post['media_url'] != null;
    final isOwner = username == widget.currentUser;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  ),
                  GestureDetector(
                    onTap: () => _showOptions(context),
                    child: const Icon(Icons.more_horiz, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),
          ),

          if (hasMedia)
            Image.network(
              post['media_url'],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => const SizedBox.shrink(),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ProfileScreen(username: username),
                  )),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF1A1A1A),
                        child: Text(username[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@$username',
                              style: const TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(post['created_at']?.toString().substring(0, 10) ?? '',
                              style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                if (post['content'] != null && post['content'].isNotEmpty)
                  Text(post['content'],
                      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),

                const SizedBox(height: 20),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await ApiService.likePost(post['id']);
                        setState(() => post['likes'] = (post['likes'] ?? 0) + 1);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_border, color: Colors.white54, size: 22),
                          const SizedBox(width: 6),
                          Text('${post['likes'] ?? 0}',
                              style: const TextStyle(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CommentsScreen(post: post),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.comment_outlined, color: Colors.white54, size: 22),
                          SizedBox(width: 6),
                          Text('Comment',
                              style: TextStyle(color: Colors.white54, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),

                if (post['vibe'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0A0A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('✨ ${post['vibe']}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final username = (post['username'] ?? 'unknown') as String;
    final isOwner = username == widget.currentUser;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (isOwner)
              _optionTile(Icons.delete_outline, 'Delete Post', Colors.red, () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF0A0A0A),
                    title: const Text('Delete post?',
                        style: TextStyle(color: Colors.white)),
                    content: const Text('This cannot be undone.',
                        style: TextStyle(color: Colors.white54)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white54)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ApiService.deletePost(post['id']);
                  widget.onDeleted();
                }
              }),
            _optionTile(Icons.flag_outlined, 'Report Post', Colors.orange, () {
              Navigator.pop(context);
              _showReportDialog(context);
            }),
            _optionTile(Icons.share_outlined, 'Share', Colors.white, () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    String selectedReason = 'Spam';
    final reasons = ['Spam', 'Harassment', 'Hate Speech', 'Violence', 'Misinformation', 'Other'];
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Report Post',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Help us understand what\'s wrong',
                  style: TextStyle(color: Colors.white38, fontSize: 13)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: reasons.map((reason) {
                  final isSelected = selectedReason == reason;
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedReason = reason),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(reason,
                          style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white54,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Additional details (optional)',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await http.post(
                      Uri.parse('$baseUrl/reports/'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'reporter_username': widget.currentUser,
                        'reported_username': post['username'],
                        'post_id': post['id'],
                        'reason': selectedReason,
                        'description': descController.text,
                      }),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report submitted. Thank you for keeping Era safe.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Submit Report',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(color: color, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

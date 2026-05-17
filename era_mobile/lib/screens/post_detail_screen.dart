import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'comments_screen.dart';
import 'profile_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late Map<String, dynamic> post;

  @override
  void initState() {
    super.initState();
    post = widget.post;
  }

  @override
  Widget build(BuildContext context) {
    final username = (post['username'] ?? 'unknown') as String;
    final hasMedia = post['media_url'] != null;
    final isVideo = hasMedia &&
        (post['media_url'].toString().contains('.mp4') ||
         post['media_url'].toString().contains('.mov') ||
         post['media_url'].toString().contains('video'));

    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('@$username',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media
            if (hasMedia && !isVideo)
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
                  // User info
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProfileScreen(username: username),
                    )),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF2A1A4A),
                          child: Text(username[0].toUpperCase(),
                              style: const TextStyle(
                                  color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('@$username',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(post['created_at'].toString().substring(0, 10),
                                style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Content
                  Text(post['content'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),

                  const SizedBox(height: 20),

                  // Actions
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
                      const SizedBox(width: 24),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_outlined,
                              color: Color(0xFFC9A84C), size: 22),
                          const SizedBox(width: 6),
                          Text('\$${(post['tips'] ?? 0.0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: Color(0xFFC9A84C), fontSize: 14)),
                        ],
                      ),
                    ],
                  ),

                  if (post['vibe'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('✨ ${post['vibe']}',
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
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
}
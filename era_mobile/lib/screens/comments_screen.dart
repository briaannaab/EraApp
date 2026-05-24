import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CommentsScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  List<dynamic> comments = [];
  bool loading = true;
  final controller = TextEditingController();
  int? replyingToId;
  String? replyingToUsername;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    final data = await ApiService.getComments(widget.post['id']);
    setState(() {
      comments = data;
      loading = false;
    });
  }

  Future<void> submitComment() async {
    if (controller.text.isEmpty) return;
    await ApiService.createComment(
      postId: widget.post['id'],
      userId: 1,
      username: 'briaannaab',
      content: controller.text,
      parentId: replyingToId,
    );
    controller.clear();
    setState(() {
      replyingToId = null;
      replyingToUsername = null;
    });
    loadComments();
  }

  List<dynamic> get topLevelComments =>
      comments.where((c) => c['parent_id'] == null).toList();

  List<dynamic> repliesFor(int commentId) =>
      comments.where((c) => c['parent_id'] == commentId).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Text('Comments',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('${comments.length}',
                style: const TextStyle(color: Colors.white38, fontSize: 14)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFFFF)))
                : comments.isEmpty
                    ? const Center(
                        child: Text('No comments yet. Be first!',
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: topLevelComments.length,
                        itemBuilder: (context, index) {
                          final comment = topLevelComments[index];
                          final replies = repliesFor(comment['id']);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _commentTile(comment, isReply: false),
                              // Replies
                              ...replies.map((reply) => Padding(
                                    padding: const EdgeInsets.only(left: 48),
                                    child: _commentTile(reply, isReply: true),
                                  )),
                            ],
                          );
                        },
                      ),
          ),
          // Reply indicator
          if (replyingToUsername != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF0A0A0A),
              child: Row(
                children: [
                  Text('Replying to @$replyingToUsername',
                      style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 12)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      replyingToId = null;
                      replyingToUsername = null;
                    }),
                    child: const Icon(Icons.close, color: Colors.white38, size: 16),
                  ),
                ],
              ),
            ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF0A0A0A),
              border: Border(top: BorderSide(color: Color(0xFF2A1A2A))),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF1A1A1A),
                  child: Text('B',
                      style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: replyingToUsername != null
                          ? 'Reply to @$replyingToUsername...'
                          : 'Add a comment...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submitComment,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.black, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentTile(Map<String, dynamic> comment, {required bool isReply}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 18,
            backgroundColor: const Color(0xFF1A1A1A),
            child: Text(
              (comment['username'] ?? '?')[0].toUpperCase(),
              style: TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: isReply ? 10 : 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('@${comment['username']}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(comment['content'],
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await ApiService.likeComment(comment['id']);
                        loadComments();
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.favorite_border,
                              color: Colors.white38, size: 14),
                          const SizedBox(width: 4),
                          Text('${comment['likes'] ?? 0}',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (!isReply)
                      GestureDetector(
                        onTap: () => setState(() {
                          replyingToId = comment['id'];
                          replyingToUsername = comment['username'];
                        }),
                        child: const Text('Reply',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 12)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

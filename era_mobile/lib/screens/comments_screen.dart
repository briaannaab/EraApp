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
    );
    controller.clear();
    loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Comments',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
                : comments.isEmpty
                    ? const Center(
                        child: Text('No comments yet. Be first!',
                            style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: const Color(0xFF2A1A4A),
                                  child: Text(
                                    (comment['username'] ?? '?')[0].toUpperCase(),
                                    style: const TextStyle(color: Color(0xFFC9A84C), fontSize: 12),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submitComment,
                  child: const Icon(Icons.send, color: Color(0xFFC9A84C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
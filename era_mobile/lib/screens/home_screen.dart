import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final data = await ApiService.getPosts();
      setState(() {
        posts = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        elevation: 0,
        title: const Text(
          'era.',
          style: TextStyle(
            color: Color(0xFFC9A84C),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : posts.isEmpty
              ? const Center(
                  child: Text('No posts yet. Be first! 👑',
                      style: TextStyle(color: Colors.white54)))
              : RefreshIndicator(
                  onRefresh: loadPosts,
                  color: const Color(0xFFC9A84C),
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _PostCard(post: post, onLike: loadPosts);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFC9A84C),
        onPressed: () => _showCreatePost(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showCreatePost(BuildContext context) {
    final controller = TextEditingController();
    Uint8List? selectedImageBytes;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Post', style: TextStyle(
                color: Color(0xFFC9A84C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "What's your era?",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
              if (selectedImageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(selectedImageBytes!, height: 150, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.first.bytes != null) {
                    setModalState(() {
                      selectedImageBytes = result.files.first.bytes;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF333333)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined, color: Colors.white54, size: 18),
                      SizedBox(width: 6),
                      Text('Photo', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (controller.text.isEmpty) return;
                    String? mediaUrl;
                    if (selectedImageBytes != null) {
                      mediaUrl = await ApiService.uploadImage(
                        selectedImageBytes!,
                        'post_image.jpg',
                      );
                    }
                    await ApiService.createPost(
                      userId: 1,
                      username: 'briaannaab',
                      content: controller.text,
                      mediaUrl: mediaUrl,
                    );
                    Navigator.pop(context);
                    loadPosts();
                  },
                  child: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;

  const _PostCard({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF2A1A4A),
                child: Text(
                  post['username'][0].toUpperCase(),
                  style: const TextStyle(color: Color(0xFFC9A84C)),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('@${post['username']}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(post['created_at'].toString().substring(0, 10),
                      style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post['content'],
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5)),
          if (post['media_url'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post['media_url'], 
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  await ApiService.likePost(post['id']);
                  onLike();
                },
                child: Row(
                  children: [
                    const Icon(Icons.favorite_border, color: Colors.white38, size: 18),
                    const SizedBox(width: 4),
                    Text('${post['likes']}',
                        style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  const Icon(Icons.monetization_on_outlined,
                      color: Color(0xFFC9A84C), size: 18),
                  const SizedBox(width: 4),
                  Text('\$${post['tips'].toStringAsFixed(2)}',
                      style: const TextStyle(color: Color(0xFFC9A84C), fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

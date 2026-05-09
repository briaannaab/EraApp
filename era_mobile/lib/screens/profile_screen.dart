import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/${widget.username}/profile'),
    );
    if (response.statusCode == 200) {
      setState(() {
        profile = jsonDecode(response.body);
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '@${widget.username}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : profile == null
              ? const Center(child: Text('User not found', style: TextStyle(color: Colors.white54)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: const Color(0xFF2A1A4A),
                                  child: Text(
                                    profile!['username'][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFC9A84C),
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _stat('${profile!['post_count']}', 'Posts'),
                                      _stat('${profile!['followers']}', 'Followers'),
                                      _stat('${profile!['following']}', 'Following'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '@${profile!['username']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (profile!['is_creator'])
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC9A84C).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: const Text('CREATOR',
                                    style: TextStyle(
                                        color: Color(0xFFC9A84C),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                              ),
                            if (profile!['bio'] != null && profile!['bio'].isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(profile!['bio'],
                                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              ),
                            const SizedBox(height: 16),
                            if (profile!['is_creator'])
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.monetization_on_outlined,
                                        color: Color(0xFFC9A84C), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      '\$${profile!['tips_received'].toStringAsFixed(2)} earned',
                                      style: const TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF333333)),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {},
                                child: const Text('Follow'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Color(0xFF1A1A1A)),
                      // Posts Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(2),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: profile!['posts'].length,
                        itemBuilder: (context, index) {
                          final post = profile!['posts'][index];
                          return Container(
                            color: const Color(0xFF1A1A1A),
                            child: post['media_url'] != null
                                ? Image.network(post['media_url'], fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(
                                      Icons.videocam, color: Color(0xFFC9A84C)))
                                : Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(post['content'],
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                    ),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'profile_screen.dart';

class FollowersScreen extends StatefulWidget {
  final String username;
  final bool showFollowing;

  const FollowersScreen({
    super.key,
    required this.username,
    this.showFollowing = false,
  });

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List<dynamic> users = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users/'));
    setState(() {
      users = response.statusCode == 200 ? jsonDecode(response.body) : [];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0008),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0008),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.showFollowing ? 'Following' : 'Followers',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : users.isEmpty
              ? Center(
                  child: Text(
                    widget.showFollowing ? 'Not following anyone yet' : 'No followers yet',
                    style: const TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final username = (user['username'] ?? 'unknown') as String;
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(username: username),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF2A1A4A),
                              child: Text(
                                username[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Color(0xFFC9A84C),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('@$username',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                  if (user['bio'] != null && user['bio'].isNotEmpty)
                                    Text(user['bio'],
                                        style: const TextStyle(
                                            color: Colors.white38, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A1A4A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('View',
                                  style: TextStyle(
                                      color: Color(0xFFC9A84C),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
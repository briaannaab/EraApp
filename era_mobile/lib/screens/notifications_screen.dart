import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool loading = true;
  final String currentUser = AuthService.username ?? AuthService.username ?? 'briaannaab';

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$currentUser'),
    );
    setState(() {
      notifications = response.statusCode == 200 ? jsonDecode(response.body) : [];
      loading = false;
    });
  }

  Future<void> markAllRead() async {
    await http.post(Uri.parse('$baseUrl/notifications/mark-all-read/$currentUser'));
    loadNotifications();
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'like': return Icons.favorite;
      case 'comment': return Icons.comment;
      case 'follow': return Icons.person_add;
      case 'prayer': return Icons.volunteer_activism;
      default: return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'like': return Colors.red;
      case 'comment': return const Color(0xFF6C63FF);
      case 'follow': return const Color(0xFF00C9A7);
      case 'prayer': return const Color(0xFFC084FC);
      default: return const Color(0xFFFFFFFF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Notifications',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          if (notifications.any((n) => n['read'] == false))
            TextButton(
              onPressed: markAllRead,
              child: const Text('Mark all read',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 12)),
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFFFF)))
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0A0A),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none,
                            color: Colors.white24, size: 36),
                      ),
                      const SizedBox(height: 16),
                      const Text('No notifications yet',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('When someone likes or comments\nyou\'ll see it here',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final isUnread = notif['read'] == false;
                    final type = notif['type'] ?? 'general';

                    return Container(
                      color: isUnread
                          ? const Color(0xFF0A0A0A)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _getColor(type).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getIcon(type),
                                color: _getColor(type), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(notif['message'] ?? '',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: isUnread
                                            ? FontWeight.bold
                                            : FontWeight.normal)),
                                const SizedBox(height: 4),
                                Text(
                                  _timeAgo(notif['created_at']),
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _timeAgo(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
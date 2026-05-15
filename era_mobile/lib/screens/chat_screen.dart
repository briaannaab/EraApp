import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String otherUser;

  const ChatScreen({super.key, required this.currentUser, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> messages = [];
  bool loading = true;
  final messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/messages/conversation/${widget.currentUser}/${widget.otherUser}'),
    );
    setState(() {
      messages = response.statusCode == 200 ? jsonDecode(response.body) : [];
      loading = false;
    });
  }

  Future<void> sendMessage() async {
    if (messageController.text.isEmpty) return;
    final content = messageController.text;
    messageController.clear();

    await http.post(
      Uri.parse('$baseUrl/messages/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sender_id': 1,
        'receiver_id': 2,
        'sender_username': widget.currentUser,
        'receiver_username': widget.otherUser,
        'content': content,
      }),
    );
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF2A1A4A),
              child: Text(
                widget.otherUser[0].toUpperCase(),
                style: const TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Text('@${widget.otherUser}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
                : messages.isEmpty
                    ? const Center(
                        child: Text('No messages yet. Say hi! 👋',
                            style: TextStyle(color: Colors.white38)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg['sender_username'] == widget.currentUser;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFFC9A84C) : const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                msg['content'],
                                style: TextStyle(
                                  color: isMe ? Colors.black : Colors.white,
                                  fontSize: 14,
                                ),
                              ),
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
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFC9A84C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.black, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
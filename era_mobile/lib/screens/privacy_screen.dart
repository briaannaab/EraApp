import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _isPrivate = false;
  bool _allowMessages = true;
  bool _allowComments = true;
  bool _showActivity = true;
  final messageController = TextEditingController();
  Uint8List? _imageBytes;
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Privacy',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save',
                style: TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Privacy
            const Text('Account Privacy',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _toggleTile(
              icon: Icons.lock_outline,
              title: 'Private Account',
              subtitle: 'Only approved followers can see your content',
              value: _isPrivate,
              onChanged: (val) => setState(() => _isPrivate = val),
            ),
            _toggleTile(
              icon: Icons.chat_bubble_outline,
              title: 'Allow Messages',
              subtitle: 'Let anyone send you direct messages',
              value: _allowMessages,
              onChanged: (val) => setState(() => _allowMessages = val),
            ),
            _toggleTile(
              icon: Icons.comment_outlined,
              title: 'Allow Comments',
              subtitle: 'Let people comment on your posts',
              value: _allowComments,
              onChanged: (val) => setState(() => _allowComments = val),
            ),
            _toggleTile(
              icon: Icons.visibility_outlined,
              title: 'Show Activity Status',
              subtitle: 'Let others see when you were last active',
              value: _showActivity,
              onChanged: (val) => setState(() => _showActivity = val),
            ),

            const SizedBox(height: 32),

            // Private Account Message
            const Text('Private Account Message',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'This message shows to users who try to view your private profile.',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Privacy image
            GestureDetector(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null && result.files.first.bytes != null) {
                  setState(() => _imageBytes = result.files.first.bytes);
                  final url = await ApiService.uploadImage(
                    result.files.first.bytes!, 'privacy.jpg');
                  if (url != null) setState(() => _imageUrl = url);
                }
              },
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _imageBytes != null
                        ? const Color(0xFFC9A84C)
                        : const Color(0xFF333333),
                  ),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: Color(0xFFC9A84C), size: 36),
                          SizedBox(height: 8),
                          Text('Add a privacy screen photo',
                              style: TextStyle(color: Colors.white38, fontSize: 13)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'e.g. This account is private. Follow to see my content.',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterStyle: const TextStyle(color: Colors.white38),
              ),
            ),

            const SizedBox(height: 32),

            // Blocked content
            const Text('Blocked Content',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Color(0xFFC9A84C), size: 20),
                      SizedBox(width: 10),
                      Text('Era Safe Space Protection',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Era automatically filters hate speech, bullying, and harmful content to keep your experience safe.',
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC9A84C), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFC9A84C),
          ),
        ],
      ),
    );
  }
}
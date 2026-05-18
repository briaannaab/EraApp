import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController bioController;
  bool _saving = false;
  String? voiceBioUrl;

  @override
  void initState() {
    super.initState();
    bioController = TextEditingController(text: widget.profile['bio'] ?? '');
    voiceBioUrl = widget.profile['voice_bio_url'];
  }

  Future<void> saveProfile() async {
    setState(() => _saving = true);
    await http.put(
      Uri.parse('$baseUrl/users/${widget.profile['id']}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bio': bioController.text,
        'voice_bio_url': voiceBioUrl,
      }),
    );
    setState(() => _saving = false);
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> uploadVoiceBio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.first.bytes != null) {
      final url = await ApiService.uploadAudio(
        result.files.first.bytes!,
        result.files.first.name,
      );
      if (url != null) setState(() => voiceBioUrl = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0008),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0008),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _saving ? null : saveProfile,
            child: Text(_saving ? 'Saving...' : 'Save',
                style: const TextStyle(
                    color: Color(0xFFC9A84C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bio
            const Text('Bio', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: bioController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              maxLength: 150,
              decoration: InputDecoration(
                hintText: 'Tell your story...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1A0A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterStyle: const TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 24),

            // Username
            const Text('Username', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A0A1A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('@${widget.profile['username']}',
                      style: const TextStyle(color: Colors.white54, fontSize: 15)),
                  const Spacer(),
                  const Text('Cannot be changed',
                      style: TextStyle(color: Colors.white24, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Voice Bio
            const Text('Voice Bio', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: uploadVoiceBio,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A0A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: voiceBioUrl != null
                        ? const Color(0xFFC9A84C)
                        : const Color(0xFF333333),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9A84C).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        voiceBioUrl != null ? Icons.mic : Icons.mic_none,
                        color: const Color(0xFFC9A84C),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voiceBioUrl != null ? 'Voice bio uploaded ✓' : 'Add a voice bio',
                            style: TextStyle(
                              color: voiceBioUrl != null
                                  ? const Color(0xFFC9A84C)
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            voiceBioUrl != null
                                ? 'Tap to replace'
                                : 'Upload an audio clip to introduce yourself',
                            style: const TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (voiceBioUrl != null)
                      GestureDetector(
                        onTap: () => setState(() => voiceBioUrl = null),
                        child: const Icon(Icons.close, color: Colors.white38, size: 18),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

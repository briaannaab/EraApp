import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  bool _isRecording = false;
  bool _processing = false;
  Uint8List? _audioBytes;
  String? _audioName;
  final captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000000),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Voice Post',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Share your voice',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload an audio file to post',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 48),
            if (_audioBytes != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0A0A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.audio_file, color: Color(0xFFFFFFFF), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_audioName ?? 'Audio file',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text('Ready to post',
                              style: TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() { _audioBytes = null; _audioName = null; }),
                      child: const Icon(Icons.close, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                );
                if (result != null && result.files.first.bytes != null) {
                  setState(() {
                    _audioBytes = result.files.first.bytes;
                    _audioName = result.files.first.name;
                  });
                }
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B35).withOpacity(0.15),
                  border: Border.all(color: const Color(0xFFFF6B35).withOpacity(0.5), width: 2),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mic, color: Color(0xFFFF6B35), size: 40),
                    SizedBox(height: 8),
                    Text('Upload Audio', style: TextStyle(color: Color(0xFFFF6B35), fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: captionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a caption...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_audioBytes != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _processing ? null : () async {
                    setState(() => _processing = true);
                    final mediaUrl = await ApiService.uploadAudio(
                      _audioBytes!,
                      _audioName ?? 'voice.mp3',
                    );
                    await ApiService.createPost(
                      userId: AuthService.userId ?? 1,
                      username: AuthService.username ?? 'briaannaab',
                      content: captionController.text.isEmpty
                          ? '🎙️ Voice post'
                          : captionController.text,
                      mediaUrl: mediaUrl,
                    );
                    setState(() => _processing = false);
                    if (mounted) Navigator.pop(context);
                  },
                  child: _processing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Post Voice', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
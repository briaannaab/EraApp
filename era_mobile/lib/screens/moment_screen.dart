import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MomentScreen extends StatefulWidget {
  const MomentScreen({super.key});

  @override
  State<MomentScreen> createState() => _MomentScreenState();
}

class _MomentScreenState extends State<MomentScreen> {
  Uint8List? _imageBytes;
  final captionController = TextEditingController();
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080808),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('New Moment',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null && result.files.first.bytes != null) {
                  setState(() => _imageBytes = result.files.first.bytes);
                }
              },
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _imageBytes != null
                        ? const Color(0xFFC9A84C)
                        : const Color(0xFF333333),
                  ),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Color(0xFFC9A84C), size: 48),
                          SizedBox(height: 12),
                          Text('Tap to add a photo',
                              style: TextStyle(color: Colors.white54, fontSize: 16)),
                          SizedBox(height: 4),
                          Text('Share your moment',
                              style: TextStyle(color: Colors.white38, fontSize: 13)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: captionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What's this moment about?",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9A84C),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _processing || _imageBytes == null ? null : () async {
                  setState(() => _processing = true);
                  final mediaUrl = await ApiService.uploadImage(_imageBytes!, 'moment.jpg');
                  await ApiService.createPost(
                    userId: 1,
                    username: 'briaannaab',
                    content: captionController.text.isEmpty
                        ? '✨ Moment'
                        : captionController.text,
                    mediaUrl: mediaUrl,
                  );
                  setState(() => _processing = false);
                  if (mounted) Navigator.pop(context);
                },
                child: _processing
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Share Moment',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
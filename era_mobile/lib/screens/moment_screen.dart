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
  Uint8List? _videoBytes;
  String? _videoName;
  final captionController = TextEditingController();
  bool _processing = false;
  String _type = 'photo'; // photo, video, text

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0008),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0008),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('New Moment',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Type selector
            Row(
              children: [
                _typeTab('photo', Icons.image_outlined, 'Photo'),
                const SizedBox(width: 12),
                _typeTab('video', Icons.videocam_outlined, 'Video'),
                const SizedBox(width: 12),
                _typeTab('text', Icons.edit_outlined, 'Text'),
              ],
            ),
            const SizedBox(height: 24),

            // Media picker
            if (_type == 'photo')
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.first.bytes != null) {
                    setState(() {
                      _imageBytes = result.files.first.bytes;
                      _videoBytes = null;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0A1A),
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
                            Icon(Icons.add_photo_alternate_outlined,
                                color: Color(0xFFC9A84C), size: 48),
                            SizedBox(height: 12),
                            Text('Tap to add a photo',
                                style: TextStyle(color: Colors.white54, fontSize: 16)),
                          ],
                        ),
                ),
              ),

            if (_type == 'video')
              GestureDetector(
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.video);
                  if (result != null && result.files.first.bytes != null) {
                    setState(() {
                      _videoBytes = result.files.first.bytes;
                      _videoName = result.files.first.name;
                      _imageBytes = null;
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A0A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _videoBytes != null
                          ? const Color(0xFFC9A84C)
                          : const Color(0xFF333333),
                    ),
                  ),
                  child: _videoBytes != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam, color: Color(0xFFC9A84C), size: 48),
                            const SizedBox(height: 12),
                            Text(_videoName ?? 'Video selected',
                                style: const TextStyle(color: Colors.white54, fontSize: 14)),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.video_call_outlined,
                                color: Color(0xFFC9A84C), size: 48),
                            SizedBox(height: 12),
                            Text('Tap to add a video',
                                style: TextStyle(color: Colors.white54, fontSize: 16)),
                          ],
                        ),
                ),
              ),

            if (_type == 'text')
              Container(
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A0A2A), Color(0xFF0A1A2A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC9A84C).withOpacity(0.3)),
                ),
                child: TextField(
                  controller: captionController,
                  style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.5),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: const InputDecoration(
                    hintText: 'Share your moment...',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Caption (for photo/video)
            if (_type != 'text')
              TextField(
                controller: captionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Add a caption...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1A0A1A),
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
                onPressed: _processing
                    ? null
                    : () async {
                        if (_type == 'text' && captionController.text.isEmpty) return;
                        if (_type == 'photo' && _imageBytes == null) return;
                        if (_type == 'video' && _videoBytes == null) return;

                        setState(() => _processing = true);
                        String? mediaUrl;

                        if (_type == 'photo' && _imageBytes != null) {
                          mediaUrl = await ApiService.uploadImage(_imageBytes!, 'moment.jpg');
                        } else if (_type == 'video' && _videoBytes != null) {
                          mediaUrl = await ApiService.uploadVideo(_videoBytes!, _videoName ?? 'moment.mp4');
                        }

                        await ApiService.createPost(
                          userId: 1,
                          username: 'briaannaab',
                          content: captionController.text.isEmpty ? '✨ Moment' : captionController.text,
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

  Widget _typeTab(String type, IconData icon, String label) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFC9A84C) : const Color(0xFF1A0A1A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white54,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}

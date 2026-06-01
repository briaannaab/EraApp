import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MomentScreen extends StatefulWidget {
  const MomentScreen({super.key});

  @override
  State<MomentScreen> createState() => _MomentScreenState();
}

class _MomentScreenState extends State<MomentScreen> {
  Uint8List? _mediaBytes;
  String? _videoName;
  bool _isVideo = false;
  final captionController = TextEditingController();
  bool _processing = false;
  bool _showCaption = false;

  Future<void> _pickMedia(ImageSource source, {bool video = false}) async {
    final picker = ImagePicker();
    if (video) {
      final v = await picker.pickVideo(source: source);
      if (v != null) {
        final bytes = await v.readAsBytes();
        setState(() { _mediaBytes = bytes; _videoName = v.name; _isVideo = true; });
      }
    } else {
      final img = await picker.pickImage(source: source);
      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() { _mediaBytes = bytes; _isVideo = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media preview or dark bg
            if (_mediaBytes != null && !_isVideo)
              Image.memory(_mediaBytes!, fit: BoxFit.cover)
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
                  ),
                ),
              ),

            // Overlay gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),

            // Top bar
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                  const Text('✦ moment',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  GestureDetector(
                    onTap: () => setState(() => _showCaption = !_showCaption),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_showCaption ? Icons.text_fields : Icons.text_fields_outlined,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Video indicator
            if (_mediaBytes != null && _isVideo)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.videocam, color: Colors.white, size: 48),
                    SizedBox(height: 12),
                    Text('Video ready', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),

            // No media placeholder
            if (_mediaBytes == null)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white24, size: 48),
                    SizedBox(height: 12),
                    Text('your moment', style: TextStyle(color: Colors.white24, fontSize: 16, letterSpacing: 2)),
                  ],
                ),
              ),

            // Caption overlay
            if (_showCaption)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: captionController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                    ),
                    maxLines: null,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: 'say something...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 22),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

            // Bottom controls
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Media source buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _sourceBtn(Icons.camera_alt_outlined, 'Camera', () => _pickMedia(ImageSource.camera)),
                      const SizedBox(width: 16),
                      _sourceBtn(Icons.photo_library_outlined, 'Gallery', () => _pickMedia(ImageSource.gallery)),
                      const SizedBox(width: 16),
                      _sourceBtn(Icons.videocam_outlined, 'Video', () => _pickMedia(ImageSource.camera, video: true)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Share button
                  GestureDetector(
                    onTap: _processing ? null : _share,
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _mediaBytes != null || captionController.text.isNotEmpty
                            ? Colors.white
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: _processing
                          ? const Center(child: SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2)))
                          : const Text('Share Moment',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sourceBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Future<void> _share() async {
    if (_mediaBytes == null && captionController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _processing = true);
    String? mediaUrl;
    if (_mediaBytes != null) {
      if (_isVideo) {
        mediaUrl = await ApiService.uploadVideo(_mediaBytes!, _videoName ?? 'moment.mp4');
      } else {
        mediaUrl = await ApiService.uploadImage(_mediaBytes!, 'moment.jpg');
      }
    }
    await ApiService.createPost(
      userId: AuthService.userId ?? 1,
      username: AuthService.username ?? 'briaannaab',
      content: captionController.text.isEmpty ? '✦' : captionController.text,
      mediaUrl: mediaUrl,
      isMoment: true,
    );
    setState(() => _processing = false);
    if (mounted) Navigator.pop(context);
  }
}

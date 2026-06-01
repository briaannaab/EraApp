import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MomentScreen extends StatefulWidget {
  const MomentScreen({super.key});

  @override
  State<MomentScreen> createState() => _MomentScreenState();
}

class _MomentScreenState extends State<MomentScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _cameraReady = false;
  bool _isRecording = false;
  bool _isFrontCamera = true;
  Uint8List? _capturedBytes;
  bool _isVideo = false;
  String? _videoPath;
  final captionController = TextEditingController();
  bool _showCaption = false;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isEmpty) return;
    final cam = _isFrontCamera
        ? _cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => _cameras.first)
        : _cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => _cameras.first);

    _cameraController = CameraController(cam, ResolutionPreset.high, enableAudio: true);
    await _cameraController!.initialize();
    if (mounted) setState(() => _cameraReady = true);
  }

  Future<void> _flipCamera() async {
    setState(() { _isFrontCamera = !_isFrontCamera; _cameraReady = false; });
    await _cameraController?.dispose();
    await _initCamera();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    final file = await _cameraController!.takePicture();
    final bytes = await file.readAsBytes();
    setState(() { _capturedBytes = bytes; _isVideo = false; });
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    await _cameraController!.startVideoRecording();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_isRecording) return;
    final file = await _cameraController!.stopVideoRecording();
    final bytes = await file.readAsBytes();
    setState(() { _capturedBytes = bytes; _isVideo = true; _videoPath = file.path; _isRecording = false; });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview or captured media
            if (_capturedBytes != null && !_isVideo)
              Image.memory(_capturedBytes!, fit: BoxFit.cover)
            else if (_cameraReady && _cameraController != null && _capturedBytes == null)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _cameraController!.value.previewSize!.height,
                    height: _cameraController!.value.previewSize!.width,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              )
            else if (_capturedBytes != null && _isVideo)
              Container(
                color: Colors.black,
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam, color: Colors.white, size: 48),
                      SizedBox(height: 12),
                      Text('Video captured', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: Colors.white)),

            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
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
                    onTap: () {
                      if (_capturedBytes != null) {
                        setState(() { _capturedBytes = null; _isVideo = false; });
                      } else {
                        Navigator.pop(context);
                      }
                    },
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
                  Row(
                    children: [
                      if (_capturedBytes != null)
                        GestureDetector(
                          onTap: () => setState(() => _showCaption = !_showCaption),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.text_fields, color: Colors.white, size: 20),
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (_capturedBytes == null)
                        GestureDetector(
                          onTap: _flipCamera,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 20),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Caption overlay
            if (_showCaption && _capturedBytes != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: TextField(
                    controller: captionController,
                    autofocus: true,
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
              bottom: 32,
              left: 0,
              right: 0,
              child: _capturedBytes == null
                  ? _cameraControls()
                  : _shareControls(),
            ),

            // Recording indicator
            if (_isRecording)
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                        SizedBox(width: 6),
                        Text('REC', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cameraControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('tap to photo · hold to video',
            style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Shutter button
            GestureDetector(
              onTap: _takePicture,
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: _isRecording ? Colors.red.withOpacity(0.8) : Colors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Container(
                    width: _isRecording ? 24 : 56,
                    height: _isRecording ? 24 : 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: _isRecording ? BorderRadius.circular(4) : BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _shareControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _processing ? null : _share,
          child: Container(
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
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
    );
  }

  Future<void> _share() async {
    if (_capturedBytes == null && captionController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() => _processing = true);
    String? mediaUrl;
    if (_capturedBytes != null) {
      if (_isVideo) {
        mediaUrl = await ApiService.uploadVideo(_capturedBytes!, _videoPath ?? 'moment.mp4');
      } else {
        mediaUrl = await ApiService.uploadImage(_capturedBytes!, 'moment.jpg');
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

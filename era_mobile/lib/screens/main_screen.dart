import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'live_screen.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'voice_screen.dart';
import 'moment_screen.dart';
import 'poll_screen.dart';
import 'prayer_screen.dart';
import 'notifications_screen.dart';

const List<Map<String, dynamic>> photoFilters = [
  {'name': 'None', 'matrix': <double>[1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0]},
  {'name': 'Warm', 'matrix': <double>[1.2,0,0,0,0, 0,1.0,0,0,0, 0,0,0.8,0,0, 0,0,0,1,0]},
  {'name': 'Cool', 'matrix': <double>[0.8,0,0,0,0, 0,1.0,0,0,0, 0,0,1.2,0,0, 0,0,0,1,0]},
  {'name': 'Noir', 'matrix': <double>[0.33,0.33,0.33,0,0, 0.33,0.33,0.33,0,0, 0.33,0.33,0.33,0,0, 0,0,0,1,0]},
  {'name': 'Fade', 'matrix': <double>[1,0,0,0,40, 0,1,0,0,40, 0,0,1,0,40, 0,0,0,0.8,0]},
  {'name': 'Vivid', 'matrix': <double>[1.4,0,0,0,-20, 0,1.4,0,0,-20, 0,0,1.4,0,-20, 0,0,0,1,0]},
  {'name': 'Dusk', 'matrix': <double>[1.1,0,0,0,10, 0,0.9,0,0,0, 0,0,0.8,0,20, 0,0,0,1,0]},
  {'name': 'Golden', 'matrix': <double>[1.3,0.1,0,0,10, 0.1,1.1,0,0,5, 0,0,0.7,0,0, 0,0,0,1,0]},
  {'name': 'Moody', 'matrix': <double>[0.8,0,0,0,-10, 0,0.7,0,0,-10, 0,0,0.9,0,-10, 0,0,0,1,0]},
  {'name': 'Soft', 'matrix': <double>[1,0,0,0,30, 0,1,0,0,30, 0,0,1,0,30, 0,0,0,0.85,0]},
  {'name': 'Vintage', 'matrix': <double>[0.9,0.1,0.1,0,10, 0.1,0.8,0.1,0,5, 0,0.1,0.7,0,0, 0,0,0,1,0]},
  {'name': 'Contrast', 'matrix': <double>[1.5,0,0,0,-40, 0,1.5,0,0,-40, 0,0,1.5,0,-40, 0,0,0,1,0]},
  {'name': 'Rose', 'matrix': <double>[1.2,0,0.1,0,10, 0,0.9,0.1,0,0, 0,0,0.8,0,0, 0,0,0,1,0]},
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 0=home, 1=messages

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < -300) {
            // Swipe left → Discover
            Navigator.push(context, _slideRoute(const DiscoverScreen(), fromRight: true));
          } else if (details.primaryVelocity! > 300) {
            // Swipe right → Profile
            Navigator.push(context, _slideRoute(ProfileScreen(username: AuthService.username ?? 'briaannaab'), fromRight: false));
          }
        },
        child: IndexedStack(
          index: _currentIndex,
          children: [
            const HomeScreen(),
            const MessagesScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onCreate: () => _showCreateMenu(context),
        onDiscover: () => Navigator.push(context, _slideRoute(const DiscoverScreen(), fromRight: true)),
        onProfile: () => Navigator.push(context, _slideRoute(ProfileScreen(username: AuthService.username ?? 'briaannaab'), fromRight: false)),
      ),
    );
  }

  PageRouteBuilder _slideRoute(Widget page, {required bool fromRight}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, _, child) {
        final offset = fromRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
        return SlideTransition(
          position: Tween<Offset>(begin: offset, end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  void _showCreateMenu(BuildContext context) {
    final outerContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('What would you like to share?',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _createOption(Icons.edit_outlined, 'Post', const Color(0xFF6C63FF), () {
                    Navigator.pop(context);
                    _showCreatePost(outerContext);
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.mic_outlined, 'Voice', const Color(0xFFFF6B35), () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(builder: (context) => const VoiceScreen()));
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.sensors, 'Live', const Color(0xFFFF3B5C), () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(
                      builder: (context) => const LiveScreen(channelName: "era_live_stream", isBroadcaster: true),
                    ));
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.bar_chart, 'Poll', const Color(0xFF00C9A7), () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(builder: (context) => const PollScreen()));
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.auto_awesome, 'Moment', Colors.white, () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(builder: (context) => const MomentScreen()));
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.volunteer_activism, 'Prayer', const Color(0xFFC084FC), () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(builder: (context) => const PrayerScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showCreatePost(BuildContext context) {
    final controller = TextEditingController();
    bool _posting = false;
    Uint8List? selectedImageBytes;
    Uint8List? selectedVideoBytes;
    String? selectedVideoName;
    String? selectedVibe;
    int selectedFilterIndex = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0A),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) => GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Post',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "What's your era?",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
              ),
              if (selectedImageBytes != null) ...[
                ColorFiltered(
                  colorFilter: ColorFilter.matrix(
                    List<double>.from(photoFilters[selectedFilterIndex]['matrix']),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(selectedImageBytes!, height: 200, fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: photoFilters.length,
                    itemBuilder: (context, index) {
                      final filter = photoFilters[index];
                      final isSelected = selectedFilterIndex == index;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedFilterIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.matrix(List<double>.from(filter['matrix'])),
                                    child: Image.memory(selectedImageBytes!, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(filter['name'] as String,
                                  style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.white38,
                                      fontSize: 9)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (selectedVideoBytes != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(selectedVideoName ?? 'Video selected',
                          style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              const Text('Set a vibe (optional)',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['Peaceful', 'Healing', 'Inspired', 'Energized', 'Quiet', 'Safe', 'Grounded']
                      .map((vibe) {
                    final isSelected = selectedVibe == vibe.toLowerCase();
                    return GestureDetector(
                      onTap: () => setModalState(() =>
                          selectedVibe = isSelected ? null : vibe.toLowerCase()),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(vibe,
                            style: TextStyle(
                                color: isSelected ? Colors.black : Colors.white54,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _mediaButton(Icons.camera_alt_outlined, 'Camera', () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        setModalState(() { selectedImageBytes = bytes; selectedVideoBytes = null; });
                      }
                    }),
                    const SizedBox(width: 8),
                    _mediaButton(Icons.photo_library_outlined, 'Gallery', () async {
                      final picker = ImagePicker();
                      final image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        final bytes = await image.readAsBytes();
                        setModalState(() { selectedImageBytes = bytes; selectedVideoBytes = null; });
                      }
                    }),
                    const SizedBox(width: 8),
                    _mediaButton(Icons.videocam_outlined, 'Record', () async {
                      final picker = ImagePicker();
                      final video = await picker.pickVideo(source: ImageSource.camera);
                      if (video != null) {
                        final bytes = await video.readAsBytes();
                        setModalState(() { selectedVideoBytes = bytes; selectedVideoName = video.name; selectedImageBytes = null; });
                      }
                    }),
                    const SizedBox(width: 8),
                    _mediaButton(Icons.video_library_outlined, 'Video', () async {
                      final picker = ImagePicker();
                      final video = await picker.pickVideo(source: ImageSource.gallery);
                      if (video != null) {
                        final bytes = await video.readAsBytes();
                        setModalState(() { selectedVideoBytes = bytes; selectedVideoName = video.name; selectedImageBytes = null; });
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (controller.text.isEmpty && selectedImageBytes == null && selectedVideoBytes == null) return;
                    FocusScope.of(context).unfocus();
                    setModalState(() => _posting = true);
                    String? mediaUrl;
                    if (selectedImageBytes != null) {
                      mediaUrl = await ApiService.uploadImage(selectedImageBytes!, 'post.jpg');
                    } else if (selectedVideoBytes != null) {
                      mediaUrl = await ApiService.uploadVideo(selectedVideoBytes!, selectedVideoName ?? 'video.mp4');
                    }
                    await ApiService.createPost(
                      userId: AuthService.userId ?? 1,
                      username: AuthService.username ?? 'briaannaab',
                      content: controller.text,
                      mediaUrl: mediaUrl,
                      vibe: selectedVibe,
                    );
                    Navigator.pop(context);
                  },
                  child: _posting
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mediaButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _createOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCreate;
  final VoidCallback onDiscover;
  final VoidCallback onProfile;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onCreate,
    required this.onDiscover,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navBtn(Icons.home_outlined, Icons.home, 0, currentIndex, onTap),
              GestureDetector(
                onTap: onDiscover,
                child: const Icon(Icons.explore_outlined, color: Colors.white38, size: 24),
              ),
              GestureDetector(
                onTap: onCreate,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.black, size: 24),
                ),
              ),
              _navBtn(Icons.chat_bubble_outline, Icons.chat_bubble, 1, currentIndex, onTap),
              GestureDetector(
                onTap: onProfile,
                child: const Icon(Icons.person_outline, color: Colors.white38, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, IconData activeIcon, int index, int currentIndex, ValueChanged<int> onTap) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Icon(
        isActive ? activeIcon : icon,
        color: isActive ? Colors.white : Colors.white38,
        size: 24,
      ),
    );
  }
}

// Need to import NotificationsScreen

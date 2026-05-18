import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'discover_screen.dart';
import 'messages_screen.dart';
import 'profile_screen.dart';
import 'live_screen.dart';
import '../services/api_service.dart';
import 'voice_screen.dart';
import 'moment_screen.dart';
import 'poll_screen.dart';
import 'prayer_screen.dart';

//photo filters
const List<Map<String, dynamic>> photoFilters = [
  {
    'name': 'None',
    'matrix': <double>[1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0],
  },
  {
    'name': 'Warm',
    'matrix': <double>[1.2,0,0,0,0, 0,1.0,0,0,0, 0,0,0.8,0,0, 0,0,0,1,0],
  },
  {
    'name': 'Cool',
    'matrix': <double>[0.8,0,0,0,0, 0,1.0,0,0,0, 0,0,1.2,0,0, 0,0,0,1,0],
  },
  {
    'name': 'Noir',
    'matrix': <double>[0.33,0.33,0.33,0,0, 0.33,0.33,0.33,0,0, 0.33,0.33,0.33,0,0, 0,0,0,1,0],
  },
  {
    'name': 'Fade',
    'matrix': <double>[1,0,0,0,40, 0,1,0,0,40, 0,0,1,0,40, 0,0,0,0.8,0],
  },
  {
    'name': 'Vivid',
    'matrix': <double>[1.4,0,0,0,-20, 0,1.4,0,0,-20, 0,0,1.4,0,-20, 0,0,0,1,0],
  },
  {
    'name': 'Dusk',
    'matrix': <double>[1.1,0,0,0,10, 0,0.9,0,0,0, 0,0,0.8,0,20, 0,0,0,1,0],
  },
];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const MessagesScreen(),
    ProfileScreen(username: 'briaannaab'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          border: Border(top: BorderSide(color: Color(0xFF1A1A1A))),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_outlined, Icons.home, 'Home', 0),
                _navItem(Icons.explore_outlined, Icons.explore, 'Discover', 1),
                _createButton(),
                _navItem(Icons.chat_bubble_outline, Icons.chat_bubble, 'Messages', 2),
                _navItem(Icons.person_outline, Icons.person, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, IconData activeIcon, String label, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? const Color(0xFFC9A84C) : Colors.white38,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFC9A84C) : Colors.white38,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createButton() {
    return GestureDetector(
      onTap: () => _showCreateMenu(context),
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFC9A84C), Color(0xFFE8C96A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x66C9A84C),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }

  void _showCreateMenu(BuildContext context) {
    final outerContext = context;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create', style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
            const Text('What would you like to share?',
                style: TextStyle(color: Colors.white38, fontSize: 14)),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _createOption(Icons.edit_outlined, 'Post', const Color(0xFF6C63FF), () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 0);
                    _showCreatePost(outerContext);
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.mic_outlined, 'Voice', const Color(0xFFFF6B35), () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(
                      builder: (context) => const VoiceScreen(),
                    ));
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.sensors, 'Live', const Color(0xFFFF3B5C), () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(
                      builder: (context) => const LiveScreen(
                        channelName: "era_live_stream",
                        isBroadcaster: true,
                      ),
                    ));
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.bar_chart, 'Poll', const Color(0xFF00C9A7), () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(
                      builder: (context) => const PollScreen(),
                    ));
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.auto_awesome, 'Moment', const Color(0xFFC9A84C), () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(
                      builder: (context) => const MomentScreen(),
                    ));
                  }),
                  const SizedBox(width: 16),
                  _createOption(Icons.volunteer_activism, 'Prayer', const Color(0xFFC084FC), () {
                    Navigator.pop(context);
                    Navigator.push(outerContext, MaterialPageRoute(
                      builder: (context) => const PrayerScreen(),
                    ));
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
    Uint8List? selectedImageBytes;
    Uint8List? selectedVideoBytes;
    String? selectedVideoName;
    String? selectedVibe;
    int selectedFilterIndex = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Post', style: TextStyle(
                color: Color(0xFFC9A84C),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              )),
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
                                    color: isSelected ? const Color(0xFFC9A84C) : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.matrix(
                                      List<double>.from(filter['matrix']),
                                    ),
                                    child: Image.memory(selectedImageBytes!, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(filter['name'] as String,
                                  style: TextStyle(
                                      color: isSelected ? const Color(0xFFC9A84C) : Colors.white38,
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
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, color: Color(0xFFC9A84C)),
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
                  children: [
                    'Peaceful', 'Healing', 'Inspired', 'Energized', 'Quiet', 'Safe', 'Grounded'
                  ].map((vibe) {
                    final isSelected = selectedVibe == vibe.toLowerCase();
                    return GestureDetector(
                      onTap: () => setModalState(() =>
                          selectedVibe = isSelected ? null : vibe.toLowerCase()),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFC9A84C) : const Color(0xFF2A2A2A),
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null && result.files.first.bytes != null) {
                        setModalState(() {
                          selectedImageBytes = result.files.first.bytes;
                          selectedVideoBytes = null;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF333333)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.image_outlined, color: Colors.white54, size: 18),
                          SizedBox(width: 6),
                          Text('Photo', style: TextStyle(color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(type: FileType.video);
                      if (result != null && result.files.first.bytes != null) {
                        setModalState(() {
                          selectedVideoBytes = result.files.first.bytes;
                          selectedVideoName = result.files.first.name;
                          selectedImageBytes = null;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF333333)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_outlined, color: Colors.white54, size: 18),
                          SizedBox(width: 6),
                          Text('Video', style: TextStyle(color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A84C),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    if (controller.text.isEmpty && selectedImageBytes == null && selectedVideoBytes == null) return;
                    String? mediaUrl;
                    if (selectedImageBytes != null) {
                      mediaUrl = await ApiService.uploadImage(selectedImageBytes!, 'post.jpg');
                    } else if (selectedVideoBytes != null) {
                      mediaUrl = await ApiService.uploadVideo(selectedVideoBytes!, selectedVideoName ?? 'video.mp4');
                    }
                    await ApiService.createPost(
                      userId: 1,
                      username: 'briaannaab',
                      content: controller.text,
                      mediaUrl: mediaUrl,
                      vibe: selectedVibe,
                    );
                    Navigator.pop(context);
                    setState(() => _currentIndex = 0);
                  },
                  child: const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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

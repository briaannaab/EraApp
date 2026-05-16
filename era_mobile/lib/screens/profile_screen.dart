import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profile;
  bool loading = true;
  String selectedTheme = 'default';
  Color? customAccentColor;
  String? profileImageUrl;
  final String currentUser = 'briaannaab';

  final Map<String, List<Color>> themes = {
    'default': [const Color(0xFF1a0033), const Color(0xFF080808)],
    'cosmic': [const Color(0xFF0a0a2e), const Color(0xFF1a0040)],
    'aurora': [const Color(0xFF002a1a), const Color(0xFF001a0a)],
    'ember': [const Color(0xFF2a0a00), const Color(0xFF1a0500)],
    'ocean': [const Color(0xFF001a2a), const Color(0xFF000a1a)],
  };

  final Map<String, Color> themeAccents = {
    'default': const Color(0xFFC9A84C),
    'cosmic': const Color(0xFF8B9FFF),
    'aurora': const Color(0xFF4ECDC4),
    'ember': const Color(0xFFFF6B35),
    'ocean': const Color(0xFF4FC3F7),
  };

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/${widget.username}/profile'),
    );
    if (response.statusCode == 200) {
      setState(() {
        profile = jsonDecode(response.body);
        loading = false;
      });
    }
  }

  Future<void> pickProfileImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.first.bytes != null) {
      final url = await ApiService.uploadImage(result.files.first.bytes!, 'profile.jpg');
      if (url != null) setState(() => profileImageUrl = url);
    }
  }

  Future<void> showColorPicker(Color currentColor) async {
    Color picked = currentColor;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Pick a color', style: TextStyle(color: Colors.white)),
        content: ColorPicker(
          color: picked,
          onColorChanged: (color) => picked = color,
          width: 40,
          height: 40,
          borderRadius: 8,
          pickersEnabled: const {
            ColorPickerType.wheel: true,
            ColorPickerType.primary: false,
            ColorPickerType.accent: false,
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => customAccentColor = picked);
              Navigator.pop(context);
            },
            child: const Text('Apply', style: TextStyle(color: Color(0xFFC9A84C))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = themes[selectedTheme]!;
    final accent = customAccentColor ?? themeAccents[selectedTheme]!;
    final isOwnProfile = widget.username == currentUser;

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : profile == null
              ? const Center(child: Text('User not found', style: TextStyle(color: Colors.white54)))
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: gradient,
                    ),
                  ),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Top bar
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (Navigator.canPop(context))
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(Icons.arrow_back_ios, color: accent, size: 20),
                                    )
                                  else
                                    const SizedBox(width: 20),
                                  Row(
                                    children: [
                                      if (isOwnProfile)
                                        GestureDetector(
                                          onTap: () async {
                                            final updated = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EditProfileScreen(profile: profile!),
                                              ),
                                            );
                                            if (updated == true) loadProfile();
                                          },
                                          child: Icon(Icons.edit_outlined, color: accent, size: 20),
                                        ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () => showModalBottomSheet(
                                          context: context,
                                          backgroundColor: const Color(0xFF1A1A1A),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (context) => Padding(
                                            padding: const EdgeInsets.all(24),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 40, height: 4,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white24,
                                                    borderRadius: BorderRadius.circular(2),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                if (isOwnProfile) ...[
                                                  _menuItem(Icons.share_outlined, 'Share Profile', accent, () => Navigator.pop(context)),
                                                  _menuItem(Icons.settings_outlined, 'Settings', accent, () => Navigator.pop(context)),
                                                ] else ...[
                                                  _menuItem(Icons.share_outlined, 'Share Profile', accent, () => Navigator.pop(context)),
                                                  _menuItem(Icons.block_outlined, 'Block @${widget.username}', Colors.orange, () => Navigator.pop(context)),
                                                  _menuItem(Icons.flag_outlined, 'Report @${widget.username}', Colors.red, () => Navigator.pop(context)),
                                                ],
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          ),
                                        ),
                                        child: Icon(Icons.more_horiz, color: accent, size: 20),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Avatar with camera button
                          Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: accent.withOpacity(0.4),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 45,
                                  backgroundColor: accent.withOpacity(0.2),
                                  backgroundImage: profileImageUrl != null
                                      ? NetworkImage(profileImageUrl!) : null,
                                  child: profileImageUrl == null
                                      ? Text(
                                          widget.username[0].toUpperCase(),
                                          style: TextStyle(
                                            color: accent,
                                            fontSize: 36,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              if (isOwnProfile)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: pickProfileImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF080808), width: 2),
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 14),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.username,
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              if (profile!['is_creator'] == true) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.verified, color: accent, size: 18),
                              ],
                            ],
                          ),

                          Text('@${widget.username}',
                              style: TextStyle(color: accent.withOpacity(0.7), fontSize: 13)),

                          if (profile!['bio'] != null && profile!['bio'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                              child: Text(
                                profile!['bio'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _stat('${profile!['post_count']}', 'Posts', accent),
                              Container(width: 1, height: 30, color: accent.withOpacity(0.2)),
                              _stat('${profile!['followers']}', 'Followers', accent),
                              Container(width: 1, height: 30, color: accent.withOpacity(0.2)),
                              _stat('${profile!['following']}', 'Following', accent),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Action buttons
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                if (!isOwnProfile) ...[
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: accent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text('Follow',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          currentUser: currentUser,
                                          otherUser: widget.username,
                                        ),
                                      )),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(
                                          color: accent.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: accent.withOpacity(0.3)),
                                        ),
                                        child: Text('Message',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ),
                                ] 
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Creator earnings
                          if (profile!['is_creator'] == true && isOwnProfile)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: accent.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.monetization_on_outlined, color: accent),
                                    const SizedBox(width: 10),
                                    Text('\$${profile!['tips_received'].toStringAsFixed(2)} earned',
                                        style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                              ),
                            ),

                          // Themes
                          if (isOwnProfile) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Themes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text('Customize', style: TextStyle(color: accent, fontSize: 13)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 52,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                children: [
                                  ...themes.keys.map((theme) {
                                    final isSelected = selectedTheme == theme && customAccentColor == null;
                                    final colors = themes[theme]!;
                                    return GestureDetector(
                                      onTap: () => setState(() {
                                        selectedTheme = theme;
                                        customAccentColor = null;
                                      }),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        margin: const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(colors: colors),
                                          border: Border.all(
                                            color: isSelected ? themeAccents[theme]! : Colors.transparent,
                                            width: 2.5,
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  // Custom color picker
                                  GestureDetector(
                                    onTap: () => showColorPicker(customAccentColor ?? themeAccents[selectedTheme]!),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const SweepGradient(colors: [
                                          Colors.red, Colors.yellow, Colors.green,
                                          Colors.blue, Colors.purple, Colors.red,
                                        ]),
                                        border: Border.all(
                                          color: customAccentColor != null ? Colors.white : Colors.transparent,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: const Icon(Icons.colorize, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Pinned Moments
                          if (profile!['posts'] != null && (profile!['posts'] as List).isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Pinned Moments', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text('See all', style: TextStyle(color: accent, fontSize: 13)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: (profile!['posts'] as List).take(5).length,
                                itemBuilder: (context, index) {
                                  final post = profile!['posts'][index];
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: accent.withOpacity(0.2)),
                                    ),
                                    child: post['media_url'] != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.network(post['media_url'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) =>
                                                    Icon(Icons.image_outlined, color: accent)),
                                          )
                                        : Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(post['content'] ?? '',
                                                  maxLines: 4,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: accent.withOpacity(0.8), fontSize: 10)),
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // Posts grid
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Posts', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                            ),
                            itemCount: (profile!['posts'] as List).length,
                            itemBuilder: (context, index) {
                              final post = profile!['posts'][index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: post['media_url'] != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(post['media_url'],
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                Icon(Icons.play_circle_outline, color: accent)),
                                      )
                                    : Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Text(post['content'] ?? '',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(color: accent.withOpacity(0.7), fontSize: 9)),
                                        ),
                                      ),
                              );
                            },
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
Widget _menuItem(IconData icon, String label, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(color: color, fontSize: 15)),
        ],
      ),
    ),
  );
}
  Widget _stat(String value, String label, Color accent) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        Text(label, style: TextStyle(color: accent.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }
}

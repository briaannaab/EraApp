import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'post_detail_screen.dart';
import 'followers_screen.dart';

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
    'default': [const Color(0xFF000000), const Color(0xFF000000)],
    'cosmic': [const Color(0xFF0a0a2e), const Color(0xFF000000)],
    'aurora': [const Color(0xFF002a1a), const Color(0xFF00080A)],
    'ember': [const Color(0xFF2a0a00), const Color(0xFF0A0000)],
    'ocean': [const Color(0xFF001a2a), const Color(0xFF00080D)],
  };

  final Map<String, Color> themeAccents = {
    'default': const Color(0xFFFFFFFF),
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
        backgroundColor: const Color(0xFF0A0A0A),
        title: const Text('Pick your aura color', style: TextStyle(color: Colors.white)),
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
            child: const Text('Apply', style: TextStyle(color: Color(0xFFFFFFFF))),
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
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFFFFF)))
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
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text('era.',
                                    style: TextStyle(
                                        color: accent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5)),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Navigator.canPop(context)
                                      ? GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.arrow_back_ios_new, color: accent, size: 16),
                                          ),
                                        )
                                      : const SizedBox(width: 36),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
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
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.edit_outlined, color: accent, size: 16),
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => showModalBottomSheet(
                                          context: context,
                                          backgroundColor: const Color(0xFF0A0A0A),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                                                  _menuItem(Icons.settings_outlined, 'Settings', accent, () {
                                                    Navigator.pop(context);
                                                    Navigator.push(context, MaterialPageRoute(
                                                      builder: (context) => const SettingsScreen(),
                                                    ));
                                                  }),
                                                ] else ...[
                                                  _menuItem(Icons.share_outlined, 'Share Profile', accent, () => Navigator.pop(context)),
                                                  _menuItem(Icons.block_outlined, 'Block @\${widget.username}', Colors.orange, () => Navigator.pop(context)),
                                                  _menuItem(Icons.flag_outlined, 'Report @\${widget.username}', Colors.red, () => Navigator.pop(context)),
                                                ],
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.more_horiz, color: accent, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                                                    const SizedBox(height: 32),

                          // Hero avatar with aura glow
                          Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        accent.withOpacity(0.3),
                                        accent.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: accent, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundColor: accent.withOpacity(0.15),
                                    backgroundImage: profileImageUrl != null
                                        ? NetworkImage(profileImageUrl!) : null,
                                    child: profileImageUrl == null
                                        ? Text(
                                            widget.username[0].toUpperCase(),
                                            style: TextStyle(
                                              color: accent,
                                              fontSize: 40,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                if (isOwnProfile)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: pickProfileImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: accent,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF000000), width: 2),
                                        ),
                                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.username,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5)),
                              if (profile!['is_creator'] == true) ...[
                                const SizedBox(width: 6),
                                Icon(Icons.verified, color: accent, size: 20),
                              ],
                            ],
                          ),

                          Text('@${widget.username}',
                              style: TextStyle(color: accent.withOpacity(0.6), fontSize: 13)),

                          const SizedBox(height: 12),

                          if (profile!['bio'] != null && profile!['bio'].isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 48),
                              child: Text(
                                profile!['bio'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6),
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Floating glass stats card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: accent.withOpacity(0.2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.05),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: _stat('${profile!["post_count"]}', 'Posts', accent),
                                    ),
                                    Container(width: 1, height: 30, color: accent.withOpacity(0.2)),
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => FollowersScreen(username: widget.username),
                                      )),
                                      child: _stat('${profile!["followers"]}', 'Followers', accent),
                                    ),
                                    Container(width: 1, height: 30, color: accent.withOpacity(0.2)),
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(
                                        builder: (context) => FollowersScreen(username: widget.username, showFollowing: true),
                                      )),
                                      child: _stat('${profile!["following"]}', 'Following', accent),
                                    ),
                                  ],
                                ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          if (!isOwnProfile)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                              onTap: () async {
                                                await ApiService.followUser(widget.username);
                                                loadProfile();
                                              },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [accent, accent.withOpacity(0.7)],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: accent.withOpacity(0.3),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                        child: const Text('Follow',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
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
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: accent.withOpacity(0.3)),
                                        ),
                                        child: Text('Message',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: accent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          if (profile!['is_creator'] == true && isOwnProfile)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(32, 0, 32, 20),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: accent.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: accent.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.monetization_on_outlined, color: accent, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('\$${profile!["tips_received"].toStringAsFixed(2)}',
                                            style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 18)),
                                        const Text('Total earned',
                                            style: TextStyle(color: Colors.white38, fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          if (isOwnProfile) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              child: Row(
                                children: [
                                  Text('Aura',
                                      style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  const SizedBox(width: 8),
                                  Text('Choose your vibe color',
                                      style: TextStyle(color: Colors.white38, fontSize: 11)),
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

                          if (profile!['posts'] != null && (profile!['posts'] as List).isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              child: Row(
                                children: [
                                  Text('Moments',
                                      style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                  const SizedBox(width: 8),
                                  Text('${profile!["post_count"]} posts',
                                      style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: (profile!['posts'] as List).take(6).length,
                                itemBuilder: (context, index) {
                                  final post = profile!['posts'][index];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => PostDetailScreen(
                                        post: Map<String, dynamic>.from(post),
                                        allPosts: (profile!['posts'] as List).map((p) => Map<String, dynamic>.from(p)).toList(),
                                        initialIndex: index,
                                      ),
                                    )),
                                    child: Container(
                                      width: 110,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: accent.withOpacity(0.15)),
                                      ),
                                      child: post['media_url'] != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  Image.network(post['media_url'], fit: BoxFit.cover,
                                                      errorBuilder: (c, e, s) => Icon(Icons.image_outlined, color: accent)),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.bottomCenter,
                                                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Text(post['content'] ?? '',
                                                  maxLines: 5,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11, height: 1.4)),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (profile!['posts'] != null && (profile!['posts'] as List).isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                              child: Text('All Posts',
                                  style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: (profile!['posts'] as List).length,
                                itemBuilder: (context, index) {
                                  final post = profile!['posts'][index];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => PostDetailScreen(
                                        post: Map<String, dynamic>.from(post),
                                        allPosts: (profile!['posts'] as List).map((p) => Map<String, dynamic>.from(p)).toList(),
                                        initialIndex: index,
                                      ),
                                    )),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: accent.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: accent.withOpacity(0.1)),
                                      ),
                                      child: post['media_url'] != null
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(16),
                                              child: Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  Image.network(post['media_url'], fit: BoxFit.cover,
                                                      errorBuilder: (c, e, s) => Center(child: Icon(Icons.play_circle_outline, color: accent, size: 32))),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin: Alignment.topCenter,
                                                        end: Alignment.bottomCenter,
                                                        colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 10, left: 10,
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.favorite, color: Colors.white, size: 12),
                                                        const SizedBox(width: 4),
                                                        Text('${post["likes"] ?? 0}',
                                                            style: const TextStyle(color: Colors.white, fontSize: 11)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.all(14),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (post['vibe'] != null)
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 8),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: accent.withOpacity(0.15),
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Text('✨ ${post["vibe"]}',
                                                          style: TextStyle(color: accent, fontSize: 9)),
                                                    ),
                                                  Expanded(
                                                    child: Text(post['content'] ?? '',
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 6,
                                                        style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.5)),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(Icons.favorite_border, color: accent, size: 12),
                                                      const SizedBox(width: 4),
                                                      Text('${post["likes"] ?? 0}',
                                                          style: TextStyle(color: accent, fontSize: 11)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: accent.withOpacity(0.6), fontSize: 11, letterSpacing: 0.5)),
      ],
    );
  }
}

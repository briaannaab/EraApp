import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'chat_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'post_detail_screen.dart';
import 'followers_screen.dart';


String? getVideoThumbnail(String? url) {
  if (url == null) return null;
  if (url.contains('/video/upload/')) {
    return url
        .replaceAll('/video/upload/', '/video/upload/so_0,f_jpg/')
        .replaceAll('.mp4', '.jpg')
        .replaceAll('.mov', '.jpg');
  }
  return url;
}

bool isVideo(String? url) {
  if (url == null) return false;
  return url.contains('/video/upload/') ||
      url.contains('.mp4') ||
      url.contains('.mov');
}

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
  String get currentUser => AuthService.username ?? 'briaannaab';
  bool isSubscribed = false;
  int subscriberCount = 0;
  double creatorEarnings = 0.0;
  int selectedTab = 0; // 0=posts, 1=moments, 2=vibes

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
    loadSubscriptionData();
  }

  Future<void> loadSubscriptionData() async {
    try {
      final count = await ApiService.getSubscriberCount(widget.username);
      final earnings = await ApiService.getCreatorEarnings(widget.username);
      final subscribed = AuthService.userId != null
          ? await ApiService.checkSubscription(widget.username, AuthService.userId!)
          : false;
      if (mounted) setState(() {
        subscriberCount = count;
        creatorEarnings = earnings;
        isSubscribed = subscribed;
      });
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> loadProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/${widget.username}/profile'),
    );
    if (response.statusCode == 200) {
      setState(() {
        profile = jsonDecode(response.body);
        loading = false;
        if (profile!['profile_picture_url'] != null) {
          profileImageUrl = profile!['profile_picture_url'];
        }
        if (profile!['aura_theme'] != null) {
          selectedTheme = profile!['aura_theme'];
        }
        if (profile!['aura_color'] != null) {
          final hex = profile!['aura_color'] as String;
          customAccentColor = Color(int.parse(hex, radix: 16));
        }
      });
    } else {
      setState(() => loading = false);
    }
  }
  Future<void> pickProfileImageFuture<void> pickProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final url = await ApiService.uploadImage(bytes, 'profile.jpg');
      if (url != null) {
        setState(() => profileImageUrl = url);
        // Save to database
        await http.post(
          Uri.parse('$baseUrl/users/${AuthService.userId ?? 1}/profile-picture?url=${Uri.encodeComponent(url)}'),
        );
      }
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
            onPressed: () async {
              setState(() => customAccentColor = picked);
              Navigator.pop(context);
              await http.post(
                Uri.parse('$baseUrl/users/${AuthService.userId ?? 1}/aura'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({'theme': selectedTheme, 'color': picked.value.toRadixString(16)}),
              );
            },
            child: const Text('Apply', style: TextStyle(color: Colors.white)),
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
      backgroundColor: Colors.black,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
                                                  _menuItem(Icons.block_outlined, 'Block @${widget.username}', Colors.orange, () => Navigator.pop(context)),
                                                  _menuItem(Icons.flag_outlined, 'Report @${widget.username}', Colors.red, () => Navigator.pop(context)),
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

                          // Avatar
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
                                            style: TextStyle(color: accent, fontSize: 40, fontWeight: FontWeight.bold),
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
                                          border: Border.all(color: Colors.black, width: 2),
                                        ),
                                        child: const Icon(Icons.camera_alt, color: Colors.black, size: 12),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.username,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5)),
                              const SizedBox(width: 6),
                              Icon(Icons.verified, color: accent, size: 20),
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

                          // Stats
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: accent.withOpacity(0.2)),
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

                          // Action buttons
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
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                                        ),
                                        child: const Text('Follow',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                      ),
                                    ),
                                  ),
                                  if (profile!['is_creator_subscription'] == true) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (isSubscribed) {
                                            await ApiService.unsubscribe(widget.username, AuthService.userId ?? 1);
                                          } else {
                                            await ApiService.subscribe(
                                              widget.username,
                                              AuthService.userId ?? 1,
                                              AuthService.username ?? 'briaannaab',
                                            );
                                          }
                                          loadSubscriptionData();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: isSubscribed ? Colors.white.withOpacity(0.05) : Colors.transparent,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isSubscribed ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.4),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                isSubscribed ? Icons.check_circle_outline : Icons.stars_outlined,
                                                color: isSubscribed ? Colors.white38 : Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                isSubscribed ? 'Subscribed' : 'Subscribe',
                                                style: TextStyle(
                                                  color: isSubscribed ? Colors.white38 : Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                                        ),
                                        child: const Text('Message',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Aura themes
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
                                      onTap: () async {
                                        setState(() {
                                          selectedTheme = theme;
                                          customAccentColor = null;
                                        });
                                        await http.post(
                                          Uri.parse('$baseUrl/users/${AuthService.userId ?? 1}/aura'),
                                          headers: {'Content-Type': 'application/json'},
                                          body: jsonEncode({'theme': theme, 'color': null}),
                                        );
                                      },
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

                          // Tabs
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                _profileTab('Posts', 0, accent),
                                _profileTab('Moments', 1, accent),
                                _profileTab('Vibes', 2, accent),
                              ],
                            ),
                          ),
                          Container(height: 1, color: Colors.white.withOpacity(0.08)),
                          const SizedBox(height: 16),

                          // Posts tab
                          if (selectedTab == 0 && profile!['posts'] != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: 1,
                                ),
                                itemCount: (profile!['posts'] as List).where((p) => p['is_moment'] == false || p['is_moment'] == null).length,
                                itemBuilder: (context, index) {
                                  final posts = (profile!['posts'] as List).where((p) => p['is_moment'] == false || p['is_moment'] == null).toList();
                                  if (index >= posts.length) return const SizedBox();
                                  final post = posts[index];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => PostDetailScreen(
                                        post: Map<String, dynamic>.from(post),
                                        allPosts: posts.map((p) => Map<String, dynamic>.from(p)).toList(),
                                        initialIndex: index,
                                      ),
                                    )),
                                    child: Container(
                                      color: const Color(0xFF0A0A0A),
                                      child: post['media_url'] != null
                                          ? Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                Image.network(
                                                  getVideoThumbnail(post['media_url']) ?? post['media_url'],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_outlined, color: Colors.white24, size: 24)),
                                                ),
                                                if (isVideo(post['media_url']))
                                                  const Positioned(top: 4, right: 4, child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 16)),
                                              ],
                                            )
                                          : Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Text(post['content'] ?? '',
                                                    maxLines: 4,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // Moments tab
                          if (selectedTab == 1 && profile!['posts'] != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                  childAspectRatio: 0.7,
                                ),
                                itemCount: (profile!['posts'] as List).where((p) => p['is_moment'] == true).length,
                                itemBuilder: (context, index) {
                                  final moments = (profile!['posts'] as List).where((p) => p['is_moment'] == true).toList();
                                  if (index >= moments.length) return const SizedBox();
                                  final moment = moments[index];
                                  return Container(
                                    color: const Color(0xFF0A0A0A),
                                    child: moment['media_url'] != null
                                        ? Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.network(
                                                getVideoThumbnail(moment['media_url']) ?? moment['media_url'],
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.auto_awesome, color: Colors.white24, size: 20)),
                                              ),
                                              const Positioned(top: 4, right: 4,
                                                child: Text('✦', style: TextStyle(color: Colors.white54, fontSize: 10))),
                                            ],
                                          )
                                        : Center(
                                            child: Text(moment['content'] ?? '✦',
                                                maxLines: 3,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                          ),
                                  );
                                },
                              ),
                            ),
                          ],

                          // Vibes tab
                          if (selectedTab == 2)
                            Padding(
                              padding: const EdgeInsets.all(40),
                              child: Center(child: Text('Vibes coming soon',
                                  style: TextStyle(color: accent.withOpacity(0.4), fontSize: 13))),
                            ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _profileTab(String label, int index, Color accent) {
    final isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? accent : Colors.transparent,
                width: 1.5,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? accent : Colors.white24,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              letterSpacing: 1,
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

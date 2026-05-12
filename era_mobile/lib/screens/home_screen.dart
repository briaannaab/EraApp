import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../services/api_service.dart';
import 'profile_screen.dart';
import 'comments_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> posts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final data = await ApiService.getPosts();
      setState(() {
        posts = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      extendBodyBehindAppBar: true,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)))
          : posts.isEmpty
              ? const Center(
                  child: Text('No posts yet. Be first! 👑',
                      style: TextStyle(color: Colors.white54)))
              : Stack(
                  children: [
                    PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return _ImmersivePostCard(
                          post: posts[index],
                          onLike: loadPosts,
                        );
                      },
                    ),
                    // Floating header
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'era.',
                            style: TextStyle(
                              color: Color(0xFFC9A84C),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.search, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ImmersivePostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;

  const _ImmersivePostCard({required this.post, required this.onLike});

  @override
  Widget build(BuildContext context) {
    final isVideo = post['media_url'] != null &&
        (post['media_url'].toString().contains('.mp4') ||
         post['media_url'].toString().contains('.mov') ||
         post['media_url'].toString().contains('video'));
    final username = (post['username'] ?? 'unknown') as String;
    final hasMedia = post['media_url'] != null;

    return Container(
      color: const Color(0xFF050505),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background media
          if (hasMedia)
            isVideo
                ? _VideoPlayer(url: post['media_url'])
                : Image.network(
                    post['media_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(color: const Color(0xFF1A1A1A)),
                  )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A0A2A), Color(0xFF0A1A2A)],
                ),
              ),
            ),

          // Cinematic gradient overlay
          Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.95),
              ],
              stops: const [0.0, 0.3, 0.6, 1.0],
            ),
          ),
        ),
          // Right side actions
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _ActionButton(
                  icon: Icons.favorite_border,
                  label: '${post['likes'] ?? 0}',
                  onTap: () async {
                    await ApiService.likePost(post['id']);
                    onLike();
                  },
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CommentsScreen(post: post),
                  ),
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  icon: Icons.monetization_on_outlined,
                  label: '\$${(post['tips'] ?? 0.0).toStringAsFixed(0)}',
                  color: const Color(0xFFC9A84C),
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _ActionButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Bottom info
          Positioned(
            left: 16,
            right: 80,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(username: username),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF2A1A4A),
                        child: Text(
                          username[0].toUpperCase(),
                          style: const TextStyle(color: Color(0xFFC9A84C), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '@$username',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post['content'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _VideoPlayer extends StatefulWidget {
  final String url;
  const _VideoPlayer({required this.url});

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoController,
            autoPlay: true,
            looping: true,
            showControls: false,
            aspectRatio: _videoController.value.aspectRatio,
          );
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFC9A84C)));
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController.value.size.width,
          height: _videoController.value.size.height,
          child: Chewie(controller: _chewieController!),
        ),
      ),
    );
  }

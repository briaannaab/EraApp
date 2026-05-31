import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'profile_screen.dart';
import 'comments_screen.dart';
import 'notifications_screen.dart';
import 'discover_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> posts = [];
  List<dynamic> moments = [];
  bool loading = true;
  int currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final data = await ApiService.getPosts();
      final momentData = await ApiService.getMoments();
      setState(() {
        posts = data;
        moments = momentData;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void _showMomentViewer(BuildContext context, int startIndex) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => _MomentViewer(moments: moments, startIndex: startIndex),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : posts.isEmpty
              ? const Center(
                  child: Text('No posts yet. Be first! 👑',
                      style: TextStyle(color: Colors.white54)))
              : Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: posts.length,
                      onPageChanged: (index) => setState(() => currentIndex = index),
                      itemBuilder: (context, index) {
                        return _ImmersivePostCard(
                          post: posts[index],
                          onRefresh: loadPosts,
                        );
                      },
                    ),

                    // Story strip
                    if (moments.isNotEmpty)
                      Positioned(
                        top: 110,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: moments.length,
                            itemBuilder: (context, index) {
                              final moment = moments[index];
                              return GestureDetector(
                                onTap: () => _showMomentViewer(context, index),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                          image: moment['media_url'] != null
                                              ? DecorationImage(
                                                  image: NetworkImage(moment['media_url']),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: const Color(0xFF1A1A1A),
                                        ),
                                        child: moment['media_url'] == null
                                            ? const Icon(Icons.auto_awesome, color: Colors.white, size: 24)
                                            : null,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        moment['username'] ?? '',
                                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    // Header
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('era.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              )),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const DiscoverScreen(),
                                )),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.search, color: Colors.white, size: 20),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => const NotificationsScreen(),
                                )),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Floating bar
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(posts.length.clamp(0, 5), (i) {
                                final isActive = i == currentIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: isActive ? 16 : 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white : Colors.white30,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _ImmersivePostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final VoidCallback onRefresh;

  const _ImmersivePostCard({required this.post, required this.onRefresh});

  @override
  State<_ImmersivePostCard> createState() => _ImmersivePostCardState();
}

class _ImmersivePostCardState extends State<_ImmersivePostCard>
    with SingleTickerProviderStateMixin {
  bool _showRing = false;
  bool _liked = false;
  late AnimationController _ringController;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _ringAnimation = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  void _showRadialRing() {
    setState(() => _showRing = true);
    _ringController.forward();
  }

  void _hideRadialRing() {
    _ringController.reverse().then((_) {
      if (mounted) setState(() => _showRing = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final username = (widget.post['username'] ?? 'unknown') as String;
    final hasMedia = widget.post['media_url'] != null;
    final isOwner = username == (AuthService.username ?? 'briaannaab');
    final isVideo = hasMedia &&
        (widget.post['media_url'].toString().contains('.mp4') ||
         widget.post['media_url'].toString().contains('.mov') ||
         widget.post['media_url'].toString().contains('video'));

    return GestureDetector(
      onDoubleTap: () async {
        setState(() => _liked = true);
        await ApiService.likePost(widget.post['id']);
        widget.onRefresh();
      },
      onLongPressStart: (_) => _showRadialRing(),
      // onLongPressEnd: (_) => _hideRadialRing(),
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media
            if (hasMedia)
              isVideo
                  ? _VideoPlayer(url: widget.post['media_url'])
                  : Image.network(
                      widget.post['media_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(color: const Color(0xFF0A0A0A)),
                    )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0A0A0A), Color(0xFF1A1A1A)],
                  ),
                ),
              ),

            // Gradient overlay
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

            // Double tap like animation
            if (_liked)
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value < 0.5 ? value * 2 : (1 - value) * 2,
                      child: Transform.scale(
                        scale: 0.5 + value,
                        child: const Icon(Icons.favorite, color: Colors.white, size: 80),
                      ),
                    );
                  },
                  onEnd: () => setState(() => _liked = false),
                ),
              ),

            // Post info
            Positioned(
              left: 16,
              right: 80,
              bottom: 130,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ProfileScreen(username: username),
                    )),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFF1A1A1A),
                          child: Text(username[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Text('@$username',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.post['content'] != null && widget.post['content'].isNotEmpty)
                    Text(widget.post['content'],
                        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis),
                  if (widget.post['vibe'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Text('✨ ${widget.post['vibe']}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      ),
                    ),
                ],
              ),
            ),

            // Hold hint
            Positioned(
              right: 16,
              bottom: 130,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.more_horiz, color: Colors.white54, size: 20),
                  ),
                  const SizedBox(height: 4),
                  const Text('hold', style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  const Text('❤️', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  const Text('2x tap', style: TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1)),
                ],
              ),
            ),



            // Radial ring
            if (_showRing)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _hideRadialRing,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: ScaleTransition(
                      scale: _ringAnimation,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer ring
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                              ),
                            ),
                            // Inner ring
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
                              ),
                            ),
                            // Center - delete if owner, close if not
                            GestureDetector(
                              onTap: () async {
                                if (isOwner) {
                                  _hideRadialRing();
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFF0A0A0A),
                                      title: const Text('Delete post?', style: TextStyle(color: Colors.white)),
                                      content: const Text('This cannot be undone.', style: TextStyle(color: Colors.white54)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await ApiService.deletePost(widget.post['id']);
                                    widget.onRefresh();
                                  }
                                } else {
                                  _hideRadialRing();
                                }
                              },
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOwner ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.15),
                                  border: Border.all(color: isOwner ? Colors.red.withOpacity(0.5) : Colors.white.withOpacity(0.3)),
                                ),
                                child: Icon(
                                  isOwner ? Icons.delete_outline : Icons.close,
                                  color: isOwner ? Colors.red : Colors.white54,
                                  size: 18,
                                ),
                              ),
                            ),
                            // Like - top
                            Positioned(
                              top: 0,
                              child: _RingAction(
                                icon: Icons.favorite,
                                label: 'like',
                                onTap: () async {
                                  _hideRadialRing();
                                  await ApiService.likePost(widget.post['id']);
                                  widget.onRefresh();
                                },
                              ),
                            ),
                            // Comment - right
                            Positioned(
                              right: 0,
                              child: _RingAction(
                                icon: Icons.comment_outlined,
                                label: 'comment',
                                onTap: () {
                                  _hideRadialRing();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CommentsScreen(post: widget.post),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Share - bottom
                            Positioned(
                              bottom: 0,
                              child: _RingAction(
                                icon: Icons.share_outlined,
                                label: 'share',
                                onTap: () => _hideRadialRing(),
                              ),
                            ),
                            // Report - left
                            Positioned(
                              left: 0,
                              child: _RingAction(
                                icon: Icons.flag_outlined,
                                label: 'report',
                                onTap: () => _hideRadialRing(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RingAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RingAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 8, letterSpacing: 1)),
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
      return const Center(child: CircularProgressIndicator(color: Colors.white));
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
}

class _MomentViewer extends StatefulWidget {
  final List<dynamic> moments;
  final int startIndex;
  const _MomentViewer({required this.moments, required this.startIndex});

  @override
  State<_MomentViewer> createState() => _MomentViewerState();
}

class _MomentViewerState extends State<_MomentViewer>
    with SingleTickerProviderStateMixin {
  late int currentIndex;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.startIndex;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _next();
        }
      });
    _progressController.forward();
  }

  void _next() {
    if (currentIndex < widget.moments.length - 1) {
      setState(() => currentIndex++);
      _progressController.reset();
      _progressController.forward();
    } else {
      Navigator.pop(context);
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _progressController.reset();
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moment = widget.moments[currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final x = details.globalPosition.dx;
          final width = MediaQuery.of(context).size.width;
          if (x < width / 2) {
            _prev();
          } else {
            _next();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media
            if (moment['media_url'] != null)
              Image.network(moment['media_url'], fit: BoxFit.cover)
            else
              Container(
                color: const Color(0xFF0A0A0A),
                child: Center(
                  child: Text(
                    moment['content'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),

            // Progress bars
            Positioned(
              top: 60,
              left: 12,
              right: 12,
              child: Row(
                children: List.generate(widget.moments.length, (i) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: i < currentIndex
                          ? Container(color: Colors.white)
                          : i == currentIndex
                              ? AnimatedBuilder(
                                  animation: _progressController,
                                  builder: (context, child) => FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _progressController.value,
                                    child: Container(color: Colors.white),
                                  ),
                                )
                              : null,
                    ),
                  );
                }),
              ),
            ),

            // User info
            Positioned(
              top: 72,
              left: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF1A1A1A),
                    child: Text(
                      (moment['username'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '@${moment['username']}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Close button
            Positioned(
              top: 60,
              right: 16,
              child: GestureDetector(
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
            ),

            // Caption
            if (moment['content'] != null && moment['content'].isNotEmpty && moment['media_url'] != null)
              Positioned(
                bottom: 60,
                left: 16,
                right: 16,
                child: Text(
                  moment['content'],
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _feeds = [];
  List<int> _savedPosts = [];
  final _commentController = TextEditingController();
  int? _replyingToPostId;

  late final AnimationController _heartController;
  late final Animation<double> _heartAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _heartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
    _loadAllData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _heartController.dispose();
    super.dispose();
  }

  // ==================== DATA ====================
  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _feeds = prefs.getString('feeds') != null
          ? List<Map<String, dynamic>>.from(
              json.decode(prefs.getString('feeds')!))
          : _getDemoFeeds();

      _savedPosts = prefs.getString('saved_posts') != null
          ? List<int>.from(json.decode(prefs.getString('saved_posts')!))
          : [];
    });
  }

  Future<void> _saveAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('feeds', json.encode(_feeds)),
      prefs.setString('saved_posts', json.encode(_savedPosts)),
    ]);
  }

  List<Map<String, dynamic>> _getDemoFeeds() => [
        {
          "id": 1,
          "userName": "Aiony Haust",
          "userImage":
              "https://images.pexels.com/photos/1855582/pexels-photo-1855582.jpeg",
          "feedTime": "1 soat oldin",
          "feedText": "Hayot go'zal kunlarda boshlanadi",
          "mediaList": [
            {"path": "", "isVideo": false}
          ],
          "isPrivate": false,
          "isNsfw": false,
          "likes": 2500,
          "isLiked": false,
          "comments": [],
          "isMine": false,
        },
        {
          "id": 2,
          "userName": "Siz",
          "userImage":
              "https://images.pexels.com/photos/91227/pexels-photo-91227.jpeg",
          "feedTime": "Hozirgina",
          "feedText": "Salom dunyo!",
          "mediaList": [],
          "isPrivate": false,
          "isNsfw": false,
          "likes": 5,
          "isLiked": true,
          "comments": [],
          "isMine": true,
        }
      ];

  // ==================== + TUGMASI — 18+ SWITCH + CHIROYLILIK ====================
  void _showCreateOptions() {
    bool isNsfw = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Yangi post / Reels",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SwitchListTile(
                title: const Text("18+ (NSFW) kontent",
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text("Faqat profilingizda ko‘rinadi",
                    style: TextStyle(color: Colors.white70)),
                value: isNsfw,
                activeColor: Colors.redAccent,
                onChanged: (val) => setModalState(() => isNsfw = val),
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(Icons.post_add,
                    color: Colors.cyanAccent, size: 34),
                title: const Text("Post / Reels yaratish",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CreatePostScreen(isNsfw: false)),
                  );
                  if (result != null && mounted) {
                    setState(() => _feeds.insert(0, result));
                    _saveAllData();
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showPostMenu(Map<String, dynamic> post) {
    final isMine = post['isMine'] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: isMine
              ? [
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.white70),
                    title: const Text("Tahrirlash"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CreatePostScreen(editPost: post)),
                      ).then((updatedPost) {
                        if (updatedPost != null && mounted) {
                          setState(() {
                            final index =
                                _feeds.indexWhere((p) => p['id'] == post['id']);
                            if (index != -1) _feeds[index] = updatedPost;
                          });
                          _saveAllData();
                        }
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text("O'chirish",
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() =>
                          _feeds.removeWhere((p) => p['id'] == post['id']));
                      _saveAllData();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Post o'chirildi")));
                    },
                  ),
                ]
              : [
                  ListTile(
                    leading: const Icon(Icons.flag, color: Colors.red),
                    title: const Text("Shikoyat qilish"),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Shikoyat yuborildi")));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.block, color: Colors.red),
                    title: const Text("Bloklash"),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() =>
                          _feeds.removeWhere((p) => p['id'] == post['id']));
                      _saveAllData();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Foydalanuvchi bloklandi")));
                    },
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Explore tabda 18+ postlar ko‘rinmaydi
    final visibleFeeds =
        _feeds.where((post) => post['isNsfw'] != true).toList();

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text("SafeChat",
              style: GoogleFonts.pacifico(fontSize: 30, color: Colors.white)),
          actions: [
            IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    size: 28, color: Colors.white),
                onPressed: () {}),
            const SizedBox(width: 8),
          ],
        ),
        body: visibleFeeds.isEmpty
            ? const Center(
                child: Text("Hozircha postlar yo'q",
                    style: TextStyle(color: Colors.white70, fontSize: 18)))
            : ListView.builder(
                cacheExtent: 3000,
                physics: const BouncingScrollPhysics(),
                itemCount: visibleFeeds.length,
                itemBuilder: (context, i) {
                  final post = visibleFeeds[i];
                  final isSaved = _savedPosts.contains(post['id']);

                  return PostWidget(
                    key: ValueKey(post['id']),
                    post: post,
                    isSaved: isSaved,
                    heartAnimation: _heartAnimation,
                    commentController: _commentController,
                    isReplying: _replyingToPostId == post['id'],
                    onReply: () =>
                        setState(() => _replyingToPostId = post['id']),
                    onCancelReply: () =>
                        setState(() => _replyingToPostId = null),
                    onLike: () {
                      setState(() {
                        post['isLiked'] = !(post['isLiked'] as bool);
                        post['likes'] =
                            (post['likes'] as int) + (post['isLiked'] ? 1 : -1);
                      });
                      _heartController
                          .forward()
                          .then((_) => _heartController.reset());
                      _saveAllData();
                    },
                    onDoubleTap: () {
                      if (!(post['isLiked'] as bool)) {
                        setState(() {
                          post['isLiked'] = true;
                          post['likes'] = (post['likes'] as int) + 1;
                        });
                        _heartController
                            .forward()
                            .then((_) => _heartController.reset());
                        _saveAllData();
                      }
                    },
                    onToggleSave: () {
                      setState(() {
                        isSaved
                            ? _savedPosts.remove(post['id'])
                            : _savedPosts.add(post['id']);
                      });
                      _saveAllData();
                    },
                    onSubmitComment: (text) {
                      setState(() {
                        post['comments']
                            .add({"user": "Siz", "text": text, "isMine": true});
                        _commentController.clear();
                        _replyingToPostId = null;
                      });
                      _saveAllData();
                    },
                    onMenuTap: () => _showPostMenu(post),
                  );
                },
              ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            onPressed: _showCreateOptions,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.purpleAccent]),
                boxShadow: [
                  BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.6),
                      blurRadius: 25,
                      spreadRadius: 5)
                ],
              ),
              child: const Icon(Icons.add, size: 34, color: Colors.black),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

// ==================== POST WIDGET ====================
class PostWidget extends StatefulWidget {
  final Map<String, dynamic> post;
  final bool isSaved;
  final Animation<double> heartAnimation;
  final TextEditingController commentController;
  final bool isReplying;
  final VoidCallback onReply,
      onCancelReply,
      onLike,
      onDoubleTap,
      onToggleSave,
      onMenuTap;
  final Function(String) onSubmitComment;

  const PostWidget({
    Key? key,
    required this.post,
    required this.isSaved,
    required this.heartAnimation,
    required this.commentController,
    required this.isReplying,
    required this.onReply,
    required this.onCancelReply,
    required this.onLike,
    required this.onDoubleTap,
    required this.onToggleSave,
    required this.onSubmitComment,
    required this.onMenuTap,
  }) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late PageController _pageController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initVideoIfNeeded();
  }

  void _initVideoIfNeeded() {
    final mediaList = widget.post['mediaList'] as List? ?? [];
    if (mediaList.isNotEmpty && (mediaList[0]['isVideo'] == true)) {
      final path = mediaList[0]['path'] as String;
      _videoController = path.startsWith('http')
          ? VideoPlayerController.network(path)
          : VideoPlayerController.file(File(path));
      _videoController?.initialize().then((_) {
        _videoController?.setLooping(true);
        _videoController?.play();
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = widget.post['mediaList'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + 18+ badge
          ListTile(
            leading: CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(widget.post['userImage'])),
            title: Row(
              children: [
                Text(widget.post['userName'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 8),
              ],
            ),
            subtitle: Text(widget.post['feedTime'],
                style: const TextStyle(color: Colors.white70)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    widget.post['isPrivate'] == true
                        ? Icons.lock
                        : Icons.public,
                    size: 20,
                    color: Colors.white70),
                IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onPressed: widget.onMenuTap),
              ],
            ),
          ),

          if ((widget.post['feedText'] as String?)?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(widget.post['feedText'],
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
            ),

          if (mediaList.isNotEmpty)
            SizedBox(
              height: 420,
              child: PageView.builder(
                controller: _pageController,
                itemCount: mediaList.length,
                itemBuilder: (context, i) {
                  final media = mediaList[i];
                  final bool isVideo = media['isVideo'] == true;

                  return GestureDetector(
                    onDoubleTap: widget.onDoubleTap,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: isVideo
                              ? (_videoController?.value.isInitialized == true
                                  ? AspectRatio(
                                      aspectRatio:
                                          _videoController!.value.aspectRatio,
                                      child: VideoPlayer(_videoController!))
                                  : const Center(
                                      child: CircularProgressIndicator(
                                          color: Colors.cyanAccent)))
                              : (media['path'].toString().startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: media['path'],
                                      fit: BoxFit.cover,
                                      width: double.infinity)
                                  : Image.file(File(media['path']),
                                      fit: BoxFit.cover)),
                        ),
                        if (isVideo)
                          IconButton(
                              icon: const Icon(Icons.play_circle_fill,
                                  size: 80, color: Colors.white70),
                              onPressed: () => _videoController?.play()),
                        AnimatedBuilder(
                          animation: widget.heartAnimation,
                          builder: (_, __) => Opacity(
                            opacity: widget.heartAnimation.value,
                            child: const Icon(Icons.favorite,
                                size: 120, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                      widget.post['isLiked']
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          widget.post['isLiked'] ? Colors.red : Colors.white70),
                  onPressed: widget.onLike,
                ),
                IconButton(
                    icon: const Icon(Icons.chat_bubble_outline,
                        color: Colors.white70),
                    onPressed: widget.onReply),
                IconButton(
                  icon: Icon(
                      widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white70),
                  onPressed: widget.onToggleSave,
                ),
                const Spacer(),
                Text("${widget.post['likes']} ta yoqdi",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white70)),
              ],
            ),
          ),

          if (widget.isReplying)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.cyanAccent,
                      child: Text("S", style: TextStyle(color: Colors.black))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: widget.commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Izoh yozing...",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30)),
                        filled: true,
                        fillColor: Colors.grey[850],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (t) => t.trim().isNotEmpty
                          ? widget.onSubmitComment(t.trim())
                          : null,
                    ),
                  ),
                  TextButton(
                      onPressed: widget.onCancelReply,
                      child: const Text("Bekor",
                          style: TextStyle(color: Colors.cyanAccent))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== CREATE POST SCREEN — isNsfw qo‘shildi ====================
class CreatePostScreen extends StatefulWidget {
  final Map<String, dynamic>? editPost;
  final bool isNsfw;
  const CreatePostScreen({Key? key, this.editPost, this.isNsfw = false})
      : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with TickerProviderStateMixin {
  final _captionController = TextEditingController();
  List<Map<String, dynamic>> _mediaList = [];
  late final AnimationController _fabPulseController;
  late final Animation<double> _fabPulseAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.editPost != null) {
      _captionController.text = widget.editPost!['feedText'] ?? '';
      _mediaList = List.from(widget.editPost!['mediaList'] ?? []);
    }
    _fabPulseController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..repeat(reverse: true);
    _fabPulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
        CurvedAnimation(parent: _fabPulseController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      final newMedia = picked
          .map((x) => {
                'path': x.path,
                'isVideo': x.path.endsWith('.mp4') || x.path.endsWith('.mov'),
              })
          .toList();
      setState(() => _mediaList.addAll(newMedia));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.editPost != null ? "Tahrirlash" : "Yangi post"),
          actions: [
            TextButton(
              onPressed: () {
                final newPost = {
                  "id": widget.editPost?['id'] ??
                      DateTime.now().millisecondsSinceEpoch,
                  "userName": "Siz",
                  "userImage": "https://i.pravatar.cc/150?img=3",
                  "feedTime": "Hozirgina",
                  "feedText": _captionController.text,
                  "mediaList": _mediaList,
                  "isPrivate": false,
                  "isNsfw": widget.isNsfw, // Muhim qator!
                  "likes": widget.editPost?['likes'] ?? 0,
                  "isLiked": false,
                  "comments": widget.editPost?['comments'] ?? [],
                  "isMine": true,
                };
                Navigator.pop(context, newPost);
              },
              child: const Text("Joylash",
                  style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        body: Column(
          children: [
            if (widget.isNsfw)
              Container(
                width: double.infinity,
                color: Colors.redAccent.withOpacity(0.2),
                padding: const EdgeInsets.all(12),
                child: const Row(
                    // children: [
                    //   Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    //   SizedBox(width: 10),
                    //   Text("18+ Kontent – Faqat profilingizda ko‘rinadi",
                    //       style: TextStyle(
                    //           color: Colors.redAccent,
                    //           fontWeight: FontWeight.bold)),
                    // ],
                    ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _captionController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: "Neler bo‘lyapti?", border: InputBorder.none),
              ),
            ),
            Expanded(
              child: _mediaList.isEmpty
                  ? const Center(
                      child: Text("Media tanlang",
                          style: TextStyle(color: Colors.white70)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8),
                      itemCount: _mediaList.length,
                      itemBuilder: (ctx, i) {
                        final media = _mediaList[i];
                        return Stack(
                          children: [
                            Positioned.fill(
                                child: Image.file(File(media['path']),
                                    fit: BoxFit.cover)),
                            if (media['isVideo'] == true)
                              const Center(
                                  child: Icon(Icons.play_circle_fill,
                                      size: 40, color: Colors.white70)),
                            Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _mediaList.removeAt(i)),
                                    child: const Icon(Icons.close,
                                        color: Colors.white))),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: ScaleTransition(
          scale: _fabPulseAnimation,
          child: FloatingActionButton(
              backgroundColor: Colors.cyanAccent,
              onPressed: _pickMedia,
              child: const Icon(Icons.add, color: Colors.black)),
        ),
      ),
    );
  }
}

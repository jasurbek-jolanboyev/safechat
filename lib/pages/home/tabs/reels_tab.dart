// lib/pages/home/tabs/reels_tab.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ReelsTab extends StatefulWidget {
  const ReelsTab({Key? key}) : super(key: key);
  @override
  State<ReelsTab> createState() => _ReelsTabState();
}

class _ReelsTabState extends State<ReelsTab> {
  late PageController _pageController;
  final List<String> videoUrls = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:
            const Text("Reels", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return ReelVideoItem(videoUrl: videoUrls[index % videoUrls.length]);
        },
      ),
    );
  }
}

class ReelVideoItem extends StatefulWidget {
  final String videoUrl;
  const ReelVideoItem({Key? key, required this.videoUrl}) : super(key: key);
  @override
  State<ReelVideoItem> createState() => _ReelVideoItemState();
}

class _ReelVideoItemState extends State<ReelVideoItem> {
  late VideoPlayerController _controller;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _controller.value.isInitialized
            ? GestureDetector(
                onTap: () => _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play(),
                child: VideoPlayer(_controller),
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.white)),
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              IconButton(
                icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 40, color: _isLiked ? Colors.red : Colors.white),
                onPressed: () => setState(() => _isLiked = !_isLiked),
              ),
              const Text("12.5K", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              const Icon(Icons.comment, size: 36, color: Colors.white),
              const Text("342", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              const Icon(Icons.share, size: 36, color: Colors.white),
            ],
          ),
        ),
        Positioned(
          left: 16,
          bottom: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("@username",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              const Text("Bu juda qiziqarli video!",
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }
}

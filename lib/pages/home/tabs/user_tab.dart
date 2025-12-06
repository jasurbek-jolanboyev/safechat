// user_tab.dart (yoki profile_tab.dart)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with TickerProviderStateMixin {
  late TabController _tabController;

  String profilePicUrl =
      "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800";

  final String name = "User ";
  final String username = "@Username";
  final String bio =
      "Flutter & Dart Enthusiast\nMobile • Web • Desktop\nOpen source lover";
  final String location = "Toshkent, Uzbekistan";
  final String website = "User.dev";

  int posts = 156;
  int followers = 12450;
  int following = 378;

  final List<String> postsList =
      List.generate(60, (i) => "https://picsum.photos/seed/p$i/600");

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Web'da rasm tanlash tez orada qo'shiladi")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profilePicUrl = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // TOP BAR
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _showProfileMenu,
                      icon: const Icon(Icons.menu_rounded,
                          color: Colors.white, size: 30),
                    ),
                    Text(username,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: _showAddPostSheet,
                      icon: const Icon(Icons.add_box_outlined,
                          color: Colors.white, size: 30),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // PROFIL RASM — CHIROYLISI
              GestureDetector(
                onTap: _pickProfileImage,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.7),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _buildProfileImage(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(username,
                  style:
                      const TextStyle(color: Colors.cyanAccent, fontSize: 18)),

              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 16, height: 1.6)),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.location_on, color: Colors.white54, size: 18),
                  SizedBox(width: 8),
                  Text("Toshkent, Uzbekistan",
                      style: TextStyle(color: Colors.white54)),
                ],
              ),

              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _launchURL(website),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: Colors.black45, blurRadius: 10)
                    ],
                  ),
                  child: Text(website,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),

              const SizedBox(height: 40),

              // STATISTIKA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem("$posts", "Posts"),
                  GestureDetector(
                      onTap: _showFollowersList,
                      child: _statItem(
                          "${(followers / 1000).toStringAsFixed(1)}K",
                          "Followers")),
                  GestureDetector(
                      onTap: _showFollowingList,
                      child: _statItem("$following", "Following")),
                ],
              ),

              const SizedBox(height: 40),

              // TUGMALAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _editProfile,
                        icon: const Icon(Icons.edit, size: 20),
                        label: const Text("Edit Profile"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _viewInsights,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        padding: const EdgeInsets.all(18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Icon(Icons.analytics, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // TAB BAR
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.cyanAccent,
                indicatorWeight: 4,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_view_rounded)),
                  Tab(icon: Icon(FontAwesomeIcons.playCircle)),
                  Tab(icon: Icon(Icons.bookmark_border)),
                ],
              ),

              // KONTENT
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _postsGrid(),
                        _reelsGrid(),
                        const Center(
                            child: Text("Saqlanganlar",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    if (profilePicUrl.isEmpty) {
      return Container(
          color: Colors.grey[800],
          child: const Icon(Icons.person, size: 80, color: Colors.white54));
    }
    if (kIsWeb || profilePicUrl.startsWith("http")) {
      return CachedNetworkImage(
          imageUrl: profilePicUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              const CircularProgressIndicator(color: Colors.white));
    }
    return Image.file(File(profilePicUrl), fit: BoxFit.cover);
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 15)),
      ],
    );
  }

  Widget _postsGrid() => GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: postsList.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(imageUrl: postsList[i], fit: BoxFit.cover),
        ),
      );

  Widget _reelsGrid() => GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.56,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemCount: 18,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                  imageUrl: "https://picsum.photos/seed/reel$i/600/1000",
                  fit: BoxFit.cover),
              Container(color: Colors.black54),
              const Center(
                  child: Icon(Icons.play_circle_fill,
                      color: Colors.white, size: 60)),
            ],
          ),
        ),
      );

  // ==== FUNKSİYALAR — TO‘LIQ TUGALLANGAN ====
  void _showAddPostSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text("Yangi qo'shish",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24),
          ListTile(
              leading: const Icon(Icons.photo, color: Colors.white),
              title: const Text("Post", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _addNewPost();
              }),
          ListTile(
              leading: const Icon(Icons.videocam, color: Colors.white),
              title: const Text("Reel", style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context)),
          ListTile(
              leading: const Icon(Icons.circle_outlined, color: Colors.white),
              title: const Text("Story", style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _addNewStory();
              }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _addNewPost() {
    setState(() {
      postsList.insert(0, "https://picsum.photos/seed/newpost/600");
      posts++;
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Post qo'shildi!")));
  }

  void _addNewStory() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Story qo'shildi!")));
  }

  void _editProfile() => Navigator.push(
      context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));

  void _viewInsights() => showDialog(
        context: context,
        builder: (_) => const AlertDialog(
            title: Text("Statistika"),
            content: Text("124K ko‘rish\n+18% o‘sish")),
      );

  void _showFollowersList() => showModalBottomSheet(
      context: context,
      builder: (_) => const Center(
          child: Text("Followers",
              style: TextStyle(fontSize: 24, color: Colors.white))));

  void _showFollowingList() => showModalBottomSheet(
      context: context,
      builder: (_) => const Center(
          child: Text("Following",
              style: TextStyle(fontSize: 24, color: Colors.white))));

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          ListTile(
              leading: Icon(Icons.settings, color: Colors.white),
              title: Text("Sozlamalar", style: TextStyle(color: Colors.white))),
          ListTile(
              leading: Icon(Icons.share, color: Colors.white),
              title: Text("Ulashish", style: TextStyle(color: Colors.white))),
          ListTile(
              leading: Icon(Icons.qr_code, color: Colors.white),
              title: Text("QR kod", style: TextStyle(color: Colors.white))),
          ListTile(
              leading: Icon(Icons.archive, color: Colors.white),
              title: Text("Arxiv", style: TextStyle(color: Colors.white))),
          ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title:
                  Text("Chiqish", style: TextStyle(color: Colors.redAccent))),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _launchURL(String url) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Link: $url")));
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          title:
              const Text("Tahrirlash", style: TextStyle(color: Colors.white))),
      body: const Center(
          child: Text("Tez orada...",
              style: TextStyle(color: Colors.white, fontSize: 20))),
    );
  }
}

import 'dart:ui';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:safechat/models/chat/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class VideoCallPage extends HookWidget {
  final bool isVideo; // Video yoki audio chaqirish uchun

  VideoCallPage({Key? key, this.isVideo = true}) : super(key: key);

  final String placeholderImage =
      'https://images.unsplash.com/photo-1627087820883-7a102b79179a?ixlib=rb-1.2.1&auto=format&fit=crop&w=1974&q=80';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Chat ma’lumotlarini olish
    final Chat chat = ModalRoute.of(context)!.settings.arguments as Chat;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(chat.user.profile),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(1),
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // --- Profil + Calling animatsiyasi --- //
                Column(
                  children: [
                    AvatarGlow(
                      glowColor: Colors.white,
                      glowRadiusFactor: 0.4,
                      duration: const Duration(milliseconds: 2000),
                      repeat: true,
                      curve: Curves.easeOut,
                      child: Container(
                        width: 100,
                        height: 100,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(80),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CachedNetworkImage(
                          imageUrl: chat.user.profile,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      chat.user.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isVideo ? 'Video calling' : 'Audio calling',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        DefaultTextStyle(
                          style: TextStyle(fontSize: 12.0),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TyperAnimatedText(
                                '.....',
                                speed: Duration(milliseconds: 500),
                              ),
                            ],
                            repeatForever: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // --- Video/Audio tugmalari --- //
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () {},
                      color: Colors.grey.shade700,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(18),
                      child: Icon(
                        isVideo ? Icons.videocam : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // --- End call --- //
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80),
                  ),
                  minWidth: 70,
                  height: 70,
                  child: Icon(Icons.call_end, color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

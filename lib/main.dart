import 'package:flutter/material.dart';
import 'package:safechat/pages/call/video/video_call_page.dart';
import 'package:safechat/pages/home/home_page.dart';
import 'package:safechat/pages/message_page.dart';
import 'package:safechat/pages/story/story_page.dart';
import 'package:safechat/pages/auth/login_page.dart';
import 'package:safechat/pages/home/home_page.dart';
import 'package:safechat/pages/profile/edit_profile_page.dart';
import 'package:safechat/pages/profile/privacy_page.dart';
import 'package:safechat/pages/profile/security_page.dart';
import 'package:safechat/pages/profile/notifications_settings_page.dart';
import 'package:safechat/pages/profile/help_support_page.dart';
import 'package:safechat/pages/story/story_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: {
        '/message': (context) => MessagePage(),
        '/story': (context) => StoryPage(),
        '/video-call': (context) => VideoCallPage(),
        '/login': (context) => LoginPage(), // const yoʻq
        '/home': (context) => HomePage(), // const yoʻq
        '/edit-profile': (context) => EditProfilePage(), // const yoʻq
        '/privacy': (context) => PrivacyPage(), // const yoʻq
        '/security': (context) => SecurityPage(), // const yoʻq
        '/notifications-settings': (context) =>
            NotificationsSettingsPage(), // const yoʻq
        '/help': (context) => HelpSupportPage(),
      },
    );
  }
}

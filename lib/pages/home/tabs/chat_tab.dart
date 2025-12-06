// lib/pages/home/tabs/chat_tab.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:safechat/data/chat.dart';
import 'package:safechat/pages/home/tabs/components/chat_widget.dart';
import 'package:safechat/pages/home/tabs/components/story_list.dart';
import 'package:safechat/shared/constants/color_constants.dart';

class ChatTab extends StatefulWidget {
  const ChatTab({Key? key}) : super(key: key);

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final chats = getChats();

  void _openNewChat() {
    // Kelajakda kontaktlar ro'yxati ochiladi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Yangi chat — tez orada!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.lightBackgroundColor,
        elevation: 0,
        title: const Text('Chat',
            style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.w700)),
        centerTitle: false,
        actions: [
          IconButton(
            splashRadius: 20,
            icon: const Icon(Iconsax.search_normal_1,
                color: Colors.black, size: 22),
            onPressed: () {},
          ),
          IconButton(
            splashRadius: 20,
            icon: const Icon(Iconsax.add_circle,
                color: Colors.cyanAccent, size: 26),
            onPressed: _openNewChat,
            tooltip: "Yangi chat",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const StoryList(), // Bu yerda sizning va boshqalarning storylari ko'rinadi
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Chats",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            ...chats
                .map((e) => Column(
                      children: [
                        ChatWidget(chat: e),
                        if (chats.indexOf(e) != chats.length - 1)
                          const Divider(indent: 80, height: 1, endIndent: 16),
                      ],
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

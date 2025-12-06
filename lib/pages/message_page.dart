import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:safechat/models/chat/chat.dart';
import 'package:safechat/models/message/message.dart';
import 'package:safechat/pages/home/tabs/components/message_widget.dart';
import 'package:safechat/shared/constants/color_constants.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:safechat/pages/call/video/video_call_page.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AnimationMixin {
  late Chat chat;
  final textController = TextEditingController();
  final _scrollController = ScrollController();
  late Animation<double> opacity;
  bool showEmoji = false;
  bool isRecording = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    opacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    controller.duration = const Duration(milliseconds: 250);

    textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void addToMessages(String text) {
    setState(() {
      chat.messages.insert(
        0,
        Message(
          id: DateTime.now().millisecondsSinceEpoch,
          text: text,
          createdAt: 'Hozir',
          isMe: true,
        ),
      );
    });
    textController.clear();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void sendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        chat.messages.insert(
          0,
          Message(
            id: DateTime.now().millisecondsSinceEpoch,
            type: "image",
            attachment: pickedFile.path,
            createdAt: "Hozir",
            isMe: true,
          ),
        );
      });
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    chat = ModalRoute.of(context)!.settings.arguments as Chat;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorConstants.lightBackgroundColor,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(chat.user.profile),
          ),
          title: Text(chat.user.name),
          subtitle: const Text('oxirgi marta koʻrilgan: 21:05'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallPage(isVideo: true),
                  settings: RouteSettings(arguments: chat),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCallPage(isVideo: false),
                  settings: RouteSettings(arguments: chat),
                ),
              );
            },
          ),
        ],
      ),

      body: GestureDetector(
        onTap: () => setState(() => showEmoji = false),
        child: Column(
          children: [
            // Xabarlar roʻyxati
            Expanded(
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: chat.messages.length,
                itemBuilder: (context, index) =>
                    MessageWidget(message: chat.messages[index]),
              ),
            ),

            // Input + emoji + mic
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // Asosiy input qatori
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        // Emoji tugmasi
                        IconButton(
                          icon: Icon(
                            showEmoji
                                ? Icons.keyboard
                                : Icons.sentiment_satisfied_alt,
                          ),
                          onPressed: () {
                            setState(() {
                              showEmoji = !showEmoji;
                              if (showEmoji) FocusScope.of(context).unfocus();
                            });
                          },
                        ),

                        // Rasm joʻnatish tugmasi
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: sendImage,
                        ),

                        // TextField
                        Expanded(
                          child: TextField(
                            controller: textController,
                            minLines: 1,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: "Xabar yozing...",
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),

                        // Mic yoki Send
                        textController.text.isEmpty
                            ? GestureDetector(
                                onLongPressStart: (_) =>
                                    setState(() => isRecording = true),
                                onLongPressEnd: (_) =>
                                    setState(() => isRecording = false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isRecording
                                        ? Colors.red.shade100
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isRecording ? Icons.mic : Icons.mic_none,
                                    color: isRecording
                                        ? Colors.red
                                        : Colors.grey.shade600,
                                    size: 28,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.send_rounded,
                                  color: ColorConstants.primaryColor,
                                ),
                                onPressed: () {
                                  if (textController.text.trim().isNotEmpty) {
                                    addToMessages(textController.text.trim());
                                  }
                                },
                              ),
                      ],
                    ),
                  ),

                  // Emoji Picker — 4.4.0+ uchun toʻgʻri konfiguratsiya!
                  // Emoji Picker — 4.4.0+ uchun eng toʻgʻri va sodda variant
                  Offstage(
                    offstage: !showEmoji,
                    child: SizedBox(
                      height: 280,
                      child: EmojiPicker(
                        onEmojiSelected: (category, emoji) {
                          textController.text += emoji.emoji;
                          // Kursorni oxiriga olib borish
                          textController.selection = TextSelection.fromPosition(
                            TextPosition(offset: textController.text.length),
                          );
                        },
                        // config BUTUNLAY OʻCHIRILDI — hozircha eng barqaror yechim!
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

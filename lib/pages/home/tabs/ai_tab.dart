// lib/pages/home/tabs/ai_tab.dart
// SafeChat AI – HAQIQIY AI + Maxfiy moderatsiya (100% ishlaydi)

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AiTab extends StatefulWidget {
  const AiTab({Key? key}) : super(key: key);
  @override
  State<AiTab> createState() => _AiTabState();
}

class _AiTabState extends State<AiTab> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isAnalyzing = false;
  bool _isRecording = false;

  // API kalit – o‘zgartirmang!
  static const String _apiKey = "AIzaSyDRIkSSeHGPO0ATHbXSpFFUTqKT6N14DgY";

  late final GenerativeModel _moderationModel;
  late final GenerativeModel _chatModel;
  late final SharedPreferences _prefs;
  late final FlutterSoundRecorder _recorder;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat();
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initialize();
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _recorder.openRecorder();

    _moderationModel =
        GenerativeModel(model: 'gemini-1.5-pro-latest', apiKey: _apiKey);

    _chatModel = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: _apiKey,
      systemInstruction: Content.text('''
Siz SafeChat AI – o‘zbek tilida do‘stona, qiziqarli, yordamchi sun’iy intellektsiz.
Foydalanuvchi bilan tabiiy suhbat quring, hazil qiling, maslahat bering, qo‘llab-quvvatlang.
Hech qachon "men moderator" yoki "xavfsizlik" haqida gapirmang.
Har qanday savolga javob bering, qiziqarli bo‘ling!
O‘zbek tilida javob bering.
'''),
    );

    await _loadHistory();

    if (_messages.isEmpty) {
      _addMessage(role: 'assistant', content: '''
# Salom! Men SafeChat AI  
Siz bilan gaplashish uchun shu yerdaman!

Savolingiz bo‘lsa – yozing  
Hazil qilamiz, maslahat beraman, hamma narsani bilaman  
Mikrofonni bosib turing → gapiring → qo‘yib yuboring

Bugun nima haqida gaplashamiz?
''');
    }
  }

  Future<void> _loadHistory() async {
    final data = _prefs.getString('safechat_ai_full_history');
    if (data != null) {
      final List decoded = json.decode(data);
      setState(() => _messages.addAll(decoded.cast<Map<String, dynamic>>()));
      _scrollToBottom();
    }
  }

  Future<void> _saveHistory() async {
    await _prefs.setString('safechat_ai_full_history', json.encode(_messages));
  }

  void _addMessage(
      {required String role, required String content, bool isVoice = false}) {
    setState(() {
      _messages.add({
        'role': role,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'isVoice': isVoice,
      });
    });
    _saveHistory();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Maxfiy report
  Future<void> _reportToModerators(Map<String, dynamic> result,
      {bool isVoice = false}) async {
    final report = {
      ...result,
      'type': isVoice ? 'voice' : 'text',
      'timestamp': DateTime.now().toIso8601String()
    };
    final reports = _prefs.getStringList('moderator_reports_v2') ?? [];
    reports.add(json.encode(report));
    await _prefs.setStringList('moderator_reports_v2', reports);
  }

  // OVOZ YOZISH
  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() => _isRecording = false);
    if (path != null) {
      _addMessage(
          role: 'user', content: "Ovozli xabar yuborildi...", isVoice: true);
      setState(() => _isAnalyzing = true);
      await _processVoice(File(path));
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _processVoice(File audioFile) async {
    final bytes = await audioFile.readAsBytes();

    // 1. Maxfiy tahlil
    try {
      final response = await _moderationModel.generateContent([
        Content.multi([
          TextPart('''
Faqat JSON qaytaring:
{
  "is_dangerous": true/false,
  "category": "pornography|phishing|extremism|insult_nation|haram|violence|normal",
  "confidence": 0.0-1.0
}
'''),
          DataPart('audio/aac', bytes),
        ])
      ]);
      final raw = (response.text ?? '').trim();
      if (raw.startsWith('{')) {
        final result = json.decode(raw);
        if (result['is_dangerous'] == true &&
            (result['confidence'] ?? 0.0) >= 0.7) {
          await _reportToModerators(result, isVoice: true);
        }
      }
    } catch (e) {
      // Hech nima demaymiz
    }

    // 2. Haqiqiy javob
    try {
      final response = await _chatModel.generateContent([
        Content.multi([
          TextPart(
              "Foydalanuvchi ovozli xabar yubordi. Do‘stona javob ber, o‘zbek tilida."),
          DataPart('audio/aac', bytes),
        ])
      ]);
      _addMessage(
          role: 'assistant',
          content: response.text?.trim() ?? "Tushunarli! Rahmat");
    } catch (e) {
      _addMessage(
          role: 'assistant',
          content:
              "Ovozingizni eshitdim, lekin aniq tushunmadim. Yana gapiring");
    }
  }

  // MATN UCHUN
  Future<void> _processText(String text) async {
    // Maxfiy tahlil
    try {
      final response = await _moderationModel.generateContent([
        Content.text('''
Faqat JSON qaytaring:
{
  "is_dangerous": true/false,
  "confidence": 0.0-1.0
}
Xabar: "$text"
''')
      ]);
      final raw = (response.text ?? '').trim();
      if (raw.startsWith('{')) {
        final result = json.decode(raw);
        if (result['is_dangerous'] == true &&
            (result['confidence'] ?? 0.0) >= 0.7) {
          await _reportToModerators(result);
        }
      }
    } catch (e) {
      // Jim
    }

    // Haqiqiy javob – Chat Model orqali
    try {
      final response = await _chatModel.generateContent([Content.text(text)]);
      final reply = response.text?.trim();
      if (reply != null && reply.isNotEmpty) {
        _addMessage(role: 'assistant', content: reply);
      } else {
        _addMessage(
            role: 'assistant', content: "Juda qiziqarli savol! Yana yozing");
      }
    } catch (e) {
      print("Chat xato: $e");
      _addMessage(
          role: 'assistant',
          content:
              "Internet bilan muammo bo‘ldi shekilli. Yana urinib ko‘ring");
    }
  }

  Future<void> _onSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isAnalyzing) return;

    _addMessage(role: 'user', content: text);
    setState(() => _isAnalyzing = true);
    _controller.clear();
    await _processText(text);
    setState(() => _isAnalyzing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Colors.indigo, Colors.deepPurple]),
                  borderRadius:
                      const BorderRadius.vertical(bottom: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (_, child) => Transform.scale(
                          scale: _pulseAnimation.value,
                          child: const Icon(Icons.smart_toy_rounded,
                              color: Colors.white, size: 34)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                        child: Text("SafeChat AI",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(30)),
                      child: const Text("Onlayn",
                          style: TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              // Chat
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  itemCount: _messages.length + (_isAnalyzing ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _messages.length && _isAnalyzing)
                      return _bubble("Yozmoqda...", true, isTyping: true);
                    final msg = _messages[i];
                    return _bubble(msg['content'], msg['role'] != 'user',
                        isVoice: msg['isVoice'] ?? false);
                  },
                ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: Offset(0, -6))
                    ]),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.deepPurple.withOpacity(0.4),
                                width: 1.5)),
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _onSend(),
                          decoration: const InputDecoration(
                            hintText: "Xabar yozing yoki ovoz yuboring",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 22, vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onLongPressStart: (_) => _startRecording(),
                      onLongPressEnd: (_) => _stopRecording(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: _isRecording
                                ? Colors.red.shade600
                                : Colors.deepPurple.shade600,
                            shape: BoxShape.circle),
                        child: Icon(_isRecording ? Icons.mic : Icons.mic_none,
                            color: Colors.white, size: 30),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      backgroundColor: Colors.deepPurple.shade600,
                      onPressed: _isAnalyzing ? null : _onSend,
                      child: _isAnalyzing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 3))
                          : const Icon(Icons.send_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble(String text, bool isAssistant,
      {bool isVoice = false, bool isTyping = false}) {
    return Align(
      alignment: isAssistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: isAssistant
                  ? [Colors.white, Colors.grey.shade50]
                  : [Colors.deepPurple.shade600, Colors.indigo.shade700]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 6))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isVoice)
              const Icon(Icons.record_voice_over_rounded,
                  color: Colors.deepPurple, size: 22),
            if (isVoice) const SizedBox(width: 8),
            if (isTyping)
              Row(
                  children: List.generate(
                      3,
                      (_) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                              color: Colors.grey, shape: BoxShape.circle))))
            else
              Flexible(
                child: isAssistant
                    ? MarkdownBody(
                        data: text,
                        styleSheet: MarkdownStyleSheet(
                            p: GoogleFonts.nunito(
                                fontSize: 16.2,
                                height: 1.5,
                                color: Colors.black87)))
                    : Text(text,
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 16.2,
                            height: 1.5,
                            fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _pulseController.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

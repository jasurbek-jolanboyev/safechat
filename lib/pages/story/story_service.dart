// lib/services/story_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StoryService {
  static const String _storiesKey = 'user_stories';
  static const String _viewsKey = 'story_views_';

  // Story yaratish
  static Future<void> addStory(Map<String, dynamic> story) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stories = prefs.getStringList(_storiesKey) ?? [];

    // O'zimizniki bo'lsa eski storyni o'chirib, yangisini qo'shamiz (1 ta story faqat)
    stories.removeWhere((s) => json.decode(s)['isMine'] == true);
    stories.add(json.encode(story));

    await prefs.setStringList(_storiesKey, stories);
  }

  // Barcha amaldagi storylarni olish (24 soat ichidagilar)
  static Future<List<Map<String, dynamic>>> getActiveStories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stories = prefs.getStringList(_storiesKey) ?? [];
    final now = DateTime.now().millisecondsSinceEpoch;

    final List<Map<String, dynamic>> active = [];

    for (var s in stories) {
      final story = json.decode(s) as Map<String, dynamic>;
      final timestamp = story['timestamp'] as int;
      if (now - timestamp < 24 * 60 * 60 * 1000) {
        active.add(story);
      }
    }

    return active;
  }

  // Story ko'rilganini belgilash
  static Future<void> markAsViewed(int storyId, String viewerName) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_viewsKey$storyId';
    final List<String> viewers = prefs.getStringList(key) ?? [];
    if (!viewers.contains(viewerName)) {
      viewers.add(viewerName);
      await prefs.setStringList(key, viewers);
    }
  }

  // Kim ko'rganini olish
  static Future<List<String>> getViewers(int storyId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_viewsKey$storyId') ?? [];
  }

  // Reaksiya qo'shish
  static Future<void> addReaction(
      int storyId, String emoji, String user) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'reactions_$storyId';
    final List<String> reactions = prefs.getStringList(key) ?? [];
    reactions.add(json.encode({'emoji': emoji, 'user': user}));
    await prefs.setStringList(key, reactions);
  }

  static Future<List<Map<String, dynamic>>> getReactions(int storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList('reactions_$storyId') ?? [];
    return list.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }
}

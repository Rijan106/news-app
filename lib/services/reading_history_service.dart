import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingHistoryService {
  static const String _historyKey = 'reading_history';
  static const int _maxHistoryItems = 50;

  Future<void> addToHistory(dynamic article) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getReadingHistory();

      // Remove if article already exists (to move it to top)
      history.removeWhere((item) => item['id'] == article['id']);

      // Add article with timestamp
      final articleWithTimestamp = {
        ...article,
        'viewedAt': DateTime.now().toIso8601String(),
      };

      history.insert(0, articleWithTimestamp);

      // Keep only the most recent items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      await prefs.setString(_historyKey, jsonEncode(history));
    } catch (e) {
      print('Error adding to reading history: $e');
    }
  }

  Future<List<dynamic>> getReadingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson != null) {
        return List<dynamic>.from(jsonDecode(historyJson));
      }
    } catch (e) {
      print('Error getting reading history: $e');
    }
    return [];
  }

  Future<void> removeFromHistory(int articleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getReadingHistory();
      history.removeWhere((item) => item['id'] == articleId);
      await prefs.setString(_historyKey, jsonEncode(history));
    } catch (e) {
      print('Error removing from reading history: $e');
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
    } catch (e) {
      print('Error clearing reading history: $e');
    }
  }

  Future<bool> isInHistory(int articleId) async {
    try {
      final history = await getReadingHistory();
      return history.any((item) => item['id'] == articleId);
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getRecentlyViewed({int limit = 10}) async {
    try {
      final history = await getReadingHistory();
      return history.take(limit).toList();
    } catch (e) {
      return [];
    }
  }
}

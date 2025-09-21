import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksService {
  static const String _bookmarksKey = 'bookmarked_articles';

  Future<void> addBookmark(Map<String, dynamic> article) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();

    // Check if article is already bookmarked
    final existingIndex = bookmarks.indexWhere((b) => b['id'] == article['id']);
    if (existingIndex >= 0) {
      // Update existing bookmark with current timestamp
      bookmarks[existingIndex] = {
        ...article,
        'bookmarkedAt': DateTime.now().toIso8601String(),
      };
    } else {
      // Add new bookmark
      bookmarks.add({
        ...article,
        'bookmarkedAt': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString(_bookmarksKey, jsonEncode(bookmarks));
  }

  Future<void> removeBookmark(int articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();

    bookmarks.removeWhere((article) => article['id'] == articleId);
    await prefs.setString(_bookmarksKey, jsonEncode(bookmarks));
  }

  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getString(_bookmarksKey);

    if (bookmarksJson == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(bookmarksJson);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isBookmarked(int articleId) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any((article) => article['id'] == articleId);
  }

  Future<void> clearAllBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_bookmarksKey);
  }
}

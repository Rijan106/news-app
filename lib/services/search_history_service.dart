import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _searchHistoryKey = 'search_history';
  static const int _maxHistoryItems = 20;

  // Save search query to history
  Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_searchHistoryKey) ?? [];

    // Remove if already exists (to move to top)
    history.remove(query);

    // Add to beginning
    history.insert(0, query);

    // Keep only last 20 items
    if (history.length > _maxHistoryItems) {
      history = history.sublist(0, _maxHistoryItems);
    }

    await prefs.setStringList(_searchHistoryKey, history);
  }

  // Get search history
  Future<List<String>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_searchHistoryKey) ?? [];
  }

  // Clear all history
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
  }

  // Remove single item from history
  Future<void> removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList(_searchHistoryKey) ?? [];
    history.remove(query);
    await prefs.setStringList(_searchHistoryKey, history);
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineCacheService {
  static const String _cachedArticlesKey = 'cached_articles';
  static const String _cacheExpiryKey = 'cache_expiry';
  static const int _cacheDurationHours = 24; // Cache for 24 hours

  Future<void> cacheArticles(List<dynamic> articles, {int? categoryId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = categoryId == null
          ? _cachedArticlesKey
          : '${_cachedArticlesKey}_$categoryId';
      final expiryKey = categoryId == null
          ? _cacheExpiryKey
          : '${_cacheExpiryKey}_$categoryId';

      final cacheData = {
        'articles': articles,
        'timestamp': DateTime.now().toIso8601String(),
        'categoryId': categoryId,
      };

      await prefs.setString(cacheKey, jsonEncode(cacheData));

      // Set expiry time
      final expiryTime =
          DateTime.now().add(const Duration(hours: _cacheDurationHours));
      await prefs.setString(expiryKey, expiryTime.toIso8601String());

      print(
          'Articles cached successfully for category ${categoryId ?? 'all'}: ${articles.length} articles');
    } catch (e) {
      print('Error caching articles: $e');
    }
  }

  Future<List<dynamic>> getCachedArticles({int? categoryId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = categoryId == null
          ? _cachedArticlesKey
          : '${_cachedArticlesKey}_$categoryId';
      final expiryKey = categoryId == null
          ? _cacheExpiryKey
          : '${_cacheExpiryKey}_$categoryId';

      final cachedData = prefs.getString(cacheKey);

      if (cachedData == null) {
        return [];
      }

      final decodedData = jsonDecode(cachedData);
      final timestamp = DateTime.parse(decodedData['timestamp']);
      final expiryTime = DateTime.parse(prefs.getString(expiryKey) ?? '');

      // Check if cache is expired
      if (DateTime.now().isAfter(expiryTime)) {
        await clearCache(categoryId: categoryId);
        return [];
      }

      final articles = List<dynamic>.from(decodedData['articles']);
      print(
          'Retrieved ${articles.length} cached articles for category ${categoryId ?? 'all'}');
      return articles;
    } catch (e) {
      print('Error retrieving cached articles: $e');
      return [];
    }
  }

  Future<bool> hasValidCache({int? categoryId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = categoryId == null
          ? _cachedArticlesKey
          : '${_cachedArticlesKey}_$categoryId';
      final expiryKey = categoryId == null
          ? _cacheExpiryKey
          : '${_cacheExpiryKey}_$categoryId';

      final cachedData = prefs.getString(cacheKey);
      final expiryTimeStr = prefs.getString(expiryKey);

      if (cachedData == null || expiryTimeStr == null) {
        return false;
      }

      final expiryTime = DateTime.parse(expiryTimeStr);
      return DateTime.now().isBefore(expiryTime);
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache({int? categoryId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (categoryId == null) {
        // Clear all caches
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith(_cachedArticlesKey) ||
              key.startsWith(_cacheExpiryKey)) {
            await prefs.remove(key);
          }
        }
        print('All caches cleared successfully');
      } else {
        // Clear specific category cache
        final cacheKey = '${_cachedArticlesKey}_$categoryId';
        final expiryKey = '${_cacheExpiryKey}_$categoryId';
        await prefs.remove(cacheKey);
        await prefs.remove(expiryKey);
        print('Cache cleared successfully for category $categoryId');
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cachedArticlesKey);
      final expiryTimeStr = prefs.getString(_cacheExpiryKey);

      if (cachedData == null || expiryTimeStr == null) {
        return {'hasCache': false, 'articleCount': 0, 'expiryTime': null};
      }

      final decodedData = jsonDecode(cachedData);
      final articles = List<dynamic>.from(decodedData['articles']);
      final expiryTime = DateTime.parse(expiryTimeStr);

      return {
        'hasCache': true,
        'articleCount': articles.length,
        'expiryTime': expiryTime,
        'isExpired': DateTime.now().isAfter(expiryTime),
      };
    } catch (e) {
      return {'hasCache': false, 'articleCount': 0, 'expiryTime': null};
    }
  }
}

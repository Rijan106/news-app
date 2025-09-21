import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'offline_cache_service.dart';

class NewsService {
  static const String baseUrl = "https://gurubaa.com/wp-json/wp/v2";
  static const Duration _timeoutDuration = Duration(seconds: 15);
  static const int _maxRetries = 3;

  final OfflineCacheService _cacheService = OfflineCacheService();
  final http.Client _client;
  final Connectivity _connectivity;

  NewsService({
    http.Client? client,
    Connectivity? connectivity,
  })  : _client = client ?? http.Client(),
        _connectivity = connectivity ?? Connectivity();

  Future<List<dynamic>> fetchPosts(
      {int? categoryId,
      bool forceRefresh = false,
      int page = 1,
      int perPage = 10}) async {
    // Only check cache if not forcing refresh and page is 1
    if (!forceRefresh &&
        page == 1 &&
        await _cacheService.hasValidCache(categoryId: categoryId)) {
      final cachedArticles =
          await _cacheService.getCachedArticles(categoryId: categoryId);
      if (cachedArticles.isNotEmpty) {
        return cachedArticles;
      }
    }

    final url = categoryId == null
        ? Uri.parse("$baseUrl/posts?_embed&per_page=$perPage&page=$page")
        : Uri.parse(
            "$baseUrl/posts?_embed&categories=$categoryId&per_page=$perPage&page=$page");

    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final response = await _client.get(url).timeout(_timeoutDuration);

        if (response.statusCode == 200) {
          final List<dynamic> posts = json.decode(response.body);
          // Ensure excerpt and featured media are included
          final processedPosts = posts.map((post) {
            return {
              'id': post['id'],
              'title': post['title'],
              'excerpt': post['excerpt'],
              'date': post['date'],
              '_embedded': post['_embedded'],
              'content': post['content'],
              'link': post['link'],
            };
          }).toList();

          // Cache the posts for this specific category only for page 1
          if (page == 1) {
            await _cacheService.cacheArticles(processedPosts,
                categoryId: categoryId);
          }

          return processedPosts;
        } else {
          throw Exception("Failed to load posts");
        }
      } on TimeoutException catch (_) {
        attempt++;
        if (attempt >= _maxRetries) {
          throw Exception("Request timed out after $_maxRetries attempts");
        }
      } on SocketException catch (_) {
        // Check connectivity before retrying
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          // No internet connection, return cached data if available only for page 1
          if (page == 1) {
            final cachedArticles =
                await _cacheService.getCachedArticles(categoryId: categoryId);
            if (cachedArticles.isNotEmpty) {
              return cachedArticles;
            } else {
              throw Exception(
                  "No internet connection and no cached data available");
            }
          } else {
            throw Exception(
                "No internet connection and no cached data available");
          }
        } else {
          attempt++;
          if (attempt >= _maxRetries) {
            throw Exception("Network error after $_maxRetries attempts");
          }
        }
      } catch (e) {
        throw Exception("Unexpected error: $e");
      }
    }
    // If all retries fail, throw generic exception
    throw Exception("Failed to load posts after $_maxRetries attempts");
  }

  Future<List<dynamic>> fetchCategories({int parent = 0}) async {
    final url = Uri.parse("$baseUrl/categories?parent=$parent&per_page=20");
    final response = await _client.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load categories");
    }
  }

  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }
}

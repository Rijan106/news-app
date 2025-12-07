import 'dart:async';
import '../services/news_service.dart';
import '../services/video_service.dart';
import '../config/api_config.dart';

class LiveUpdateService {
  final NewsService _newsService = NewsService();
  final VideoService _videoService = VideoService();

  Timer? _pollTimer;
  DateTime? _lastNewsCheck;
  DateTime? _lastVideoCheck;

  // Polling interval (5 minutes)
  static const Duration pollInterval = Duration(minutes: 5);

  // Callbacks for new content
  Function(int newCount)? onNewNewsAvailable;
  Function(int newCount)? onNewVideosAvailable;
  Function(String title, String message)? onBreakingNews;

  // Start polling for updates
  void startPolling() {
    _lastNewsCheck = DateTime.now();
    _lastVideoCheck = DateTime.now();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(pollInterval, (_) => _checkForUpdates());
  }

  // Stop polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // Manual check for updates
  Future<Map<String, int>> checkForUpdates() async {
    return await _checkForUpdates();
  }

  Future<Map<String, int>> _checkForUpdates() async {
    int newNewsCount = 0;
    int newVideosCount = 0;

    try {
      // Check for new news articles
      final news = await _newsService.fetchPosts(
          forceRefresh: true, page: 1, perPage: 10);

      if (_lastNewsCheck != null && news.isNotEmpty) {
        // Count articles newer than last check
        newNewsCount = news.where((article) {
          final dateStr = article['date']?.toString();
          if (dateStr == null) return false;
          final articleDate = DateTime.parse(dateStr);
          return articleDate.isAfter(_lastNewsCheck!);
        }).length;

        // Check for breaking news (articles with "breaking" in title)
        if (newNewsCount > 0) {
          final breakingNews = news.firstWhere(
            (article) {
              final title =
                  article['title']?['rendered']?.toString().toLowerCase() ?? '';
              return title.contains('breaking') || title.contains('urgent');
            },
            orElse: () => {},
          );

          if (breakingNews.isNotEmpty && onBreakingNews != null) {
            final title = breakingNews['title']?['rendered'] ?? 'Breaking News';
            onBreakingNews!(title, 'New breaking news available');
          }
        }
      }

      _lastNewsCheck = DateTime.now();

      // Notify if new content available
      if (newNewsCount > 0 && onNewNewsAvailable != null) {
        onNewNewsAvailable!(newNewsCount);
      }
    } catch (e) {
      // Silently fail - don't interrupt user experience
    }

    return {
      'news': newNewsCount,
      'videos': newVideosCount,
    };
  }

  // Check if there are updates available
  Future<bool> hasUpdates() async {
    final updates = await checkForUpdates();
    return (updates['news'] ?? 0) > 0 || (updates['videos'] ?? 0) > 0;
  }

  void dispose() {
    stopPolling();
    _newsService.dispose();
    _videoService.dispose();
  }
}

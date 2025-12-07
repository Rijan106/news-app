import 'package:flutter/material.dart';
import '../services/live_update_service.dart';
import '../services/notification_service.dart';

class LiveUpdateProvider extends ChangeNotifier {
  final LiveUpdateService _liveUpdateService = LiveUpdateService();
  final NotificationService _notificationService = NotificationService();

  String? _breakingNewsTitle;
  String? _breakingNewsMessage;
  bool _hasUnknownNews = false;
  bool _hasUnknownVideos = false;

  String? get breakingNewsTitle => _breakingNewsTitle;
  String? get breakingNewsMessage => _breakingNewsMessage;
  bool get hasBreakingNews => _breakingNewsTitle != null;
  bool get hasUnknownNews => _hasUnknownNews;
  bool get hasUnknownVideos => _hasUnknownVideos;

  LiveUpdateProvider() {
    _initialize();
  }

  void _initialize() {
    // Setup callbacks
    _liveUpdateService.onNewNewsAvailable = (count) {
      _hasUnknownNews = true;
      _notificationService.showNewNewsNotification(count);
      notifyListeners();
    };

    _liveUpdateService.onNewVideosAvailable = (count) {
      _hasUnknownVideos = true;
      _notificationService.showNewVideosNotification(count);
      notifyListeners();
    };

    _liveUpdateService.onBreakingNews = (title, message) {
      _breakingNewsTitle = title;
      _breakingNewsMessage = message;
      _notificationService.showBreakingNewsNotification(title, message);
      notifyListeners();
    };

    // Start polling
    _liveUpdateService.startPolling();
  }

  void dismissBreakingNews() {
    _breakingNewsTitle = null;
    _breakingNewsMessage = null;
    notifyListeners();
  }

  void clearUnknownNews() {
    _hasUnknownNews = false;
    notifyListeners();
  }

  void clearUnknownVideos() {
    _hasUnknownVideos = false;
    notifyListeners();
  }

  Future<void> manualRefresh() async {
    await _liveUpdateService.checkForUpdates();
  }

  @override
  void dispose() {
    _liveUpdateService.dispose();
    super.dispose();
  }
}

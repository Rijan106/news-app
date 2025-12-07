import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  bool _newsEnabled = true;
  bool _videoEnabled = true;
  bool _breakingEnabled = true;

  bool get newsEnabled => _newsEnabled;
  bool get videoEnabled => _videoEnabled;
  bool get breakingEnabled => _breakingEnabled;

  NotificationProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _newsEnabled = await _notificationService.isNewsNotificationsEnabled();
    _videoEnabled = await _notificationService.isVideoNotificationsEnabled();
    _breakingEnabled =
        await _notificationService.isBreakingNotificationsEnabled();
    notifyListeners();
  }

  Future<void> toggleNews(bool value) async {
    _newsEnabled = value;
    await _notificationService.setNewsNotifications(value);
    notifyListeners();
  }

  Future<void> toggleVideo(bool value) async {
    _videoEnabled = value;
    await _notificationService.setVideoNotifications(value);
    notifyListeners();
  }

  Future<void> toggleBreaking(bool value) async {
    _breakingEnabled = value;
    await _notificationService.setBreakingNotifications(value);
    notifyListeners();
  }

  Future<String?> getDeviceToken() async {
    return await _notificationService.getToken();
  }
}

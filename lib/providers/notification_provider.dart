import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  Map<String, bool> _categoryNotifications = {};

  bool get notificationsEnabled => _notificationsEnabled;
  Map<String, bool> get categoryNotifications => _categoryNotifications;

  NotificationProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

      // Load category preferences
      final categories = ['education', 'news', 'announcements', 'updates'];
      for (String category in categories) {
        _categoryNotifications[category] =
            prefs.getBool('category_$category') ?? true;
      }

      notifyListeners();
    } catch (e) {
      print('Error loading notification preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);

      // Save category preferences
      for (String category in _categoryNotifications.keys) {
        await prefs.setBool(
            'category_$category', _categoryNotifications[category]!);
      }
    } catch (e) {
      print('Error saving notification preferences: $e');
    }
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _savePreferences();
    notifyListeners();
  }

  void toggleCategoryNotification(String category, bool value) {
    _categoryNotifications[category] = value;
    _savePreferences();
    notifyListeners();
  }

  Future<String?> getDeviceToken() async {
    return await NotificationService().getToken();
  }
}

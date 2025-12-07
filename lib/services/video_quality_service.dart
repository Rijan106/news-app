import 'package:shared_preferences/shared_preferences.dart';

class VideoQualityService {
  static const String _qualityKey = 'video_quality_preference';
  static const String _autoQualityKey = 'auto_quality_enabled';

  // Quality options
  static const String qualityAuto = 'auto';
  static const String quality144p = '144p';
  static const String quality240p = '240p';
  static const String quality360p = '360p';
  static const String quality480p = '480p';
  static const String quality720p = '720p';
  static const String quality1080p = '1080p';

  static const List<String> availableQualities = [
    qualityAuto,
    quality144p,
    quality240p,
    quality360p,
    quality480p,
    quality720p,
    quality1080p,
  ];

  // Save quality preference
  Future<void> saveQualityPreference(String quality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_qualityKey, quality);
  }

  // Get quality preference
  Future<String> getQualityPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_qualityKey) ?? qualityAuto;
  }

  // Save auto quality setting
  Future<void> setAutoQuality(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoQualityKey, enabled);
  }

  // Get auto quality setting
  Future<bool> isAutoQualityEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoQualityKey) ?? true;
  }

  // Get quality label for display
  static String getQualityLabel(String quality) {
    switch (quality) {
      case qualityAuto:
        return 'Auto';
      case quality144p:
        return '144p';
      case quality240p:
        return '240p';
      case quality360p:
        return '360p';
      case quality480p:
        return '480p';
      case quality720p:
        return '720p';
      case quality1080p:
        return '1080p';
      default:
        return 'Auto';
    }
  }

  // Get quality icon
  static String getQualityIcon(String quality) {
    if (quality == qualityAuto) return '🔄';
    if (quality == quality144p || quality == quality240p) return '📱';
    if (quality == quality360p || quality == quality480p) return '💻';
    return '🖥️'; // 720p, 1080p
  }
}

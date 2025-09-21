import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedTheme = 'default'; // default, blue, green, purple
  double _fontSize = 16.0;
  bool _autoDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  String get selectedTheme => _selectedTheme;
  double get fontSize => _fontSize;
  bool get autoDarkMode => _autoDarkMode;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedTheme = prefs.getString('selectedTheme') ?? 'default';
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _autoDarkMode = prefs.getBool('autoDarkMode') ?? false;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preferences: $e');
    }
  }

  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setString('selectedTheme', _selectedTheme);
      await prefs.setDouble('fontSize', _fontSize);
      await prefs.setBool('autoDarkMode', _autoDarkMode);
    } catch (e) {
      print('Error saving theme preferences: $e');
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _savePreferences();
    notifyListeners();
  }

  void setTheme(String theme) {
    _selectedTheme = theme;
    _savePreferences();
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size.clamp(12.0, 24.0);
    _savePreferences();
    notifyListeners();
  }

  void toggleAutoDarkMode() {
    _autoDarkMode = !_autoDarkMode;
    _savePreferences();
    notifyListeners();
  }

  ThemeData get theme {
    return _isDarkMode ? _getDarkTheme() : _getLightTheme();
  }

  ThemeData _getLightTheme() {
    Color primaryColor;
    Color accentColor;

    switch (_selectedTheme) {
      case 'blue':
        primaryColor = const Color(0xFF1976D2);
        accentColor = const Color(0xFF42A5F5);
        break;
      case 'green':
        primaryColor = const Color(0xFF388E3C);
        accentColor = const Color(0xFF66BB6A);
        break;
      case 'purple':
        primaryColor = const Color(0xFF7B1FA2);
        accentColor = const Color(0xFFBA68C8);
        break;
      default:
        primaryColor = const Color(0xFF59151e);
        accentColor = const Color(0xFF8B2635);
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardColor: Colors.white,
      cardTheme: CardThemeData(
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.black, fontSize: _fontSize),
        bodyMedium: TextStyle(color: Colors.black87, fontSize: _fontSize - 2),
        titleMedium: TextStyle(
            color: Colors.black,
            fontSize: _fontSize + 2,
            fontWeight: FontWeight.w500),
        titleLarge: TextStyle(
            color: Colors.black,
            fontSize: _fontSize + 4,
            fontWeight: FontWeight.bold),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        background: Colors.grey.shade50,
      ),
    );
  }

  ThemeData _getDarkTheme() {
    Color primaryColor;
    Color accentColor;

    switch (_selectedTheme) {
      case 'blue':
        primaryColor = const Color(0xFF1976D2);
        accentColor = const Color(0xFF42A5F5);
        break;
      case 'green':
        primaryColor = const Color(0xFF388E3C);
        accentColor = const Color(0xFF66BB6A);
        break;
      case 'purple':
        primaryColor = const Color(0xFF7B1FA2);
        accentColor = const Color(0xFFBA68C8);
        break;
      default:
        primaryColor = const Color(0xFF59151e);
        accentColor = const Color(0xFF8B2635);
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardColor: const Color(0xFF1E1E1E),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: _fontSize),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: _fontSize - 2),
        titleMedium: TextStyle(
            color: Colors.white,
            fontSize: _fontSize + 2,
            fontWeight: FontWeight.w500),
        titleLarge: TextStyle(
            color: Colors.white,
            fontSize: _fontSize + 4,
            fontWeight: FontWeight.bold),
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
      ),
    );
  }
}

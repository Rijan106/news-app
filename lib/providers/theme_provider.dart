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
    Color surfaceColor;
    Color backgroundColor;

    switch (_selectedTheme) {
      case 'blue':
        primaryColor = const Color(0xFF2196F3);
        accentColor = const Color(0xFF64B5F6);
        surfaceColor = const Color(0xFF1E1E2E);
        backgroundColor = const Color(0xFF0F0F23);
        break;
      case 'green':
        primaryColor = const Color(0xFF4CAF50);
        accentColor = const Color(0xFF81C784);
        surfaceColor = const Color(0xFF1E2E1E);
        backgroundColor = const Color(0xFF0F230F);
        break;
      case 'purple':
        primaryColor = const Color(0xFF9C27B0);
        accentColor = const Color(0xFFBA68C8);
        surfaceColor = const Color(0xFF2E1E2E);
        backgroundColor = const Color(0xFF230F23);
        break;
      default:
        primaryColor = const Color(0xFFFF6B6B);
        accentColor = const Color(0xFFFF8E8E);
        surfaceColor = const Color(0xFF2A1A1A);
        backgroundColor = const Color(0xFF1A0F0F);
    }

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      cardColor: surfaceColor,
      cardTheme: CardThemeData(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: _fontSize,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: _fontSize - 2,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontSize: _fontSize + 2,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: _fontSize + 4,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: _fontSize + 6,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        onSurface: Colors.white.withOpacity(0.9),
        onBackground: Colors.white.withOpacity(0.9),
      ),
      dividerColor: Colors.white.withOpacity(0.1),
      iconTheme: IconThemeData(
        color: Colors.white.withOpacity(0.8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.white.withOpacity(0.6),
      ),
    );
  }
}

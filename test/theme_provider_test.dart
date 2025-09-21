import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Provider Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('ThemeProvider initializes with light mode', () {
      expect(themeProvider.isDarkMode, isFalse);
      expect(themeProvider.theme.brightness, equals(Brightness.light));
    });

    test('ThemeProvider toggles to dark mode', () {
      themeProvider.toggleTheme();
      expect(themeProvider.isDarkMode, isTrue);
      expect(themeProvider.theme.brightness, equals(Brightness.dark));
    });

    test('ThemeProvider toggles back to light mode', () {
      themeProvider.toggleTheme(); // to dark
      themeProvider.toggleTheme(); // back to light
      expect(themeProvider.isDarkMode, isFalse);
      expect(themeProvider.theme.brightness, equals(Brightness.light));
    });

    testWidgets('ThemeProvider works with MaterialApp',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: Scaffold(
                  appBar: AppBar(title: const Text('Test')),
                  body: const Center(child: Text('Test Body')),
                ),
              );
            },
          ),
        ),
      );

      // Verify initial light theme
      expect(themeProvider.isDarkMode, isFalse);

      // Toggle to dark mode
      themeProvider.toggleTheme();
      await tester.pump();

      // Verify dark theme
      expect(themeProvider.isDarkMode, isTrue);
    });
  });
}

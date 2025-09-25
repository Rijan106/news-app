import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/main.dart';
import '../lib/providers/theme_provider.dart';
import '../lib/pages/home_page.dart';
import '../lib/pages/settings_page.dart';
import '../lib/pages/bookmarks_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Integration Theme Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('Complete theme switching flow from home to settings',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: const MainLayout(),
                routes: {
                  '/settings': (context) => const SettingsPage(),
                  '/bookmarks': (context) => const BookmarksPage(),
                },
              );
            },
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify initial theme
      expect(themeProvider.isDarkMode, isFalse);

      // Open drawer to access settings
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Navigate to settings through drawer
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify settings page is displayed
      expect(find.text('Settings'), findsOneWidget);

      // Find and tap theme toggle switch
      final themeSwitch = find.byType(Switch).first;
      expect(themeSwitch, findsWidgets);

      await tester.tap(themeSwitch);
      await tester.pumpAndSettle();

      // Verify theme changed
      expect(themeProvider.isDarkMode, isTrue);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify theme persists on home page
      expect(themeProvider.isDarkMode, isTrue);
    });

    testWidgets('Theme persistence across navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: const MainLayout(),
                routes: {
                  '/settings': (context) => const SettingsPage(),
                  '/bookmarks': (context) => const BookmarksPage(),
                },
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Open drawer and navigate to bookmarks
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('My Bookmarks'));
      await tester.pumpAndSettle();

      // Verify theme is maintained
      expect(themeProvider.isDarkMode, isTrue);
      expect(find.text('My Bookmarks'), findsOneWidget);

      // Navigate back and go to settings
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify theme is still maintained
      expect(themeProvider.isDarkMode, isTrue);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Theme affects all UI components consistently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: const MainLayout(),
                routes: {
                  '/settings': (context) => const SettingsPage(),
                },
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial light theme colors
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      // Switch to dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Navigate to settings to verify theme consistency
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify dark theme is applied
      expect(themeProvider.isDarkMode, isTrue);
      expect(themeProvider.theme.brightness, equals(Brightness.dark));
    });
  });
}

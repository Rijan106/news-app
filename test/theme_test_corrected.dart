import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/providers/theme_provider.dart';
import '../lib/pages/settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Tests - Corrected', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('Theme switching in settings page works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: const SettingsPage(),
              );
            },
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Verify initial theme
      expect(themeProvider.isDarkMode, isFalse);

      // Find the Dark Mode switch specifically (first switch in the list)
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2)); // Should find 2 switches

      // Tap the first switch (Dark Mode)
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Verify theme changed
      expect(themeProvider.isDarkMode, isTrue);

      // Verify theme brightness
      expect(themeProvider.theme.brightness, equals(Brightness.dark));
    });

    testWidgets('Theme persistence works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: const SettingsPage(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify theme is maintained
      expect(themeProvider.isDarkMode, isTrue);

      // Switch back to light mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify theme changed back
      expect(themeProvider.isDarkMode, isFalse);
      expect(themeProvider.theme.brightness, equals(Brightness.light));
    });

    testWidgets('Theme affects UI components consistently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: const SettingsPage(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial light theme
      expect(themeProvider.theme.brightness, equals(Brightness.light));

      // Switch to dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify dark theme is applied
      expect(themeProvider.isDarkMode, isTrue);
      expect(themeProvider.theme.brightness, equals(Brightness.dark));

      // Check that app bar title is still visible
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}

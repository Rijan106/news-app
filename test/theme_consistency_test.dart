import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/main.dart';
import '../lib/providers/theme_provider.dart';
import '../lib/pages/settings_page.dart';
import '../lib/pages/bookmarks_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Consistency Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      // Mock shared preferences
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('Settings page uses theme provider correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: MaterialApp(
            theme: themeProvider.theme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app bar uses theme primary color
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.backgroundColor,
          equals(themeProvider.theme.primaryColor));

      // Verify scaffold uses theme background color
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidget.backgroundColor,
          equals(themeProvider.theme.scaffoldBackgroundColor));
    });

    testWidgets('Bookmarks page uses theme provider correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: MaterialApp(
            theme: themeProvider.theme,
            home: const BookmarksPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app bar uses theme primary color
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.backgroundColor,
          equals(themeProvider.theme.primaryColor));

      // Verify scaffold uses theme background color
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);

      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidget.backgroundColor,
          equals(themeProvider.theme.scaffoldBackgroundColor));
    });

    testWidgets('Theme switching works correctly - Light to Dark',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: MaterialApp(
            theme: themeProvider.theme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should be light theme
      expect(themeProvider.isDarkMode, isFalse);

      // Switch to dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(themeProvider.isDarkMode, isTrue);

      // Verify theme colors changed
      expect(themeProvider.theme.brightness, equals(Brightness.dark));
      expect(themeProvider.theme.scaffoldBackgroundColor,
          isNot(equals(Colors.white)));
    });

    testWidgets('Theme switching works correctly - Dark to Light',
        (WidgetTester tester) async {
      // Start with dark mode
      themeProvider.toggleTheme();

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: MaterialApp(
            theme: themeProvider.theme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be dark theme
      expect(themeProvider.isDarkMode, isTrue);

      // Switch back to light mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      expect(themeProvider.isDarkMode, isFalse);

      // Verify theme colors changed
      expect(themeProvider.theme.brightness, equals(Brightness.light));
      expect(themeProvider.theme.scaffoldBackgroundColor, equals(Colors.white));
    });

    testWidgets('Color theme switching works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: MaterialApp(
            theme: themeProvider.theme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Default theme should be red
      expect(themeProvider.selectedTheme, equals('default'));
      expect(themeProvider.theme.primaryColor, equals(const Color(0xFF59151e)));

      // Switch to blue theme
      themeProvider.setTheme('blue');
      await tester.pumpAndSettle();

      expect(themeProvider.selectedTheme, equals('blue'));
      expect(themeProvider.theme.primaryColor, equals(const Color(0xFF1976D2)));

      // Switch to green theme
      themeProvider.setTheme('green');
      await tester.pumpAndSettle();

      expect(themeProvider.selectedTheme, equals('green'));
      expect(themeProvider.theme.primaryColor, equals(const Color(0xFF388E3C)));

      // Switch to purple theme
      themeProvider.setTheme('purple');
      await tester.pumpAndSettle();

      expect(themeProvider.selectedTheme, equals('purple'));
      expect(themeProvider.theme.primaryColor, equals(const Color(0xFF7B1FA2)));
    });

    testWidgets('Settings page dark mode toggle works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: MaterialApp(
            theme: themeProvider.theme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the dark mode switch
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2)); // There are two switches on the page

      // We want the first switch (dark mode toggle)
      final switchFinder = switches.at(0);

      // Initially should be off (light mode)
      Switch switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isFalse);

      // Tap the switch to turn on dark mode
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verify switch is now on
      switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, isTrue);

      // Verify theme provider updated
      expect(themeProvider.isDarkMode, isTrue);
    });

    testWidgets('Settings page color theme dropdown works',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: MaterialApp(
            theme: themeProvider.theme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the color theme dropdown
      final dropdownFinder = find.byType(DropdownButton<String>);
      expect(dropdownFinder, findsOneWidget);

      // Initially should be default
      DropdownButton<String> dropdownWidget =
          tester.widget<DropdownButton<String>>(dropdownFinder);
      expect(dropdownWidget.value, equals('default'));

      // Tap dropdown to open menu
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Select blue theme
      await tester.tap(find.text('Blue').last);
      await tester.pumpAndSettle();

      // Verify theme changed
      expect(themeProvider.selectedTheme, equals('blue'));
    });

    testWidgets('Bookmarks page adapts to theme changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: const BookmarksPage(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should be light theme
      expect(themeProvider.isDarkMode, isFalse);

      // Switch to dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify theme provider updated
      expect(themeProvider.isDarkMode, isTrue);

      // Verify app bar uses theme primary color
      final appBar = find.byType(AppBar);
      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.backgroundColor,
          equals(themeProvider.theme.primaryColor));

      // Verify scaffold uses dark theme background
      final scaffold = find.byType(Scaffold);
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidget.backgroundColor,
          equals(themeProvider.theme.scaffoldBackgroundColor));
    });

    testWidgets('Font size changes are applied correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: MaterialApp(
            theme: themeProvider.theme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Default font size should be 16
      expect(themeProvider.fontSize, equals(16.0));

      // Change font size
      themeProvider.setFontSize(20.0);
      await tester.pumpAndSettle();

      expect(themeProvider.fontSize, equals(20.0));

      // Verify theme reflects new font size
      expect(themeProvider.theme.textTheme.bodyLarge?.fontSize, equals(20.0));
    });

    testWidgets('Auto dark mode toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: MaterialApp(
            theme: themeProvider.theme,
            home: const SettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find auto dark mode switch (should be the second switch)
      final switches = find.byType(Switch);
      expect(switches,
          findsNWidgets(2)); // Dark mode switch and auto dark mode switch

      final autoDarkModeSwitch = switches.at(1);

      // Initially should be off
      Switch switchWidget = tester.widget<Switch>(autoDarkModeSwitch);
      expect(switchWidget.value, isFalse);

      // Tap to enable auto dark mode
      await tester.tap(autoDarkModeSwitch);
      await tester.pumpAndSettle();

      // Verify switch is now on
      switchWidget = tester.widget<Switch>(autoDarkModeSwitch);
      expect(switchWidget.value, isTrue);

      // Verify theme provider updated
      expect(themeProvider.autoDarkMode, isTrue);
    });
  });
}

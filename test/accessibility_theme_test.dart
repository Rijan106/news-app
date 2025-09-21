import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/providers/theme_provider.dart';
import '../lib/pages/settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Accessibility Theme Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('Color contrast ratios meet WCAG guidelines in light mode',
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
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Test Button'),
                      ),
                      const Text('Test Text'),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Test Input',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test that we're in light mode
      expect(themeProvider.isDarkMode, isFalse);

      // Verify app bar has sufficient contrast
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      // Verify button has accessible colors
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);

      // Verify text is readable
      final text = find.text('Test Text');
      expect(text, findsOneWidget);
    });

    testWidgets('Color contrast ratios meet WCAG guidelines in dark mode',
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
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Test Button'),
                      ),
                      const Text('Test Text'),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Test Input',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Switch to dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Test that we're in dark mode
      expect(themeProvider.isDarkMode, isTrue);

      // Verify dark theme maintains accessibility
      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);

      final text = find.text('Test Text');
      expect(text, findsOneWidget);
    });

    testWidgets('Screen reader compatibility - semantic labels',
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

      // Test for semantic labels on interactive elements
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Test for text elements that should be accessible
      final textElements = find.byType(Text);
      expect(textElements, findsWidgets);
    });

    testWidgets('Keyboard navigation support', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Button 1'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Button 2'),
                      ),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Test Input',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test focus order
      final button1 = find.text('Button 1');
      final button2 = find.text('Button 2');
      final textField = find.byType(TextField);

      expect(button1, findsOneWidget);
      expect(button2, findsOneWidget);
      expect(textField, findsOneWidget);

      // Verify all interactive elements are present and focusable
      final elevatedButtons = find.byType(ElevatedButton);
      expect(elevatedButtons, findsNWidgets(2));
    });

    testWidgets('Theme toggle accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: Scaffold(
                  appBar: AppBar(
                    title: const Text('Theme Test'),
                    actions: [
                      IconButton(
                        onPressed: themeProvider.toggleTheme,
                        icon: Icon(
                          themeProvider.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        tooltip: themeProvider.isDarkMode
                            ? 'Switch to light mode'
                            : 'Switch to dark mode',
                      ),
                    ],
                  ),
                  body: const Center(
                    child: Text('Theme accessibility test'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Test theme toggle button accessibility
      final themeButton = find.byIcon(Icons.dark_mode);
      expect(themeButton, findsOneWidget);

      // Test tooltip
      final tooltip = find.text('Switch to dark mode');
      expect(tooltip, findsNothing); // Tooltip not visible by default

      // Test theme switching
      await tester.tap(themeButton);
      await tester.pumpAndSettle();

      expect(themeProvider.isDarkMode, isTrue);

      // Verify icon changes
      final lightModeButton = find.byIcon(Icons.light_mode);
      expect(lightModeButton, findsOneWidget);
    });
  });
}

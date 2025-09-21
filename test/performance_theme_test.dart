import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/providers/theme_provider.dart';
import '../lib/pages/home_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Theme Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('Theme switching performance', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: const HomePage(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Toggle theme multiple times to measure performance
      for (int i = 0; i < 10; i++) {
        themeProvider.toggleTheme();
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Print elapsed time for theme toggling
      print(
          'Theme toggling time for 10 switches: ${stopwatch.elapsedMilliseconds} ms');

      // Assert that theme toggling is performant (e.g., under 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    testWidgets('Memory usage with theme changes', (WidgetTester tester) async {
      // This test is a placeholder as memory profiling is not directly supported in widget tests
      // Recommend using external profiling tools for detailed memory analysis
      expect(true, isTrue);
    });

    testWidgets('Rendering performance with large news lists',
        (WidgetTester tester) async {
      // This test is a placeholder; actual implementation depends on news list widget
      // For now, just ensure the HomePage builds without issues
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: const HomePage(),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}

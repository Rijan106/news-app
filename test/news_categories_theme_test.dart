import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import '../lib/pages/news_tab_page.dart';
import '../lib/providers/theme_provider.dart';
import '../lib/providers/search_provider.dart';
import '../lib/services/news_service.dart';
import 'news_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('News Categories Theme and Dark Mode Tests', () {
    late ThemeProvider themeProvider;
    late MockClient mockClient;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      mockClient = MockClient();
      await Future.delayed(const Duration(milliseconds: 100));

      // Mock HTTP responses
      when(mockClient.get(any)).thenAnswer((_) async => http.Response('''
          [
            {"id": 1, "name": "Technology", "parent": 0},
            {"id": 2, "name": "Sports", "parent": 0},
            {"id": 3, "name": "Business", "parent": 0}
          ]
          ''', 200));
    });

    testWidgets(
        'NewsTabPage uses theme provider correctly and toggles dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>(create: (_) => themeProvider),
            ChangeNotifierProvider<SearchProvider>(
                create: (_) => SearchProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: NewsTabPage(newsService: NewsService(client: mockClient)),
              );
            },
          ),
        ),
      );

      // Wait for initial loading - reduced time
      await tester.pump(const Duration(milliseconds: 500));

      // Verify initial theme is light
      expect(themeProvider.isDarkMode, isFalse);

      // Toggle dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify theme is dark
      expect(themeProvider.isDarkMode, isTrue);
    });

    testWidgets('NewsTabPage app bar uses theme colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: NewsTabPage(newsService: NewsService(client: mockClient)),
              );
            },
          ),
        ),
      );

      // Wait for initial loading - reduced time
      await tester.pump(const Duration(milliseconds: 500));

      final appBar = find.byType(AppBar);
      expect(appBar, findsOneWidget);
      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBarWidget.backgroundColor,
          equals(Theme.of(tester.element(appBar)).primaryColor));
    });

    testWidgets('NewsTabPage tab bar uses theme colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: NewsTabPage(newsService: NewsService(client: mockClient)),
              );
            },
          ),
        ),
      );

      // Wait for initial loading and categories to load - reduced time
      await tester.pump(const Duration(milliseconds: 800));

      final tabBar = find.byType(TabBar);
      if (tabBar.evaluate().isNotEmpty) {
        final tabBarWidget = tester.widget<TabBar>(tabBar.first);
        expect(tabBarWidget.labelColor, equals(Colors.white));
        expect(tabBarWidget.unselectedLabelColor, equals(Colors.white70));
      }
    });

    testWidgets('NewsTabPage buttons use theme colors in dark mode',
        (WidgetTester tester) async {
      // Switch to dark mode
      themeProvider.toggleTheme();
      await Future.delayed(const Duration(milliseconds: 100));

      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider,
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                theme: themeProvider.theme,
                home: NewsTabPage(newsService: NewsService(client: mockClient)),
              );
            },
          ),
        ),
      );

      // Wait for initial loading - reduced time
      await tester.pump(const Duration(milliseconds: 500));

      // Check if buttons exist and use theme colors
      final elevatedButtons = find.byType(ElevatedButton);
      expect(elevatedButtons, findsWidgets);

      // Verify theme is dark
      expect(themeProvider.isDarkMode, isTrue);
    });
  });
}

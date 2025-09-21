import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:gurubaa_news/pages/home_page.dart';
import 'package:gurubaa_news/providers/theme_provider.dart';
import 'package:gurubaa_news/providers/search_provider.dart';

void main() {
  testWidgets('HomePage displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    // Wait for the widget to build
    await tester.pumpAndSettle();

    // Verify that the home page displays expected elements
    expect(find.text('Latest News'), findsOneWidget);
    expect(find.text('Search Latest News'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);
  });

  testWidgets('HomePage search functionality works',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find the search field and enter text
    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'test search');
    await tester.pump();

    // Verify the text was entered
    expect(find.text('test search'), findsOneWidget);
  });

  testWidgets('HomePage sort dropdown works', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => SearchProvider()),
        ],
        child: const MaterialApp(
          home: HomePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Find and tap the dropdown
    final dropdown = find.byType(DropdownButton<String>);
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    // Verify dropdown items are shown
    expect(find.text('Newest'), findsWidgets);
    expect(find.text('Oldest'), findsWidgets);
  });
}

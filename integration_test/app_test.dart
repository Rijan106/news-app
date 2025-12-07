import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:Gurubaa_News/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App integration test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const GurubaaNewsApp());
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Gurubaa - Latest News'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(
        find.text('Latest News'), findsWidgets); // Multiple instances expected

    // Open drawer
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    // Verify drawer items - use more specific finders
    expect(find.byType(ListTile).at(0), findsOneWidget); // Latest News
    expect(find.text('News Categories'), findsOneWidget);
    expect(find.text('My Bookmarks'), findsOneWidget);
    expect(find.text('Recently Viewed'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Navigate to News Categories
    await tester.tap(find.text('News Categories'));
    await tester.pumpAndSettle();

    // Verify navigation - check for app bar title
    expect(find.text('News Categories'),
        findsWidgets); // Multiple instances expected

    // Go back to home
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Latest News'));
    await tester.pumpAndSettle();

    // Verify we're back home
    expect(find.text('Gurubaa - Latest News'), findsOneWidget);
  });
}

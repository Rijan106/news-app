import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Gurubaa_News/main.dart';

void main() {
  testWidgets('Performance test - App startup time',
      (WidgetTester tester) async {
    final stopwatch = Stopwatch()..start();

    // Build the app
    await tester.pumpWidget(const GurubaaNewsApp());

    // Wait for initial frame
    await tester.pump();

    // Measure startup time
    stopwatch.stop();
    final startupTime = stopwatch.elapsedMilliseconds;

    print('App startup time: ${startupTime}ms');

    // Assert reasonable startup time (under 2 seconds)
    expect(startupTime, lessThan(2000));

    // Verify app is built and basic elements are present
    expect(find.text('Gurubaa - Latest News'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('Performance test - List rendering', (WidgetTester tester) async {
    await tester.pumpWidget(const GurubaaNewsApp());
    await tester.pumpAndSettle();

    // Measure time to render initial state
    final stopwatch = Stopwatch()..start();
    await tester.pump();
    stopwatch.stop();

    print('List rendering time: ${stopwatch.elapsedMilliseconds}ms');

    // Verify basic UI elements are rendered
    expect(find.byType(Scaffold),
        findsWidgets); // Multiple Scaffold widgets expected
    expect(
        find.byType(AppBar), findsWidgets); // Multiple AppBar widgets expected
  });

  testWidgets('Performance test - Navigation smoothness',
      (WidgetTester tester) async {
    await tester.pumpWidget(const GurubaaNewsApp());
    await tester.pumpAndSettle();

    // Test drawer opening performance
    final stopwatch = Stopwatch()..start();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    stopwatch.stop();
    print('Drawer open time: ${stopwatch.elapsedMilliseconds}ms');

    // Verify drawer opened
    expect(find.text('Latest News'), findsWidgets);
    expect(find.text('News Categories'), findsWidgets);
  });
}

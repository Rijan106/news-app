import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/pages/home_page.dart';
import '../lib/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomePage Theme and Dark Mode Tests', () {
    late ThemeProvider themeProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    testWidgets('HomePage uses theme provider correctly and toggles dark mode',
        (WidgetTester tester) async {
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

      // Verify initial theme is light
      expect(themeProvider.isDarkMode, isFalse);
      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidget.backgroundColor, equals(Colors.white));

      // Toggle dark mode
      themeProvider.toggleTheme();
      await tester.pumpAndSettle();

      // Verify theme is dark
      expect(themeProvider.isDarkMode, isTrue);
      final scaffoldWidgetDark = tester.widget<Scaffold>(scaffold);
      expect(scaffoldWidgetDark.backgroundColor,
          equals(themeProvider.theme.scaffoldBackgroundColor));
    });
  });
}

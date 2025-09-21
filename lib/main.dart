import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'providers/theme_provider.dart';
import 'providers/search_provider.dart';
import 'providers/notification_provider.dart';
import 'services/notification_service.dart';
import 'pages/home_page.dart';
import 'pages/news_tab_page.dart';
import 'pages/bookmarks_page.dart';
import 'pages/settings_page.dart';
import 'pages/recently_viewed_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase optionally - app will work without it
  bool firebaseInitialized = false;
  try {
    if (kIsWeb) {
      // For web platform, provide explicit options
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCsz2A4Zy8822GkrgIrz-Ye_kKIbOt4LWs",
          authDomain: "pushnotification-f9cc5.firebaseapp.com",
          projectId: "pushnotification-f9cc5",
          storageBucket: "pushnotification-f9cc5.firebasestorage.app",
          messagingSenderId: "138106899280",
          appId: "1:138106899280:web:1c551d42b679527a35ba55",
        ),
      );
    } else {
      // For mobile platforms, use default initialization (reads from google-services.json)
      await Firebase.initializeApp();
    }
    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    debugPrint('📱 App will continue without Firebase features');
  }

  // Initialize notification service only if Firebase is available
  if (firebaseInitialized) {
    try {
      await NotificationService().init();
      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('⚠️ Notification service initialization failed: $e');
    }
  } else {
    debugPrint(
        '📱 Skipping notification service initialization (Firebase not available)');
  }

  debugPrint('🚀 Starting Gurubaa News App...');
  runApp(const GurubaaNewsApp());
}

class GurubaaNewsApp extends StatelessWidget {
  const GurubaaNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Gurubaa News',
            theme: themeProvider.theme,
            home: const MainLayout(),
          );
        },
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const NewsTabPage(),
  ];

  final List<String> _pageTitles = [
    'Gurubaa - Latest News',
    'News Categories',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF59151E),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF59151E),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Gurubaa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Education & News Hub',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Latest News'),
              selected: _selectedIndex == 0,
              onTap: () => _onItemTapped(0),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('News Categories'),
              selected: _selectedIndex == 1,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('My Bookmarks'),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookmarksPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Recently Viewed'),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecentlyViewedPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).pop(); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}

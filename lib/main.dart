import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/search_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/live_update_provider.dart';
import 'services/app_initialization_service.dart';
import 'pages/home_page.dart';
import 'pages/news_tab_page.dart';
import 'pages/playlist_page.dart';
import 'pages/bookmarks_page.dart';
import 'pages/settings_page.dart';
import 'pages/recently_viewed_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use the centralized initialization service
  final appInitService = AppInitializationService();
  await appInitService.initializeApp();

  debugPrint('🚀 Starting Gurubaa News App...');
  debugPrint(appInitService.getInitializationStatus());

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
        ChangeNotifierProvider(create: (_) => LiveUpdateProvider()),
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
    const PlaylistPage(),
  ];

  final List<String> _pageTitles = [
    'Gurubaa - Latest News',
    'News Categories',
    'Playlists',
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
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.playlist_play),
              title: const Text('Playlists'),
              selected: _selectedIndex == 2,
              onTap: () => _onItemTapped(2),
            ),
            const Divider(),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/news_service.dart';
import '../providers/theme_provider.dart';
import 'news_list_page.dart';

class NewsTabPage extends StatefulWidget {
  final NewsService? newsService;
  const NewsTabPage({super.key, this.newsService});

  @override
  State<NewsTabPage> createState() => _NewsTabPageState();
}

class _NewsTabPageState extends State<NewsTabPage>
    with TickerProviderStateMixin {
  late final NewsService _newsService;
  TabController? _tabController;
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _newsService = widget.newsService ?? NewsService();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final categories = await _newsService.fetchCategories(parent: 0);

      // Filter out unwanted categories
      final filteredCategories = categories.where((category) {
        final name = category['name'].toString().toLowerCase();
        return name != 'travel' && name != 'uncategorized' && name != 'weather';
      }).toList();

      if (mounted) {
        setState(() {
          _categories = filteredCategories;
          _isLoading = false;
          _tabController =
              TabController(length: filteredCategories.length, vsync: this);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load categories: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Widget _buildCategoryTab(dynamic category) {
    return FutureBuilder<List<dynamic>>(
      future: _newsService.fetchCategories(parent: category['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading subcategories...'),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading subcategories: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final subCategories = snapshot.data ?? [];

        if (subCategories.isEmpty) {
          // No subcategories, show posts directly
          return NewsListPage(categoryId: category['id']);
        }

        return DefaultTabController(
          length: subCategories.length,
          child: Column(
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  isScrollable: true,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: subCategories.map<Widget>((subCat) {
                    return Tab(
                      child: Text(
                        subCat['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: subCategories.map<Widget>((subCat) {
                    return NewsListPage(categoryId: subCat['id']);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        if (_isLoading) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'News Categories',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading categories...'),
                ],
              ),
            ),
          );
        }

        if (_errorMessage != null) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'News Categories',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCategories,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_categories.isEmpty) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                'News Categories',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.white),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            body: const Center(
              child: Text('No categories available'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'News Categories',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, color: Colors.white),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: _categories.map<Widget>((category) {
                return Tab(
                  child: Text(
                    category['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _categories.map<Widget>((category) {
              return _buildCategoryTab(category);
            }).toList(),
          ),
        );
      },
    );
  }
}

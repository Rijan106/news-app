import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/news_service.dart';
import '../services/search_history_service.dart';
import '../providers/theme_provider.dart';
import '../providers/live_update_provider.dart';
import '../widgets/search_filter_dialog.dart';
import '../widgets/breaking_news_banner.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsService _newsService = NewsService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allNews = [];
  List<dynamic> _filteredNews = [];
  String _searchQuery = '';
  String _sortOrder = 'Newest';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  final ScrollController _scrollController = ScrollController();
  List<String> _searchHistory = [];
  DateFilter _dateFilter = DateFilter.all;
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchLatestNews();
    _scrollController.addListener(_onScroll);
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final history = await _searchHistoryService.getHistory();
    setState(() {
      _searchHistory = history;
    });
  }

  void _onScroll() {
    // Don't load more if user is searching
    if (_searchQuery.isNotEmpty) return;

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _fetchLatestNews({bool loadMore = false}) async {
    if (loadMore && !_hasMorePages) return;

    try {
      setState(() {
        if (loadMore) {
          _isLoadingMore = true;
        } else {
          _isLoading = true;
          _currentPage = 1;
          _allNews.clear();
        }
      });

      final page = loadMore ? _currentPage + 1 : 1;
      // Load 100 articles at once for comprehensive search
      final data = await _newsService.fetchPosts(
          forceRefresh: !loadMore, page: page, perPage: 100);

      setState(() {
        if (loadMore) {
          _allNews.addAll(data);
          _currentPage = page;
        } else {
          _allNews = data;
        }

        _filteredNews = List.from(_allNews);
        _isLoading = false;
        _isLoadingMore = false;

        // Check if we have more pages
        _hasMorePages = data.length == 100;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      // Handle error
    }
  }

  Future<void> _refresh() async {
    await _fetchLatestNews();
  }

  Future<void> _loadMore() async {
    await _fetchLatestNews(loadMore: true);
  }

  void _searchNews(String query) async {
    if (query.isNotEmpty) {
      await _searchHistoryService.saveSearch(query);
      await _loadSearchHistory();
    }

    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<dynamic> filtered = List.from(_allNews);

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((news) {
        final title =
            news['title']?['rendered']?.toString().toLowerCase() ?? '';
        return title.contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply date filter
    if (_dateFilter != DateFilter.all) {
      final filterDate = getDateFromFilter(_dateFilter);
      if (filterDate != null) {
        filtered = filtered.where((news) {
          final dateStr = news['date']?.toString();
          if (dateStr == null) return false;
          final newsDate = DateTime.parse(dateStr);
          return newsDate.isAfter(filterDate);
        }).toList();
      }
    }

    _filteredNews = filtered;
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SearchFilterDialog(
        currentDateFilter: _dateFilter,
        selectedCategories: _selectedCategories,
        availableCategories: const [],
      ),
    );

    if (result != null) {
      setState(() {
        _dateFilter = result['dateFilter'] as DateFilter;
        _selectedCategories = result['categories'] as List<String>;
        _applyFilters();
      });
    }
  }

  void _sortNews(String order) {
    setState(() {
      _sortOrder = order;
      // First, get the base list (either all news or filtered by search)
      List<dynamic> baseList = _searchQuery.isEmpty
          ? _allNews
          : _allNews.where((news) {
              final title =
                  news['title']?['rendered']?.toString().toLowerCase() ?? '';
              return title.contains(_searchQuery.toLowerCase());
            }).toList();

      // Then sort the list
      baseList.sort((a, b) {
        final dateA =
            a['date'] != null ? DateTime.parse(a['date']) : DateTime(2000);
        final dateB =
            b['date'] != null ? DateTime.parse(b['date']) : DateTime(2000);
        return order == 'Newest'
            ? dateB.compareTo(dateA)
            : dateA.compareTo(dateB);
      });

      _filteredNews = baseList;
    });
  }

  Widget _buildListItem(dynamic news) {
    final title = news['title']?['rendered'] ?? 'No Title';
    final excerpt = news['excerpt']?['rendered'] ?? '';
    final date = news['date']?.toString().substring(0, 10) ?? '';
    final imageUrl = news['_embedded']?['wp:featuredmedia']?[0]?['source_url'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: SizedBox(
          width: 60,
          height: 60,
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, size: 60);
                    },
                  ),
                )
              : const Icon(Icons.article, size: 40),
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 4),
            Text(
              excerpt.replaceAll(RegExp(r'<[^>]*>'), ''),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Read More'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailPage(post: news)),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Consumer<LiveUpdateProvider>(
          builder: (context, liveUpdateProvider, child) {
            return Column(
              children: [
                // Breaking News Banner
                if (liveUpdateProvider.hasBreakingNews)
                  BreakingNewsBanner(
                    title: liveUpdateProvider.breakingNewsTitle!,
                    onTap: () {
                      // Handle tap - verify if message contains a link or just open app
                      // For now, we just dismiss or could navigate to latest news
                      liveUpdateProvider.dismissBreakingNews();
                      _refresh();
                    },
                    onDismiss: () => liveUpdateProvider.dismissBreakingNews(),
                  ),

                // Search bar with history
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Latest News',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _searchNews('');
                                    },
                                  )
                                : (_searchHistory.isNotEmpty
                                    ? PopupMenuButton<String>(
                                        icon: const Icon(Icons.history),
                                        tooltip: 'Search History',
                                        onSelected: (value) {
                                          _searchController.text = value;
                                          _searchNews(value);
                                        },
                                        itemBuilder: (context) => [
                                          ..._searchHistory.map((query) =>
                                              PopupMenuItem(
                                                value: query,
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.history,
                                                        size: 18),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                        child: Text(query)),
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.close,
                                                          size: 16),
                                                      onPressed: () async {
                                                        await _searchHistoryService
                                                            .removeFromHistory(
                                                                query);
                                                        await _loadSearchHistory();
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              )),
                                          if (_searchHistory.isNotEmpty)
                                            PopupMenuItem(
                                              child: TextButton.icon(
                                                icon: const Icon(
                                                    Icons.delete_sweep),
                                                label:
                                                    const Text('Clear History'),
                                                onPressed: () async {
                                                  await _searchHistoryService
                                                      .clearHistory();
                                                  await _loadSearchHistory();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                        ],
                                      )
                                    : null),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: _searchNews,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Filter button
                      IconButton(
                        icon: Badge(
                          isLabelVisible: _dateFilter != DateFilter.all,
                          label: const Text('1'),
                          child: const Icon(Icons.filter_list),
                        ),
                        tooltip: 'Filters',
                        onPressed: _showFilterDialog,
                      ),
                    ],
                  ),
                ),

                // Active filters display
                if (_dateFilter != DateFilter.all)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Chip(
                          label: Text(_getDateFilterLabel()),
                          onDeleted: () {
                            setState(() {
                              _dateFilter = DateFilter.all;
                              _applyFilters();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                // Sort dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<String>(
                    value: _sortOrder,
                    items: const [
                      DropdownMenuItem(value: 'Newest', child: Text('Newest')),
                      DropdownMenuItem(value: 'Oldest', child: Text('Oldest')),
                    ],
                    onChanged: (value) {
                      if (value != null) _sortNews(value);
                    },
                    isExpanded: true,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredNews.isEmpty
                            ? const Center(
                                child: Text("No latest news available"))
                            : ListView.builder(
                                controller: _scrollController,
                                itemCount: _filteredNews.length +
                                    (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _filteredNews.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  return _buildListItem(_filteredNews[index]);
                                },
                              ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getDateFilterLabel() {
    switch (_dateFilter) {
      case DateFilter.today:
        return 'Today';
      case DateFilter.thisWeek:
        return 'This Week';
      case DateFilter.thisMonth:
        return 'This Month';
      case DateFilter.all:
        return 'All Time';
    }
  }
}

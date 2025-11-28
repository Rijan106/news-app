import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/news_service.dart';
import '../providers/theme_provider.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NewsService _newsService = NewsService();
  List<dynamic> _allNews = [];
  List<dynamic> _filteredNews = [];
  String _searchQuery = '';
  String _sortOrder = 'Newest';
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  final int _perPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchLatestNews();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
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
      final data = await _newsService.fetchPosts(
          forceRefresh: !loadMore, page: page, perPage: _perPage);

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

        // Check if we have more pages (if we got less than perPage, no more pages)
        _hasMorePages = data.length == _perPage;
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

  void _searchNews(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredNews = List.from(_allNews);
      } else {
        _filteredNews = _allNews.where((news) {
          final title =
              news['title']?['rendered']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase());
        }).toList();
      }
    });
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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Latest News',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _searchNews,
              ),
            ),
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
                        ? const Center(child: Text("No latest news available"))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                _filteredNews.length + (_isLoadingMore ? 1 : 0),
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
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../pages/detail_page.dart';
import '../services/news_service.dart';
import '../services/bookmarks_service.dart';
import '../providers/search_provider.dart';

class NewsListPage extends StatefulWidget {
  final int? categoryId;
  const NewsListPage({super.key, this.categoryId});

  @override
  State<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final NewsService _newsService = NewsService();
  final BookmarksService _bookmarksService = BookmarksService();
  List<dynamic> _allPosts = [];
  List<dynamic> _filteredPosts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMorePages = true;
  Set<int> _bookmarkedIds = {};
  bool _showAdvancedFilters = false;
  final TextEditingController _searchController = TextEditingController();
  final int _perPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  void _fetchPosts({bool loadMore = false}) {
    if (loadMore && !_hasMorePages) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _currentPage = 1;
        _allPosts.clear();
      }
    });

    final page = loadMore ? _currentPage + 1 : 1;
    _newsService
        .fetchPosts(
            categoryId: widget.categoryId, page: page, perPage: _perPage)
        .then((data) {
      if (mounted) {
        setState(() {
          if (loadMore) {
            _allPosts.addAll(data);
            _currentPage = page;
          } else {
            _allPosts = List.from(data);
          }
          _filteredPosts = List.from(_allPosts);
          _isLoading = false;
          _isLoadingMore = false;
          _hasMorePages = data.length == _perPage;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    });
  }

  void _loadMore() {
    _fetchPosts(loadMore: true);
  }

  Future<void> _refresh() async {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);

    // Show refresh indicator with custom message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Refreshing news...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }

    setState(() {
      _isLoading = true;
    });

    // Add artificial delay for better UX
    await Future.delayed(const Duration(milliseconds: 800));

    // Clear filters only if no active search
    if (searchProvider.searchQuery.isEmpty &&
        !searchProvider.hasActiveFilters) {
      searchProvider.clearFilters();
    }

    _fetchPosts();

    // Wait for fetch to complete
    await Future.delayed(const Duration(milliseconds: 500));

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('News updated successfully!'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _searchPosts(String query) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.updateSearchQuery(query);
    _applyFilters();
  }

  void _sortPosts(String order) {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    searchProvider.updateSortOrder(order);
    _applyFilters();
  }

  void _applyFilters() {
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    setState(() {
      _filteredPosts = List.from(_allPosts);

      // Apply search filter
      if (searchProvider.searchQuery.isNotEmpty) {
        _filteredPosts = _filteredPosts.where((post) {
          final title =
              post['title']?['rendered']?.toString().toLowerCase() ?? '';
          return title.contains(searchProvider.searchQuery.toLowerCase());
        }).toList();
      }

      // Apply category filter
      if (searchProvider.selectedCategory != 'All') {
        _filteredPosts = _filteredPosts.where((post) {
          final categories = post['_embedded']?['wp:term']?[0] ?? [];
          return categories
              .any((cat) => cat['name'] == searchProvider.selectedCategory);
        }).toList();
      }

      // Apply date range filter
      if (searchProvider.startDate != null || searchProvider.endDate != null) {
        _filteredPosts = _filteredPosts.where((post) {
          final postDate = post['date'] != null
              ? DateTime.parse(post['date'])
              : DateTime(2000);
          bool matches = true;

          if (searchProvider.startDate != null) {
            matches = matches && postDate.isAfter(searchProvider.startDate!);
          }
          if (searchProvider.endDate != null) {
            matches = matches && postDate.isBefore(searchProvider.endDate!);
          }

          return matches;
        }).toList();
      }

      // Apply sorting
      _filteredPosts.sort((a, b) {
        final dateA =
            a['date'] != null ? DateTime.parse(a['date']) : DateTime(2000);
        final dateB =
            b['date'] != null ? DateTime.parse(b['date']) : DateTime(2000);

        switch (searchProvider.sortOrder) {
          case 'Newest':
            return dateB.compareTo(dateA);
          case 'Oldest':
            return dateA.compareTo(dateB);
          case 'A-Z':
            final titleA =
                a['title']?['rendered']?.toString().toLowerCase() ?? '';
            final titleB =
                b['title']?['rendered']?.toString().toLowerCase() ?? '';
            return titleA.compareTo(titleB);
          case 'Most Popular':
            // Assuming we have a view count or similar metric
            return (b['views'] ?? 0).compareTo(a['views'] ?? 0);
          default:
            return dateB.compareTo(dateA);
        }
      });
    });
  }

  Future<void> _toggleBookmark(dynamic post) async {
    final articleId = post['id'];
    final isCurrentlyBookmarked = _bookmarkedIds.contains(articleId);

    if (isCurrentlyBookmarked) {
      await _bookmarksService.removeBookmark(articleId);
      setState(() {
        _bookmarkedIds.remove(articleId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from bookmarks')),
        );
      }
    } else {
      await _bookmarksService.addBookmark(post);
      setState(() {
        _bookmarkedIds.add(articleId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to bookmarks')),
        );
      }
    }
  }

  Widget _buildPostCard(dynamic post) {
    final title = post['title']?['rendered'] ?? 'No Title';
    final excerpt = post['excerpt']?['rendered'] ?? '';
    final date = post['date']?.toString().substring(0, 10) ?? '';
    final imageUrl = post['_embedded']?['wp:featuredmedia']?[0]?['source_url'];
    final articleId = post['id'];
    final isBookmarked = _bookmarkedIds.contains(articleId);

    return Dismissible(
      key: Key('article_$articleId'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: isBookmarked ? Colors.red : Colors.blue,
        child: Icon(
          isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
          color: Colors.white,
          size: 28,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.green,
        child: const Icon(
          Icons.share,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Left swipe - toggle bookmark
          await _toggleBookmark(post);
          return false; // Don't dismiss the item
        } else if (direction == DismissDirection.endToStart) {
          // Right swipe - share article
          await _shareArticle(post);
          return false; // Don't dismiss the item
        }
        return false;
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 2,
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailPage(post: post)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Article Image with Cached Network Image
                SizedBox(
                  width: 60,
                  height: 60,
                  child: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: Icon(
                                Icons.broken_image,
                                size: 30,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.5),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.article,
                            size: 30,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                // Article Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Date and Excerpt
                      Text(
                        date,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        excerpt.replaceAll(RegExp(r'<[^>]*>'), ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action Buttons
                Column(
                  children: [
                    // Bookmark Button
                    IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                      ),
                      onPressed: () => _toggleBookmark(post),
                      tooltip:
                          isBookmarked ? 'Remove bookmark' : 'Add bookmark',
                    ),

                    // Read More Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        textStyle: GoogleFonts.poppins(fontSize: 12),
                        elevation: 1,
                      ),
                      child: const Text('Read'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => DetailPage(post: post)),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareArticle(dynamic post) async {
    final title = post['title']?['rendered'] ?? 'No Title';
    final link = post['link'] ?? '';

    try {
      // Using the share_plus package for native sharing
      await Share.share(
        '$title\n\nRead more: $link',
      );
    } catch (e) {
      // Fallback to clipboard if share fails
      await Clipboard.setData(ClipboardData(text: '$title\n\n$link'));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article link copied to clipboard')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Column(
          children: [
            // Search and Sort Controls
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  // Search Field
                  TextField(
                    controller:
                        TextEditingController(text: searchProvider.searchQuery),
                    decoration: InputDecoration(
                      labelText: 'Search articles...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchPosts(''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: _searchPosts,
                  ),
                  const SizedBox(height: 8),

                  // Advanced Filters Toggle
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_showAdvancedFilters
                            ? Icons.expand_less
                            : Icons.expand_more),
                        onPressed: () {
                          setState(() {
                            _showAdvancedFilters = !_showAdvancedFilters;
                          });
                        },
                      ),
                      Text(
                        'Advanced Filters',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      const Spacer(),
                      if (searchProvider.hasActiveFilters)
                        TextButton(
                          onPressed: () {
                            searchProvider.clearFilters();
                            _applyFilters();
                          },
                          child: const Text('Clear All'),
                        ),
                    ],
                  ),

                  // Advanced Filters Panel
                  if (_showAdvancedFilters) ...[
                    const SizedBox(height: 8),
                    // Removed category filter from advanced filters as it does not show anything
                    // Row(
                    //   children: [
                    //     const Icon(Icons.category, size: 20),
                    //     const SizedBox(width: 8),
                    //     Text(
                    //       'Category:',
                    //       style: GoogleFonts.poppins(fontSize: 14),
                    //     ),
                    //     const SizedBox(width: 8),
                    //     Expanded(
                    //       child: DropdownButton<String>(
                    //         value: searchProvider.selectedCategory,
                    //         isExpanded: true,
                    //         items: searchProvider.availableCategories
                    //             .map((category) => DropdownMenuItem(
                    //                   value: category,
                    //                   child: Text(category),
                    //                 ))
                    //             .toList(),
                    //         onChanged: (value) {
                    //           if (value != null) {
                    //             searchProvider.updateCategory(value);
                    //             _applyFilters();
                    //           }
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.sort, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Sort by:',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: searchProvider.sortOrder,
                            isExpanded: true,
                            items: searchProvider.sortOptions
                                .map((option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(option),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) _sortPosts(value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.date_range, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Date Range:',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDateRange:
                                    searchProvider.startDate != null &&
                                            searchProvider.endDate != null
                                        ? DateTimeRange(
                                            start: searchProvider.startDate!,
                                            end: searchProvider.endDate!)
                                        : null,
                              );
                              if (picked != null) {
                                searchProvider.updateDateRange(
                                    picked.start, picked.end);
                                _applyFilters();
                              }
                            },
                            child: Text(
                              searchProvider.startDate != null &&
                                      searchProvider.endDate != null
                                  ? '${searchProvider.startDate!.toString().substring(0, 10)} - ${searchProvider.endDate!.toString().substring(0, 10)}'
                                  : 'Select Date Range',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // News List
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading news...',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredPosts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 48,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchProvider.searchQuery.isEmpty &&
                                          !searchProvider.hasActiveFilters
                                      ? 'No news available'
                                      : 'No articles match your filters',
                                  style: GoogleFonts.poppins(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _filteredPosts.length +
                                (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _filteredPosts.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              return _buildPostCard(_filteredPosts[index]);
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

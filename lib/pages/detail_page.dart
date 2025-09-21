import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:html_unescape/html_unescape.dart';
import '../services/bookmarks_service.dart';
import '../services/reading_history_service.dart';

class DetailPage extends StatefulWidget {
  final dynamic post;
  const DetailPage({super.key, required this.post});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final BookmarksService _bookmarksService = BookmarksService();
  final ReadingHistoryService _readingHistoryService = ReadingHistoryService();
  bool _isBookmarked = false;
  final ScrollController _scrollController = ScrollController();
  double _readingProgress = 0.0;
  bool _isLoadingProgress = true;
  final TextEditingController _commentController = TextEditingController();
  PdfControllerPinch? _pdfController;
  bool _isPdfLoading = false;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
    _loadReadingProgress();
    _scrollController.addListener(_updateReadingProgress);
    _addToReadingHistory();

    // Load PDF if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final htmlContent = widget.post['content']?['rendered'] as String? ?? '';
      final unescape = HtmlUnescape();
      final decodedContent = unescape.convert(htmlContent);
      final pdfUrls = _extractPdfUrls(decodedContent);
      if (pdfUrls.isNotEmpty) {
        _loadPdfController(pdfUrls[0]);
      }
    });
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkBookmarkStatus() async {
    final isBookmarked =
        await _bookmarksService.isBookmarked(widget.post['id']);
    if (mounted) {
      setState(() {
        _isBookmarked = isBookmarked;
      });
    }
  }

  Future<void> _addToReadingHistory() async {
    try {
      await _readingHistoryService.addToHistory(widget.post);
    } catch (e) {
      // Silently handle errors for reading history
      print('Error adding to reading history: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await _bookmarksService.removeBookmark(widget.post['id']);
      setState(() {
        _isBookmarked = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from bookmarks')),
        );
      }
    } else {
      await _bookmarksService.addBookmark(widget.post);
      setState(() {
        _isBookmarked = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to bookmarks')),
        );
      }
    }
  }

  Future<void> _shareArticle() async {
    final title = widget.post['title']?['rendered'] ?? 'No Title';
    final link = widget.post['link'] ?? '';
    final shareText = '$title\n\n$link';

    try {
      await Share.share(shareText);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to share article')),
        );
      }
    }
  }

  List<String> _extractPdfUrls(String htmlContent) {
    final List<String> pdfUrls = [];
    print('Extracting PDFs from HTML content...');
    print(
        'HTML Content sample: ${htmlContent.substring(0, min(500, htmlContent.length))}');

    // Look for iframe with class "pdfembed-iframe"
    final iframeRegex = RegExp(
        r'<iframe[^>]*class="[^"]*pdfembed-iframe[^"]*"[^>]*src="([^"]+)"[^>]*>',
        caseSensitive: false);

    final iframeMatches = iframeRegex.allMatches(htmlContent);
    print('Found ${iframeMatches.length} iframe matches');
    for (final match in iframeMatches) {
      final src = match.group(1);
      if (src != null) {
        print('Processing iframe src: $src');
        // Extract the actual PDF URL from the iframe src
        // Handle HTML entity encoding (&#038; = &)
        final decodedSrc = src.replaceAll('&#038;', '&');
        final urlRegex = RegExp(r'url=([^&]+)');
        final urlMatch = urlRegex.firstMatch(decodedSrc);
        if (urlMatch != null) {
          final pdfUrl = Uri.decodeFull(urlMatch.group(1)!);
          print('Extracted PDF URL from iframe: $pdfUrl');
          pdfUrls.add(pdfUrl);
        }
      }
    }

    // Also look for direct PDF links in anchor tags
    final pdfLinkRegex = RegExp(r'<a[^>]*href="([^"]*\.pdf[^"]*)"[^>]*>.*?</a>',
        caseSensitive: false);

    final pdfLinkMatches = pdfLinkRegex.allMatches(htmlContent);
    print('Found ${pdfLinkMatches.length} PDF link matches');
    for (final match in pdfLinkMatches) {
      final href = match.group(1);
      if (href != null) {
        print('Processing PDF link href: $href');
        final decodedHref = href.replaceAll('&#038;', '&');
        final pdfUrl = Uri.decodeFull(decodedHref);
        print('Extracted PDF URL from link: $pdfUrl');
        pdfUrls.add(pdfUrl);
      }
    }

    // Look for embedded PDF objects
    final objectRegex = RegExp(
      r'<object[^>]*data="([^"]*\.pdf[^"]*)"[^>]*>.*?</object>',
      caseSensitive: false,
    );

    final objectMatches = objectRegex.allMatches(htmlContent);
    print('Found ${objectMatches.length} object matches');
    for (final match in objectMatches) {
      final data = match.group(1);
      if (data != null) {
        print('Processing object data: $data');
        final decodedData = data.replaceAll('&#038;', '&');
        final pdfUrl = Uri.decodeFull(decodedData);
        print('Extracted PDF URL from object: $pdfUrl');
        pdfUrls.add(pdfUrl);
      }
    }

    // Look for any PDF URLs in the content (more general approach)
    final generalPdfRegex = RegExp(r'https?://.*?\.pdf', caseSensitive: false);

    final generalMatches = generalPdfRegex.allMatches(htmlContent);
    print('Found ${generalMatches.length} general PDF matches');
    for (final match in generalMatches) {
      final pdfUrl = match.group(0);
      if (pdfUrl != null) {
        print('Found general PDF URL: $pdfUrl');
        pdfUrls.add(pdfUrl);
      }
    }

    // Remove duplicates
    final uniqueUrls = pdfUrls.toSet().toList();
    print('Final unique PDF URLs: $uniqueUrls');
    return uniqueUrls;
  }

  Future<void> _openPdf(String pdfUrl) async {
    try {
      final uri = Uri.parse(pdfUrl);
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open PDF: $pdfUrl')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening PDF: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _loadPdfController(String pdfUrl) async {
    if (_pdfController != null) {
      _pdfController!.dispose();
    }

    setState(() {
      _isPdfLoading = true;
    });

    try {
      print('Loading PDF from URL: $pdfUrl');
      final response = await http.get(Uri.parse(pdfUrl));
      print('HTTP response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(response.bodyBytes),
        );
        setState(() {
          _isPdfLoading = false;
        });
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        _isPdfLoading = false;
      });
      throw Exception('Error loading PDF: $e');
    }
  }

  String _estimateReadingTime(String htmlContent) {
    // Remove HTML tags and count words
    final cleanText = htmlContent.replaceAll(RegExp(r'<[^>]*>'), '');
    final wordCount = cleanText.split(RegExp(r'\s+')).length;
    // Average reading speed: 200 words per minute
    final minutes = (wordCount / 200).ceil();
    return '${minutes} min read';
  }

  Future<void> _loadReadingProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final articleId = widget.post['id'].toString();
      final savedProgress =
          prefs.getDouble('reading_progress_$articleId') ?? 0.0;

      if (mounted) {
        setState(() {
          _readingProgress = savedProgress;
          _isLoadingProgress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProgress = false;
        });
      }
    }
  }

  void _updateReadingProgress() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll > 0) {
      final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);

      if (mounted && progress != _readingProgress) {
        setState(() {
          _readingProgress = progress;
        });

        // Save progress to SharedPreferences
        _saveReadingProgress(progress);
      }
    }
  }

  Future<void> _saveReadingProgress(double progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final articleId = widget.post['id'].toString();
      await prefs.setDouble('reading_progress_$articleId', progress);
    } catch (e) {
      // Silently handle save errors
    }
  }

  Widget _buildReadingProgressBar() {
    if (_isLoadingProgress) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _readingProgress,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF59151E),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        widget.post["_embedded"]?["wp:featuredmedia"]?[0]?["source_url"];
    final rawHtmlContent = widget.post['content']?['rendered'] as String? ?? '';

    // Debug: Print raw content
    print('Raw HTML Content: $rawHtmlContent');
    print('Raw HTML Content length: ${rawHtmlContent.length}');

    final unescape = HtmlUnescape();
    final htmlContent = unescape.convert(rawHtmlContent);

    // Debug: Print decoded content
    print('Decoded HTML Content: $htmlContent');
    print('Decoded HTML Content length: ${htmlContent.length}');
    print('Is htmlContent empty: ${htmlContent.isEmpty}');

    final pdfUrls = _extractPdfUrls(htmlContent);

    // Debug: Print found PDF URLs
    print('HTML Content length: ${htmlContent.length}');
    print('Found PDF URLs: $pdfUrls');
    print('PDF URLs count: ${pdfUrls.length}');

    // Additional debug: Check if PDF viewer should be shown
    print('Should show PDF viewer: ${pdfUrls.isNotEmpty}');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.post['title']?['rendered'] ?? 'No Title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF59151E),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: _toggleBookmark,
            tooltip: _isBookmarked ? 'Remove bookmark' : 'Add bookmark',
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareArticle,
            tooltip: 'Share article',
          ),
        ],
      ),
      body: Column(
        children: [
          // Reading Progress Bar
          _buildReadingProgressBar(),

          // Article Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null)
                    Container(
                      width: double.infinity,
                      height: 250,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    widget.post['title']?['rendered'] ?? 'No Title',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Article metadata
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        widget.post['date']?.toString().substring(0, 10) ?? '',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _estimateReadingTime(htmlContent),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      ),
                      const Spacer(),
                      // Reading Progress Indicator
                      if (!_isLoadingProgress)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF59151E).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(_readingProgress * 100).round()}%',
                            style: TextStyle(
                              color: const Color(0xFF59151E),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  htmlContent.isEmpty
                      ? Center(
                          child: Text(
                            'No content available',
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 16),
                          ),
                        )
                      : Html(
                          data: htmlContent,
                          style: {
                            "body": Style(
                              fontSize: FontSize(16),
                              lineHeight: LineHeight(1.6),
                              color: Colors.black87,
                            ),
                            "h1": Style(
                              fontSize: FontSize(24),
                              fontWeight: FontWeight.bold,
                              margin: Margins.only(bottom: 16),
                              color: Colors.black87,
                            ),
                            "h2": Style(
                              fontSize: FontSize(20),
                              fontWeight: FontWeight.bold,
                              margin: Margins.only(bottom: 12),
                              color: Colors.black87,
                            ),
                            "p": Style(
                              margin: Margins.only(bottom: 12),
                              color: Colors.black87,
                            ),
                            "img": Style(
                              margin: Margins.only(bottom: 12),
                              display: Display.block,
                              width: Width(100, Unit.percent),
                              height: Height.auto(),
                              alignment: Alignment.center,
                            ),
                          },
                          onLinkTap: (url, attributes, element) {
                            if (url == null) return;

                            final uri = Uri.parse(url);

                            // Check if this is a PDF link - if so, don't open externally
                            if (url.toLowerCase().contains('.pdf')) {
                              // PDF links are handled by the inline PDF viewer below
                              // Don't open them externally
                              return;
                            }

                            // Open other links in external browser
                            canLaunchUrl(uri).then((canLaunch) {
                              if (canLaunch) {
                                launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                // Could not launch URL
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Could not launch $uri')),
                                );
                              }
                            });
                          },
                        ),
                  const SizedBox(height: 16),
                  // PDF Viewer Section
                  if (pdfUrls.isNotEmpty) ...[
                    Container(
                      height: 400,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.picture_as_pdf,
                                  color: Colors.red.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'PDF Documents',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.open_in_new,
                                    color: Colors.red.shade600),
                                onPressed: () => _openPdf(pdfUrls[0]),
                                tooltip: 'Open PDF in external browser',
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _isPdfLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _pdfController != null
                                    ? PdfViewPinch(
                                        controller: _pdfController!,
                                      )
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error,
                                                color: Colors.red, size: 48),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Failed to load PDF',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            const SizedBox(height: 8),
                                            OutlinedButton.icon(
                                              onPressed: () =>
                                                  _openPdf(pdfUrls[0]),
                                              icon: Icon(Icons.open_in_new,
                                                  size: 18),
                                              label: const Text('Open in App'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Comments Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.comment, color: const Color(0xFF59151E)),
                            const SizedBox(width: 8),
                            Text(
                              'Comments',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF59151E),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Comments disabled due to Firebase compatibility issues
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Center(
                            child: Text(
                              'Comments are currently disabled',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

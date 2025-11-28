import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String? title;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late PdfControllerPinch _pdfController;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _totalPages = 0;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      print('Loading PDF from URL: ${widget.pdfUrl}');

      // Fetch PDF data from URL
      final response = await http.get(Uri.parse(widget.pdfUrl));

      if (response.statusCode == 200) {
        // Create PDF controller from bytes
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openData(response.bodyBytes),
        );

        // Get total pages
        _totalPages = await _pdfController.pagesCount ?? 0;

        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load PDF: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 1) {
      _pdfController.previousPage(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _goToNextPage() {
    if (_currentPage < _totalPages) {
      _pdfController.nextPage(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  void _goToPage(int page) {
    _pdfController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.pdfUrl.split('/').last.split('?').first;
    final displayTitle = widget.title ?? fileName;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PDF Viewer',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            Text(
              displayTitle.length > 30
                  ? '${displayTitle.substring(0, 27)}...'
                  : displayTitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF59151E),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _loadPdf,
            tooltip: 'Reload PDF',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingView()
          : _hasError
              ? _buildErrorView()
              : _buildPdfView(),
      bottomNavigationBar: _totalPages > 0 ? _buildBottomNavigationBar() : null,
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF59151E),
            ),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(
                color: Color(0xFF59151E),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load PDF',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPdf,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF59151E),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfView() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: PdfViewPinch(
        controller: _pdfController,
        onDocumentLoaded: (document) {
          print('PDF loaded with ${document.pagesCount} pages');
        },
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        scrollDirection: Axis.vertical,
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          // Previous page button
          IconButton(
            onPressed: _currentPage > 1 ? _goToPreviousPage : null,
            icon: Icon(
              Icons.navigate_before,
              color: _currentPage > 1
                  ? const Color(0xFF59151E)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            tooltip: 'Previous page',
          ),

          // Page indicator
          Expanded(
            child: Center(
              child: Text(
                '$_currentPage / $_totalPages',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),

          // Next page button
          IconButton(
            onPressed: _currentPage < _totalPages ? _goToNextPage : null,
            icon: Icon(
              Icons.navigate_next,
              color: _currentPage < _totalPages
                  ? const Color(0xFF59151E)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            tooltip: 'Next page',
          ),
        ],
      ),
    );
  }
}

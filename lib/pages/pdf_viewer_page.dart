import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentViewId;
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _initializePdfViewer();
  }

  void _initializePdfViewer() async {
    try {
      // Handle encoded URLs (like those with pdfID parameter)
      String actualPdfUrl = widget.pdfUrl;
      if (widget.pdfUrl.contains('pdfID=') && widget.pdfUrl.contains('url=')) {
        final uri = Uri.parse(widget.pdfUrl);
        final urlParam = uri.queryParameters['url'];
        if (urlParam != null) {
          actualPdfUrl = Uri.decodeComponent(urlParam);
        }
      }

      // Download the PDF to local storage for in-app viewing
      final response = await http.get(Uri.parse(actualPdfUrl));
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final fileName = path.basename(Uri.parse(actualPdfUrl).path);
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _pdfPath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load PDF: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF59151E),
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF59151E),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_browser, color: Colors.white),
              onPressed: () async {
                // Handle encoded URLs (like those with pdfID parameter)
                String actualPdfUrl = widget.pdfUrl;
                if (widget.pdfUrl.contains('pdfID=') &&
                    widget.pdfUrl.contains('url=')) {
                  final uri = Uri.parse(widget.pdfUrl);
                  final urlParam = uri.queryParameters['url'];
                  if (urlParam != null) {
                    actualPdfUrl = Uri.decodeComponent(urlParam);
                  }
                }

                // Open PDF in external browser
                final Uri url = Uri.parse(actualPdfUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Could not open PDF')),
                    );
                  }
                }
              },
              tooltip: 'Open in browser',
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading PDF',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open in Browser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF59151E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    // Handle encoded URLs (like those with pdfID parameter)
                    String actualPdfUrl = widget.pdfUrl;
                    if (widget.pdfUrl.contains('pdfID=') &&
                        widget.pdfUrl.contains('url=')) {
                      final uri = Uri.parse(widget.pdfUrl);
                      final urlParam = uri.queryParameters['url'];
                      if (urlParam != null) {
                        actualPdfUrl = Uri.decodeComponent(urlParam);
                      }
                    }

                    // Open PDF in external browser
                    final Uri url = Uri.parse(actualPdfUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open PDF')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF59151E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: () async {
              // Handle encoded URLs (like those with pdfID parameter)
              String actualPdfUrl = widget.pdfUrl;
              if (widget.pdfUrl.contains('pdfID=') &&
                  widget.pdfUrl.contains('url=')) {
                final uri = Uri.parse(widget.pdfUrl);
                final urlParam = uri.queryParameters['url'];
                if (urlParam != null) {
                  actualPdfUrl = Uri.decodeComponent(urlParam);
                }
              }

              // Open PDF in external browser
              final Uri url = Uri.parse(actualPdfUrl);
              if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open PDF')),
                  );
                }
              }
            },
            tooltip: 'Open in browser',
          ),
        ],
      ),
      body: PDFView(
        filePath: _pdfPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        fitPolicy: FitPolicy.WIDTH,
        onRender: (_pages) {
          setState(() {
            _isLoading = false;
          });
        },
        onError: (error) {
          setState(() {
            _errorMessage = error.toString();
          });
        },
        onPageError: (page, error) {
          setState(() {
            _errorMessage = 'Error on page $page: $error';
          });
        },
        onViewCreated: (PDFViewController pdfViewController) {
          // You can use the controller to control the PDF view
        },
      ),
    );
  }
}

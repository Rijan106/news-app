// Debug test to understand why deduplication isn't working
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PDF Deduplication Debug', () {
    test('Debug URL normalization with fixed logic', () {
      // Test the normalization logic
      const url1 =
          'https://gurubaa.com?pdfID=26004&url=https%3A%2F%2Fgurubaa.com%2Fwp-content%2Fuploads%2F2025%2F09%2FResult-of-BBM-5th-Sem-2025_0001.pdf';
      const url2 =
          'https://gurubaa.com/wp-content/uploads/2025/09/Result-of-BBM-5th-Sem-2025_0001.pdf';

      print('URL 1: $url1');
      print('URL 2: $url2');

      // Test normalization with fixed logic
      final normalized1 = _normalizePdfUrl(url1);
      final normalized2 = _normalizePdfUrl(url2);

      print('Normalized 1: $normalized1');
      print('Normalized 2: $normalized2');
      print('Are they equal? ${normalized1 == normalized2}');

      // Test encoded URL extraction
      if (url1.contains('pdfID=') && url1.contains('url=')) {
        final urlParam = Uri.parse(url1).queryParameters['url'];
        if (urlParam != null) {
          final decodedUrl = Uri.decodeFull(urlParam);
          print('Decoded URL from URL1: $decodedUrl');
          final normalizedDecoded = _normalizePdfUrl(decodedUrl);
          print('Normalized decoded: $normalizedDecoded');
          print('Matches URL2? ${normalizedDecoded == normalized2}');
        }
      }

      // Test deduplication logic
      final urls = [url1, url2];
      final deduplicated = _removeDuplicatePdfs(urls);
      print('Original URLs: $urls');
      print('Deduplicated URLs: $deduplicated');
      print('Deduplication successful: ${deduplicated.length == 1}');
    });
  });
}

List<String> _removeDuplicatePdfs(List<String> pdfUrls) {
  if (pdfUrls.isEmpty) return pdfUrls;

  final normalizedUrls = <String, String>{};

  for (final url in pdfUrls) {
    // Normalize URL by removing query parameters and fragments
    final normalizedUrl = _normalizePdfUrl(url);

    // For encoded URLs, also check the decoded version
    if (url.contains('pdfID=') && url.contains('url=')) {
      try {
        final urlParam = Uri.parse(url).queryParameters['url'];
        if (urlParam != null) {
          final decodedUrl = Uri.decodeFull(urlParam);
          final normalizedDecoded = _normalizePdfUrl(decodedUrl);
          normalizedUrls[normalizedDecoded] = url; // Keep original encoded URL
        }
      } catch (e) {
        print('Error normalizing encoded PDF URL: $e');
      }
    }

    // Store the normalized URL with the original as value
    normalizedUrls[normalizedUrl] = url;
  }

  return normalizedUrls.values.toList();
}

String _normalizePdfUrl(String url) {
  try {
    final uri = Uri.parse(url);
    // Remove query parameters and fragments for comparison
    final normalized = uri.replace(
      queryParameters: {},
      fragment: '',
    ).toString();

    // Clean up the URL by removing trailing ? or # if they exist
    String cleanUrl = normalized;
    if (cleanUrl.endsWith('?') || cleanUrl.endsWith('#')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }

    return cleanUrl;
  } catch (e) {
    // If URL parsing fails, return as-is
    return url;
  }
}

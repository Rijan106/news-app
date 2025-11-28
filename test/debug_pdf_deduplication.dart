// Debug test to understand why deduplication isn't working
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PDF Deduplication Debug', () {
    test('Debug URL normalization', () {
      // Test the normalization logic
      const url1 =
          'https://gurubaa.com?pdfID=26004&url=https%3A%2F%2Fgurubaa.com%2Fwp-content%2Fuploads%2F2025%2F09%2FResult-of-BBM-5th-Sem-2025_0001.pdf';
      const url2 =
          'https://gurubaa.com/wp-content/uploads/2025/09/Result-of-BBM-5th-Sem-2025_0001.pdf';

      print('URL 1: $url1');
      print('URL 2: $url2');

      // Test normalization
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
    });
  });
}

String _normalizePdfUrl(String url) {
  try {
    final uri = Uri.parse(url);
    // Remove query parameters and fragments for comparison
    final normalized = uri.replace(
      queryParameters: {},
      fragment: '',
    ).toString();
    return normalized;
  } catch (e) {
    // If URL parsing fails, return as-is
    return url;
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video_model.dart';
import '../config/api_config.dart';

class VideoService {
  static const Duration _timeoutDuration = Duration(seconds: 15);
  static const int _maxRetries = 3;

  final http.Client _client;

  VideoService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch all videos from a specific YouTube playlist
  Future<List<VideoModel>> fetchPlaylistVideos(String playlistId) async {
    List<VideoModel> allVideos = [];
    String? nextPageToken;
    int attempt = 0;

    do {
      while (attempt < _maxRetries) {
        try {
          final url = Uri.parse(
            '${ApiConfig.youtubeApiBaseUrl}/playlistItems'
            '?part=snippet'
            '&maxResults=50'
            '&playlistId=$playlistId'
            '&key=${ApiConfig.youtubeApiKey}'
            '${nextPageToken != null ? '&pageToken=$nextPageToken' : ''}',
          );

          final response = await _client.get(url).timeout(_timeoutDuration);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final items = data['items'] as List? ?? [];

            final videos = items
                .map((item) => VideoModel.fromJson(item))
                .where((video) => video.videoId.isNotEmpty)
                .toList();

            allVideos.addAll(videos);

            // Check if there are more pages
            nextPageToken = data['nextPageToken'];
            attempt = 0; // Reset attempt counter for next page
            break; // Break retry loop, continue to next page
          } else if (response.statusCode == 403) {
            throw Exception(
                'API quota exceeded or invalid API key. Please check your YouTube API settings.');
          } else if (response.statusCode == 404) {
            throw Exception('Playlist not found');
          } else {
            throw Exception('Failed to load videos: ${response.statusCode}');
          }
        } on TimeoutException catch (_) {
          attempt++;
          if (attempt >= _maxRetries) {
            throw Exception('Request timed out after $_maxRetries attempts');
          }
        } catch (e) {
          if (attempt >= _maxRetries - 1) {
            rethrow;
          }
          attempt++;
        }
      }
    } while (nextPageToken != null);

    return allVideos;
  }

  /// Fetch playlists from a YouTube channel
  Future<List<Map<String, dynamic>>> fetchChannelPlaylists(
      String channelId) async {
    int attempt = 0;
    while (attempt < _maxRetries) {
      try {
        final url = Uri.parse(
          '${ApiConfig.youtubeApiBaseUrl}/playlists'
          '?part=snippet,contentDetails'
          '&channelId=$channelId'
          '&maxResults=50'
          '&key=${ApiConfig.youtubeApiKey}',
        );

        final response = await _client.get(url).timeout(_timeoutDuration);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final items = data['items'] as List? ?? [];
          final processedPlaylists = <Map<String, dynamic>>[];

          // Process playlists sequentially to avoid API rate limiting (429/403 errors)
          // Making parallel requests triggers YouTube's spam/quota protection
          for (final item in items) {
            final snippet = item['snippet'] ?? {};
            final contentDetails = item['contentDetails'] ?? {};
            final playlistId = item['id'] ?? '';

            // Get standard thumbnail first
            String thumbnailUrl = snippet['thumbnails']?['maxres']?['url'] ??
                snippet['thumbnails']?['high']?['url'] ??
                snippet['thumbnails']?['medium']?['url'] ??
                snippet['thumbnails']?['default']?['url'] ??
                '';

            // Try to fetch the first video's thumbnail for a better cover image
            // Only if we have a valid playlist ID
            if (playlistId.isNotEmpty) {
              try {
                final videoThumb = await fetchPlaylistCoverImage(playlistId);
                // Only replace if we got a valid high-quality thumbnail
                if (videoThumb != null && videoThumb.isNotEmpty) {
                  thumbnailUrl = videoThumb;
                }
              } catch (e) {
                // Ignore error, keep original thumbnail
                print('Error fetching cover for playlist $playlistId: $e');
              }
            }

            processedPlaylists.add({
              'id': playlistId,
              'title': snippet['title'] ?? 'Untitled Playlist',
              'description': snippet['description'] ?? '',
              'thumbnailUrl': thumbnailUrl,
              'videoCount': contentDetails['itemCount'] ?? 0,
            });
          }

          return processedPlaylists;
        } else if (response.statusCode == 403) {
          throw Exception(
              'API quota exceeded or invalid API key. Please check your YouTube API settings.');
        } else {
          throw Exception('Failed to load playlists: ${response.statusCode}');
        }
      } on TimeoutException catch (_) {
        attempt++;
        if (attempt >= _maxRetries) {
          throw Exception('Request timed out after $_maxRetries attempts');
        }
      } catch (e) {
        if (attempt >= _maxRetries - 1) {
          rethrow;
        }
        attempt++;
      }
    }
    throw Exception('Failed to load playlists after $_maxRetries attempts');
  }

  /// Fetch the thumbnail of the first video in a playlist
  Future<String?> fetchPlaylistCoverImage(String playlistId) async {
    try {
      final url = Uri.parse(
        '${ApiConfig.youtubeApiBaseUrl}/playlistItems'
        '?part=snippet'
        '&maxResults=1'
        '&playlistId=$playlistId'
        '&key=${ApiConfig.youtubeApiKey}',
      );

      final response = await _client.get(url).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];

        if (items.isNotEmpty) {
          final snippet = items.first['snippet'] ?? {};
          final resourceId = snippet['resourceId'] ?? {};
          final videoId = resourceId['videoId'];

          if (videoId != null && videoId.toString().isNotEmpty) {
            // Construct high-quality thumbnail URL directly from video ID
            return 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';
          }

          final thumbnails = snippet['thumbnails'] ?? {};
          return thumbnails['maxres']?['url'] ??
              thumbnails['high']?['url'] ??
              thumbnails['medium']?['url'] ??
              thumbnails['default']?['url'];
        }
      }
    } catch (e) {
      // Ignore errors for cover image fetch
    }
    return null;
  }

  void dispose() {
    _client.close();
  }
}

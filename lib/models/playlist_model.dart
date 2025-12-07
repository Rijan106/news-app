class PlaylistModel {
  final String title;
  final int videoCount;
  final String playlistId;
  final String playlistUrl;
  final String thumbnailUrl;

  PlaylistModel({
    required this.title,
    required this.videoCount,
    required this.playlistId,
    required this.playlistUrl,
    this.thumbnailUrl = '',
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      title: json['title'] ?? '',
      videoCount: json['videoCount'] ?? 0,
      playlistId: json['playlistId'] ?? '',
      playlistUrl: json['playlistUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'videoCount': videoCount,
      'playlistId': playlistId,
      'playlistUrl': playlistUrl,
      'thumbnailUrl': thumbnailUrl,
    };
  }

  // Extract playlist ID from YouTube URL
  static String? extractPlaylistId(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters['yt_playlist'];
  }

  // Get YouTube playlist URL
  String get youtubeUrl => 'https://www.youtube.com/playlist?list=$playlistId';
}

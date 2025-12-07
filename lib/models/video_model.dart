class VideoModel {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String publishedAt;
  final int position;

  VideoModel({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.publishedAt,
    required this.position,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] ?? {};
    final resourceId = snippet['resourceId'] ?? {};

    return VideoModel(
      videoId: resourceId['videoId'] ?? '',
      title: snippet['title'] ?? 'Untitled Video',
      description: snippet['description'] ?? '',
      thumbnailUrl: snippet['thumbnails']?['medium']?['url'] ??
          snippet['thumbnails']?['default']?['url'] ??
          '',
      publishedAt: snippet['publishedAt'] ?? '',
      position: snippet['position'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'publishedAt': publishedAt,
      'position': position,
    };
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';
}

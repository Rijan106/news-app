import '../models/playlist_model.dart';
import '../services/video_service.dart';
import '../config/api_config.dart';

class PlaylistService {
  final VideoService _videoService;

  PlaylistService({VideoService? videoService})
      : _videoService = videoService ?? VideoService();

  Future<List<PlaylistModel>> fetchPlaylists() async {
    try {
      // Fetch playlists from YouTube API
      final playlistsData =
          await _videoService.fetchChannelPlaylists(ApiConfig.gurubaaChannelId);

      return playlistsData.map((data) {
        return PlaylistModel(
          title: data['title'] as String,
          videoCount: data['videoCount'] as int,
          playlistId: data['id'] as String,
          playlistUrl: 'https://www.youtube.com/playlist?list=${data['id']}',
          thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      // If API fails, return hardcoded playlists as fallback
      // But we should try to fetch their thumbnails!
      final fallbackPlaylists = _getHardcodedPlaylists();

      // Try to fetch thumbnails for the fallback playlists
      final playlistsWithThumbs = await Future.wait(
        fallbackPlaylists.map((playlist) async {
          try {
            final thumbUrl = await _videoService
                .fetchPlaylistCoverImage(playlist.playlistId);
            if (thumbUrl != null && thumbUrl.isNotEmpty) {
              return PlaylistModel(
                title: playlist.title,
                videoCount: playlist.videoCount,
                playlistId: playlist.playlistId,
                playlistUrl: playlist.playlistUrl,
                thumbnailUrl: thumbUrl,
              );
            }
          } catch (e) {
            // Ignore error
          }
          return playlist;
        }),
      );

      return playlistsWithThumbs;
    }
  }

  List<PlaylistModel> _getHardcodedPlaylists() {
    // Fallback playlists in case API fails
    return [
      PlaylistModel(
        title: 'The Gurubaa Podcast',
        videoCount: 9,
        playlistId: 'PLbYn2hpzIrSj7HgJHXX3ePBeTxX4z1WLM',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSj7HgJHXX3ePBeTxX4z1WLM',
      ),
      PlaylistModel(
        title: 'Class 12 Chemistry in Nepali NEB',
        videoCount: 18,
        playlistId: 'PLbYn2hpzIrSiFf3Y880mmec-vllkLvRrS',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSiFf3Y880mmec-vllkLvRrS',
      ),
      PlaylistModel(
        title: 'Business Law BBS 3rd Year in Nepali/ English',
        videoCount: 2,
        playlistId: 'PLbYn2hpzIrSjWsmV7jv9ELyK0nCivJdz6',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSjWsmV7jv9ELyK0nCivJdz6',
      ),
      PlaylistModel(
        title: 'Japanese Language in Nepali (जापानी भाषा कक्षा)',
        videoCount: 51,
        playlistId: 'PLbYn2hpzIrShzOppKOKiLM2yjAIpko4zA',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrShzOppKOKiLM2yjAIpko4zA',
      ),
      PlaylistModel(
        title: 'BBS 1st Year Statistics in Nepali',
        videoCount: 29,
        playlistId: 'PLbYn2hpzIrSj5tMgtbPu2MPRWZk9K2bWv',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSj5tMgtbPu2MPRWZk9K2bWv',
      ),
      PlaylistModel(
        title: 'Class 10 Science in Nepali (ALL Chapters) SEE Exam',
        videoCount: 17,
        playlistId: 'PLbYn2hpzIrShqF68mrYKtSyHzc7Z742cw',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrShqF68mrYKtSyHzc7Z742cw',
      ),
      PlaylistModel(
        title: 'Class 10 Economics in Nepali (SEE Exam)',
        videoCount: 13,
        playlistId: 'PLbYn2hpzIrSjEXp1vycLnt_ogS3IDh1Cu',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSjEXp1vycLnt_ogS3IDh1Cu',
      ),
      PlaylistModel(
        title: 'Class 10 English (New Syllabus) for SEE Exam',
        videoCount: 15,
        playlistId: 'PLbYn2hpzIrSiTnNMLJCdzkvc28D4mcrJa',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSiTnNMLJCdzkvc28D4mcrJa',
      ),
      PlaylistModel(
        title: 'Class 10 Mathematics in Nepali (New Syllabus)',
        videoCount: 29,
        playlistId: 'PLbYn2hpzIrSiYOuBFbjbnw8ud4blIOzte',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSiYOuBFbjbnw8ud4blIOzte',
      ),
      PlaylistModel(
        title: 'Class 10 Social Studies (कक्षा १० सामाजिक अध्ययन) SEE',
        videoCount: 11,
        playlistId: 'PLbYn2hpzIrShJGmD4qK_6mw40bffEo-4u',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrShJGmD4qK_6mw40bffEo-4u',
      ),
      PlaylistModel(
        title: 'Class 10 Nepali (कक्षा १० नेपाली)',
        videoCount: 15,
        playlistId: 'PLbYn2hpzIrSgCCnjhrZCuZ2tQZDXRcxvf',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSgCCnjhrZCuZ2tQZDXRcxvf',
      ),
      PlaylistModel(
        title: 'Grade 12 Accountancy in Nepali(HSEB/NEB)',
        videoCount: 91,
        playlistId: 'PLbYn2hpzIrSjZ7MDunfMgcWBWRbbtQioC',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSjZ7MDunfMgcWBWRbbtQioC',
      ),
      PlaylistModel(
        title: 'Grade 12 Economics in Nepali(NEB)',
        videoCount: 52,
        playlistId: 'PLbYn2hpzIrSiNS5G4kIMlt7d9LJlxZIyu',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSiNS5G4kIMlt7d9LJlxZIyu',
      ),
      PlaylistModel(
        title: 'Class 12 Physics',
        videoCount: 121,
        playlistId: 'PLbYn2hpzIrSh59Q4z3CHBb7Xgq24S_Jmz',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSh59Q4z3CHBb7Xgq24S_Jmz',
      ),
      PlaylistModel(
        title: 'Class 12 English',
        videoCount: 48,
        playlistId: 'PLbYn2hpzIrSitBD05FFMWYqbbTWR9SkJb',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSitBD05FFMWYqbbTWR9SkJb',
      ),
      PlaylistModel(
        title: 'Class 11 English',
        videoCount: 32,
        playlistId: 'PLbYn2hpzIrShm69wRNVMFnxThMkcsQI9H',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrShm69wRNVMFnxThMkcsQI9H',
      ),
      PlaylistModel(
        title: 'BBS 2nd Year Accountancy',
        videoCount: 27,
        playlistId: 'PLbYn2hpzIrSgN7gJ7ucG7eTkjMbzaT5QW',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrSgN7gJ7ucG7eTkjMbzaT5QW',
      ),
      PlaylistModel(
        title: 'SEE Class 10 Mathematics in Nepali Full Course Cover',
        videoCount: 44,
        playlistId: 'PLbYn2hpzIrShdfXv4CtE8kLXFRa3cuCWW',
        playlistUrl:
            'https://www.youtube.com/playlist?list=PLbYn2hpzIrShdfXv4CtE8kLXFRa3cuCWW',
      ),
    ];
  }
}

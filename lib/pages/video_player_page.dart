import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../services/video_quality_service.dart';
import '../widgets/quality_selector_dialog.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoId;
  final String videoTitle;
  final String playlistId;

  const VideoPlayerPage({
    super.key,
    required this.videoId,
    required this.videoTitle,
    required this.playlistId,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final VideoService _videoService = VideoService();
  final VideoQualityService _qualityService = VideoQualityService();
  late YoutubePlayerController _controller;
  List<VideoModel> _playlistVideos = [];
  bool _isLoadingPlaylist = false;
  bool _showPlaylist = false;
  String _currentQuality = VideoQualityService.qualityAuto;

  @override
  void initState() {
    super.initState();
    _loadQualityPreference();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  Future<void> _loadQualityPreference() async {
    final quality = await _qualityService.getQualityPreference();
    setState(() {
      _currentQuality = quality;
    });
  }

  Future<void> _showQualitySelector() async {
    final selectedQuality = await showDialog<String>(
      context: context,
      builder: (context) => QualitySelectorDialog(
        currentQuality: _currentQuality,
      ),
    );

    if (selectedQuality != null && selectedQuality != _currentQuality) {
      await _qualityService.saveQualityPreference(selectedQuality);
      setState(() {
        _currentQuality = selectedQuality;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quality set to ${VideoQualityService.getQualityLabel(selectedQuality)}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoService.dispose();
    super.dispose();
  }

  Future<void> _loadPlaylistVideos() async {
    if (_playlistVideos.isNotEmpty) {
      setState(() {
        _showPlaylist = !_showPlaylist;
      });
      return;
    }

    setState(() {
      _isLoadingPlaylist = true;
      _showPlaylist = true;
    });

    try {
      final videos = await _videoService.fetchPlaylistVideos(widget.playlistId);
      if (mounted) {
        setState(() {
          _playlistVideos = videos;
          _isLoadingPlaylist = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPlaylist = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading playlist: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openVideo(VideoModel video) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerPage(
          videoId: video.videoId,
          videoTitle: video.title,
          playlistId: widget.playlistId,
        ),
      ),
    );
  }

  Widget _buildPlaylistVideoCard(VideoModel video, int index) {
    final isCurrentVideo = video.videoId == widget.videoId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isCurrentVideo ? 4 : 2,
      color: isCurrentVideo
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isCurrentVideo
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isCurrentVideo ? null : () => _openVideo(video),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCurrentVideo
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 100,
                height: 56,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: video.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 30,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                      if (!isCurrentVideo)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      if (isCurrentVideo)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                            isCurrentVideo ? FontWeight.w600 : FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    if (isCurrentVideo)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.play_circle_filled,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Now Playing',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (!isCurrentVideo)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.videoTitle,
              style: const TextStyle(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Theme.of(context).primaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // Quality selector button
              IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.settings, color: Colors.white),
                    if (_currentQuality != VideoQualityService.qualityAuto)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            VideoQualityService.getQualityLabel(_currentQuality)
                                .replaceAll('p', ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                tooltip: 'Video Quality',
                onPressed: _showQualitySelector,
              ),
            ],
          ),
          body: Column(
            children: [
              player,
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.videoTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Description',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Watch this educational video from Gurubaa. Learn at your own pace with high-quality content designed for students.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.8),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _loadPlaylistVideos,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.playlist_play,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _showPlaylist
                                        ? 'Hide Playlist Videos'
                                        : 'Show Playlist Videos',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _showPlaylist
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_showPlaylist)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isLoadingPlaylist)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              else if (_playlistVideos.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        'Playlist Videos (${_playlistVideos.length})',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ..._playlistVideos
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      return _buildPlaylistVideoCard(
                                        entry.value,
                                        entry.key,
                                      );
                                    }),
                                  ],
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

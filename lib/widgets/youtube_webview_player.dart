import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubeWebViewPlayer extends StatefulWidget {
  final String videoId;
  final double aspectRatio;
  final bool autoPlay;

  const YouTubeWebViewPlayer({
    super.key,
    required this.videoId,
    this.aspectRatio = 16 / 9,
    this.autoPlay = false,
  });

  @override
  State<YouTubeWebViewPlayer> createState() => _YouTubeWebViewPlayerState();
}

class _YouTubeWebViewPlayerState extends State<YouTubeWebViewPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: widget.autoPlay,
        mute: false,
        enableCaption: true,
        controlsVisibleAtStart: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        onReady: () {
          debugPrint('YouTube player ready');
        },
        onEnded: (data) {
          debugPrint('Video ended');
        },
      ),
      builder: (context, player) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: player,
          ),
        );
      },
    );
  }
}

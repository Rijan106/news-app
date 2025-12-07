import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/playlist_service.dart';
import '../models/playlist_model.dart';
import 'playlist_videos_page.dart';

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  State<PlaylistPage> createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final PlaylistService _playlistService = PlaylistService();
  List<PlaylistModel> _allPlaylists = [];
  List<PlaylistModel> _filteredPlaylists = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPlaylists();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPlaylists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final playlists = await _playlistService.fetchPlaylists();
      if (mounted) {
        setState(() {
          _allPlaylists = playlists;
          _filteredPlaylists = playlists;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading playlists: $e')),
        );
      }
    }
  }

  Future<void> _refresh() async {
    await _fetchPlaylists();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Playlists updated successfully!'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _searchPlaylists(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPlaylists = _allPlaylists;
      } else {
        _filteredPlaylists = _allPlaylists
            .where((playlist) =>
                playlist.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _openPlaylist(PlaylistModel playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistVideosPage(playlist: playlist),
      ),
    );
  }

  Widget _buildPlaylistCard(PlaylistModel playlist) {
    // Use thumbnail from API if available
    final thumbnailUrl = playlist.thumbnailUrl;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: () => _openPlaylist(playlist),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Playlist Thumbnail
              SizedBox(
                width: 120,
                height: 68,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (thumbnailUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: Icon(
                              Icons.playlist_play,
                              size: 40,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                        )
                      else
                        Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: Icon(
                            Icons.playlist_play,
                            size: 40,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.5),
                          ),
                        ),

                      // Playlist overlay icon
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.playlist_play,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${playlist.videoCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Playlist Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      playlist.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Video count
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${playlist.videoCount} video${playlist.videoCount != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Watch button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        textStyle: GoogleFonts.poppins(fontSize: 12),
                        elevation: 1,
                      ),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Watch'),
                      onPressed: () => _openPlaylist(playlist),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Theme.of(context).colorScheme.surface,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search playlists...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _searchPlaylists('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _searchPlaylists,
          ),
        ),

        // Playlists List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading playlists...',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  )
                : _filteredPlaylists.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.playlist_play,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No playlists available'
                                  : 'No playlists match your search',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredPlaylists.length,
                        itemBuilder: (context, index) {
                          return _buildPlaylistCard(_filteredPlaylists[index]);
                        },
                      ),
          ),
        ),
      ],
    );
  }
}

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song_model.dart';
import '../theme/app_theme.dart';
import 'now_playing_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 110,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.background,
              flexibleSpace: const FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'Library',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add, color: AppColors.accent, size: 24),
                  onPressed: () {},
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.accent,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.accent,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  tabs: const [
                    Tab(text: 'Songs'),
                    Tab(text: 'Albums'),
                    Tab(text: 'Artists'),
                    Tab(text: 'Playlists'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _SongsTab(provider: provider),
            _AlbumsTab(provider: provider),
            _ArtistsTab(provider: provider),
            _PlaylistsTab(),
          ],
        ),
      ),
    );
  }
}

class _SongsTab extends StatelessWidget {
  final MusicProvider provider;

  const _SongsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (!provider.permissionGranted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'Permission Required',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Allow access to your music library',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => provider.requestPermission(),
              child: const Text('Allow Access'),
            ),
          ],
        ),
      );
    }

    if (provider.songs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_off_rounded, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'No Songs Found',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add music to your device',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: provider.songs.length,
      itemBuilder: (context, index) {
        final song = provider.songs[index];
        final isCurrentSong = provider.currentSong?.id == song.id;

        return _SongListTile(
          song: song,
          isCurrentSong: isCurrentSong,
          onTap: () {
            provider.playSong(song, queue: provider.songs);
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, animation, __) => const NowPlayingScreen(),
                transitionsBuilder: (_, animation, __, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _SongListTile extends StatefulWidget {
  final SongModel song;
  final bool isCurrentSong;
  final VoidCallback onTap;

  const _SongListTile({
    required this.song,
    required this.isCurrentSong,
    required this.onTap,
  });

  @override
  State<_SongListTile> createState() => _SongListTileState();
}

class _SongListTileState extends State<_SongListTile> {
  Uint8List? _artwork;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  Future<void> _loadArtwork() async {
    final provider = context.read<MusicProvider>();
    final art = await provider.getArtworkForSong(widget.song.id);
    if (mounted) {
      setState(() => _artwork = art);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _artwork != null
            ? Image.memory(
                _artwork!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              )
            : Container(
                width: 48,
                height: 48,
                color: AppColors.elevated,
                child: const Icon(
                  Icons.music_note_rounded,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
      ),
      title: Text(
        widget.song.title,
        style: TextStyle(
          color: widget.isCurrentSong ? AppColors.accent : AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.3,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.song.artist,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isCurrentSong)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.equalizer_rounded,
                  color: AppColors.accent, size: 18),
            ),
          Text(
            widget.song.durationFormatted,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 20),
        ],
      ),
      onTap: widget.onTap,
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  final MusicProvider provider;

  const _AlbumsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    // Group songs by album
    final Map<String, List<dynamic>> albums = {};
    for (final song in provider.songs) {
      albums.putIfAbsent(song.album, () => []).add(song);
    }

    if (albums.isEmpty) {
      return const Center(
        child: Text(
          'No Albums',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final albumName = albums.keys.elementAt(index);
        final albumSongs = albums[albumName]!;
        return _AlbumCard(
          albumName: albumName,
          artist: albumSongs[0].artist,
          songCount: albumSongs.length,
        );
      },
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final String albumName;
  final String artist;
  final int songCount;

  const _AlbumCard({
    required this.albumName,
    required this.artist,
    required this.songCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(Icons.album_rounded,
                  size: 52, color: AppColors.textSecondary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          albumName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          artist,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  final MusicProvider provider;

  const _ArtistsTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final Set<String> artists = provider.songs.map((s) => s.artist).toSet();
    final sortedArtists = artists.toList()..sort();

    if (sortedArtists.isEmpty) {
      return const Center(
        child: Text(
          'No Artists',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 160),
      itemCount: sortedArtists.length,
      itemBuilder: (context, index) {
        final artist = sortedArtists[index];
        final songCount =
            provider.songs.where((s) => s.artist == artist).length;
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.elevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.textSecondary, size: 24),
          ),
          title: Text(
            artist,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '$songCount ${songCount == 1 ? 'song' : 'songs'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          trailing: const Icon(Icons.chevron_right,
              color: AppColors.textSecondary),
          onTap: () {},
        );
      },
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.playlist_play_rounded,
                size: 44, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Playlists',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a playlist to get started',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.add),
            label: const Text('New Playlist'),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

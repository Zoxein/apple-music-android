import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song_model.dart';
import '../theme/app_theme.dart';
import 'now_playing_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 110,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'Search',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Artists, Songs, Lyrics, and More',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 17,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _isSearching
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              provider.searchSongs('');
                              setState(() => _isSearching = false);
                            },
                            child: const Icon(
                              Icons.cancel_rounded,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (query) {
                    setState(() => _isSearching = query.isNotEmpty);
                    provider.searchSongs(query);
                  },
                ),
              ),
            ),
          ),

          // Results or categories
          if (!_isSearching) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  'Browse Categories',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.0,
                ),
                delegate: SliverChildListDelegate([
                  _CategoryChip('Pop', Colors.pink, Icons.music_note),
                  _CategoryChip('Hip-Hop', Colors.orange, Icons.headphones),
                  _CategoryChip('Rock', Colors.red, Icons.electric_bolt),
                  _CategoryChip('Electronic', Colors.blue, Icons.tune),
                  _CategoryChip('R&B', Colors.purple, Icons.favorite),
                  _CategoryChip('Country', Colors.brown, Icons.landscape),
                  _CategoryChip('Jazz', Colors.teal, Icons.piano),
                  _CategoryChip('Classical', Colors.indigo, Icons.queue_music),
                ]),
              ),
            ),
          ] else ...[
            if (provider.filteredSongs.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 16),
                      Text(
                        'No Results Found',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Try a different search term',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = provider.filteredSongs[index];
                    return _SearchResultTile(
                      song: song,
                      onTap: () {
                        provider.playSong(song,
                            queue: provider.filteredSongs);
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (_, animation, __) =>
                                const NowPlayingScreen(),
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
                  childCount: provider.filteredSongs.length,
                ),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _CategoryChip(this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Icon(icon, color: Colors.white.withOpacity(0.5), size: 32),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatefulWidget {
  final SongModel song;
  final VoidCallback onTap;

  const _SearchResultTile({required this.song, required this.onTap});

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
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
            ? Image.memory(_artwork!, width: 48, height: 48, fit: BoxFit.cover)
            : Container(
                width: 48,
                height: 48,
                color: AppColors.elevated,
                child: const Icon(Icons.music_note_rounded,
                    color: AppColors.textSecondary, size: 24),
              ),
      ),
      title: Text(
        widget.song.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.3,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${widget.song.artist} • ${widget.song.album}',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
      onTap: widget.onTap,
    );
  }
}

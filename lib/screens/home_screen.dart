import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphism_container.dart';
import 'now_playing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Large title app bar
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                _getGreeting(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_circle_outlined,
                    color: AppColors.accent, size: 28),
                onPressed: () {},
              ),
            ],
          ),

          // Recently Played section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recently Played',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Horizontal scroll of recent items
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: _buildRecentlyPlayed(context, provider),
            ),
          ),

          // Songs from library section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'From Your Library',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Songs list preview
          if (provider.songs.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= provider.songs.length.clamp(0, 6)) {
                    return null;
                  }
                  final song = provider.songs[index];
                  return _HomeSongTile(
                    song: song,
                    onTap: () {
                      provider.playSong(song, queue: provider.songs);
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
                childCount: provider.songs.length.clamp(0, 6),
              ),
            )
          else if (!provider.isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.library_music_outlined,
                        size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text(
                      'No Music Found',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add music files to your device to\nsee them here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!provider.permissionGranted)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => provider.requestPermission(),
                        child: const Text('Grant Permission'),
                      ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 160)),
        ],
      ),
    );
  }

  Widget _buildRecentlyPlayed(BuildContext context, MusicProvider provider) {
    // Mock recently played items
    final List<Map<String, dynamic>> mockItems = [
      {'title': 'Chill Mix', 'subtitle': 'Playlist', 'icon': Icons.headphones},
      {'title': 'Top Charts', 'subtitle': 'Apple Music', 'icon': Icons.trending_up},
      {'title': 'Late Night', 'subtitle': 'Playlist', 'icon': Icons.nightlight_round},
      {'title': 'Workout', 'subtitle': 'Playlist', 'icon': Icons.fitness_center},
      {'title': 'Favorites', 'subtitle': 'Playlist', 'icon': Icons.favorite},
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      scrollDirection: Axis.horizontal,
      itemCount: mockItems.length,
      itemBuilder: (context, index) {
        final item = mockItems[index];
        return Container(
          width: 155,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassmorphismContainer(
                width: 155,
                height: 155,
                borderRadius: 12,
                child: Center(
                  child: Icon(
                    item['icon'] as IconData,
                    size: 52,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['title'] as String,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item['subtitle'] as String,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeSongTile extends StatelessWidget {
  final dynamic song;
  final VoidCallback onTap;

  const _HomeSongTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.music_note_rounded,
            color: AppColors.textSecondary, size: 24),
      ),
      title: Text(
        song.title,
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
        song.artist,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}

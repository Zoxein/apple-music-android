import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marquee/marquee.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/rotating_album_art.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  double _dragOffset = 0;
  double _volume = 0.8;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset += details.delta.dy;
      if (_dragOffset < 0) _dragOffset = 0;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_dragOffset > 100 || details.primaryVelocity! > 500) {
      Navigator.of(context).pop();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;
    if (song == null) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;
    final dominantColor = provider.dominantColor;
    final vibrantColor = provider.vibrantColor;

    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _dragOffset),
            child: child,
          );
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Dynamic blurred background
              _buildBackground(dominantColor, vibrantColor),

              // Frosted glass overlay
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(color: Colors.transparent),
              ),

              // Content
              SafeArea(
                child: Column(
                  children: [
                    // Drag handle + header
                    _buildHeader(context),

                    const Spacer(flex: 1),

                    // Rotating album art
                    _buildAlbumArt(provider),

                    const Spacer(flex: 2),

                    // Song info + heart
                    _buildSongInfo(song, provider),

                    const SizedBox(height: 20),

                    // Progress slider
                    _buildProgressSlider(provider),

                    const SizedBox(height: 8),

                    // Playback controls
                    _buildPlaybackControls(provider),

                    const SizedBox(height: 24),

                    // Volume slider
                    _buildVolumeSlider(provider),

                    const SizedBox(height: 24),

                    // Bottom actions
                    _buildBottomActions(provider),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackground(Color dominantColor, Color vibrantColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            dominantColor,
            Color.lerp(dominantColor, Colors.black, 0.5)!,
            Colors.black,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Artwork blurred in background
          if (context.read<MusicProvider>().currentArtwork != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.25,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Image.memory(
                    context.read<MusicProvider>().currentArtwork!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          // Dark gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              Column(
                children: [
                  const Text(
                    'NOW PLAYING',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Consumer<MusicProvider>(
                    builder: (context, prov, _) => Text(
                      prov.currentSong?.album ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showMoreOptions(context),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(MusicProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: RotatingAlbumArt(
        artwork: provider.currentArtwork,
        isPlaying: provider.isPlaying,
        size: MediaQuery.of(context).size.width - 80,
      ),
    );
  }

  Widget _buildSongInfo(dynamic song, MusicProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Song title – marquee if too long
                SizedBox(
                  height: 32,
                  child: _buildMarqueeOrText(
                    song.title,
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => provider.toggleLike(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                provider.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(provider.isLiked),
                color: provider.isLiked ? AppColors.accent : Colors.white.withOpacity(0.7),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarqueeOrText(String text, TextStyle style) {
    // Check if text likely overflows – approximate by length
    if (text.length > 28) {
      return Marquee(
        text: text,
        style: style,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 60,
        velocity: 35,
        pauseAfterRound: const Duration(seconds: 2),
        startPadding: 0,
        fadingEdgeStartFraction: 0.1,
        fadingEdgeEndFraction: 0.1,
      );
    }
    return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  Widget _buildProgressSlider(MusicProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: StreamBuilder<PositionData>(
        stream: provider.positionDataStream,
        builder: (context, snapshot) {
          final positionData = snapshot.data;
          final position = positionData?.position ?? Duration.zero;
          final duration = positionData?.duration ?? Duration.zero;
          final total = duration.inMilliseconds.toDouble();
          final current = position.inMilliseconds
              .toDouble()
              .clamp(0, total == 0 ? 0 : total);

          return Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayColor: Colors.transparent,
                ),
                child: Slider(
                  value: total > 0 ? current / total : 0,
                  onChanged: (value) {
                    if (total > 0) {
                      provider.seekTo(
                        Duration(milliseconds: (value * total).toInt()),
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaybackControls(MusicProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle
          GestureDetector(
            onTap: () => provider.toggleShuffle(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  Icons.shuffle_rounded,
                  color: provider.isShuffle
                      ? AppColors.accent
                      : Colors.white.withOpacity(0.7),
                  size: 22,
                ),
                if (provider.isShuffle)
                  Positioned(
                    bottom: -4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Previous
          GestureDetector(
            onTap: () => provider.playPrevious(),
            child: Icon(
              Icons.skip_previous_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),

          // Play/Pause
          GestureDetector(
            onTap: () => provider.togglePlayPause(),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  provider.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  key: ValueKey(provider.isPlaying),
                  color: Colors.black,
                  size: 38,
                ),
              ),
            ),
          ),

          // Next
          GestureDetector(
            onTap: () => provider.playNext(),
            child: Icon(
              Icons.skip_next_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),

          // Repeat
          GestureDetector(
            onTap: () => provider.toggleRepeat(),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  provider.repeatMode == RepeatMode.one
                      ? Icons.repeat_one_rounded
                      : Icons.repeat_rounded,
                  color: provider.repeatMode != RepeatMode.none
                      ? AppColors.accent
                      : Colors.white.withOpacity(0.7),
                  size: 22,
                ),
                if (provider.repeatMode != RepeatMode.none)
                  Positioned(
                    bottom: -4,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider(MusicProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Icon(
            Icons.volume_down_rounded,
            color: Colors.white.withOpacity(0.6),
            size: 18,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                activeTrackColor: Colors.white.withOpacity(0.85),
                inactiveTrackColor: Colors.white.withOpacity(0.25),
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayColor: Colors.transparent,
              ),
              child: Slider(
                value: _volume,
                onChanged: (value) {
                  setState(() => _volume = value);
                  provider.setVolume(value);
                },
              ),
            ),
          ),
          Icon(
            Icons.volume_up_rounded,
            color: Colors.white.withOpacity(0.6),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(MusicProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.airplay_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 22,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.queue_music_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 22,
            ),
          ),
          GestureDetector(
            onTap: () => _shareSheet(context),
            child: Icon(
              Icons.share_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes;
    final sec = d.inSeconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final song = context.read<MusicProvider>().currentSong;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (song != null) ...[
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.textPrimary),
                  title: Text(
                    '${song.title}\n${song.artist}',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),
              ],
              _BottomSheetItem(
                  icon: Icons.playlist_add_rounded, label: 'Add to Playlist'),
              _BottomSheetItem(
                  icon: Icons.person_outline_rounded, label: 'View Artist'),
              _BottomSheetItem(
                  icon: Icons.album_outlined, label: 'View Album'),
              _BottomSheetItem(
                  icon: Icons.share_rounded, label: 'Share Song'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _shareSheet(BuildContext context) {
    final song = context.read<MusicProvider>().currentSong;
    if (song == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${song.title}'),
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _BottomSheetItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BottomSheetItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accent),
      title: Text(
        label,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

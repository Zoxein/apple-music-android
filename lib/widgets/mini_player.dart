import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;
    if (song == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: provider.dominantColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  child: Row(
                    children: [
                      // Album art thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 42,
                          height: 42,
                          child: provider.currentArtwork != null
                              ? Image.memory(
                                  provider.currentArtwork!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: AppColors.elevated,
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    color: AppColors.textSecondary,
                                    size: 22,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Song info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artist,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => provider.togglePlayPause(),
                            child: Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  provider.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  key: ValueKey(provider.isPlaying),
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => provider.playNext(),
                            child: const SizedBox(
                              width: 36,
                              height: 36,
                              child: Icon(
                                Icons.skip_next_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Progress bar
                StreamBuilder<PositionData>(
                  stream: provider.positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    final position =
                        positionData?.position ?? Duration.zero;
                    final duration =
                        positionData?.duration ?? Duration.zero;
                    final total = duration.inMilliseconds.toDouble();
                    final current = position.inMilliseconds
                        .toDouble()
                        .clamp(0, total == 0 ? 0 : total);
                    final progress = total > 0 ? current / total : 0.0;

                    return Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: (progress * 1000).toInt(),
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            flex: ((1 - progress) * 1000).toInt(),
                            child: Container(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

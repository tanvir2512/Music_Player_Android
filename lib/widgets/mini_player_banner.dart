import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../providers/music_provider.dart';
import '../screens/now_playing_screen.dart';
import '../theme/app_theme.dart';

/// Small "current playing song" banner. Tapping it opens the full Now
/// Playing screen. Hidden entirely when nothing is loaded.
class MiniPlayerBanner extends StatelessWidget {
  const MiniPlayerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryDark.withOpacity(0.55), AppColors.card],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primary.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: QueryArtworkWidget(
                      id: song.rawId,
                      type: ArtworkType.AUDIO,
                      artworkFit: BoxFit.cover,
                      artworkBorder: BorderRadius.zero,
                      nullArtworkWidget: Container(
                        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                        child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        provider.displayTitle(song),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        provider.displayArtist(song),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                _MiniControlButton(
                  icon: Icons.skip_previous_rounded,
                  onTap: provider.previous,
                ),
                _MiniControlButton(
                  icon: provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  filled: true,
                  onTap: provider.togglePlayPause,
                ),
                _MiniControlButton(
                  icon: Icons.skip_next_rounded,
                  onTap: provider.next,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _MiniControlButton({required this.icon, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: filled ? AppColors.primaryGradient : null,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
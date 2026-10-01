import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../models/app_song.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'song_options_sheet.dart';

class SongTile extends StatelessWidget {
  final AppSong song;
  final VoidCallback onTap;
  final bool showFavoriteStar;
  final bool highlight;

  /// Overrides what the three-dot button opens. Defaults to the standard
  /// "My Music" options (Rename, Play Later, Add to Queue, Add to
  /// Playlist, Delete, Share).
  final VoidCallback? onMoreTap;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.showFavoriteStar = false,
    this.highlight = false,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final title = provider.displayTitle(song);
    final artist = provider.displayArtist(song);

    return Material(
      color: highlight ? AppColors.cardAlt : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: QueryArtworkWidget(
                    id: song.rawId,
                    type: ArtworkType.AUDIO,
                    artworkFit: BoxFit.cover,
                    artworkBorder: BorderRadius.zero,
                    nullArtworkWidget: Container(
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                      alignment: Alignment.center,
                      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$artist • ${formatDuration(song.duration)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              if (showFavoriteStar)
                IconButton(
                  icon: const Icon(Icons.star_rounded, color: AppColors.vinylYellow),
                  onPressed: () => provider.toggleFavorite(song),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                onPressed: onMoreTap ?? () => showSongOptionsSheet(context, song),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
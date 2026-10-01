import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/song_tile.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        final songs = provider.favoriteSongs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Row(
                children: [
                  const Text(
                    'Favorite',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.favorite_rounded, color: AppColors.primaryLight, size: 22),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                '${songs.length} song${songs.length == 1 ? '' : 's'}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            Expanded(
              child: songs.isEmpty
                  ? const _EmptyFavorites()
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 130),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final isCurrent = provider.currentSong?.id == song.id;
                  return SongTile(
                    song: song,
                    showFavoriteStar: true,
                    highlight: isCurrent,
                    onTap: () => provider.playSong(song, context: songs),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_border_rounded, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No favorites yet',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tap the star on the Now Playing screen to save songs here.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
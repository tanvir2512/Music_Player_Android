import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_song.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/search_bar_field.dart';
import '../widgets/song_tile.dart';
import '../widgets/sort_options_sheet.dart';

class MyMusicScreen extends StatelessWidget {
  const MyMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        final songs = provider.filteredSongs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Text(
                'My Music',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SearchBarField(
                hintText: 'Search songs',
                onChanged: provider.setSearchQuery,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 8, 4),
              child: Row(
                children: [
                  Text(
                    '${songs.length} song${songs.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.sort_rounded, color: AppColors.primaryLight),
                    tooltip: 'Sort songs',
                    onPressed: () => showSortOptionsSheet(context, provider),
                  ),
                ],
              ),
            ),
            Expanded(child: _MusicListBody(provider: provider, songs: songs)),
          ],
        );
      },
    );
  }
}

class _MusicListBody extends StatelessWidget {
  final MusicProvider provider;
  final List<AppSong> songs;

  const _MusicListBody({required this.provider, required this.songs});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (!provider.permissionGranted) {
      return _PermissionPrompt(onGrant: provider.requestPermissionAndReload);
    }
    if (songs.isEmpty) {
      return const _EmptyState(
        icon: Icons.music_off_rounded,
        title: 'No songs found',
        subtitle: 'Try a different search, or add mp3/m4a files to your device.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 130),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isCurrent = provider.currentSong?.id == song.id;
        return SongTile(
          song: song,
          highlight: isCurrent,
          onTap: () => provider.playSong(song, context: songs),
        );
      },
    );
  }
}

class _PermissionPrompt extends StatelessWidget {
  final Future<void> Function() onGrant;
  const _PermissionPrompt({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
              child: const Icon(Icons.folder_open_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Access your music',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pulse Music needs permission to read audio files on your device.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onGrant,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
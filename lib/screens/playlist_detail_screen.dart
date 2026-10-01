import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_dialogs.dart';
import '../widgets/playlist_song_options_sheet.dart';
import '../widgets/sheet_shell.dart';
import '../widgets/song_tile.dart';
import 'add_songs_to_playlist_screen.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        final playlist = provider.playlistById(playlistId);
        if (playlist == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(context)) Navigator.of(context).pop();
          });
          return const SizedBox.shrink();
        }
        final songs = provider.songsInPlaylist(playlistId);

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              playlist.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${songs.length} song${songs.length == 1 ? '' : 's'}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                        onPressed: () => _showPlaylistMenu(context, provider, playlistId, playlist.name),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: songs.isEmpty
                      ? _EmptyPlaylist(
                    onAdd: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => AddSongsToPlaylistScreen(playlistId: playlistId)),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 110),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      final isCurrent = provider.currentSong?.id == song.id;
                      return SongTile(
                        song: song,
                        highlight: isCurrent,
                        onTap: () => provider.playSong(song, context: songs),
                        onMoreTap: () => showPlaylistSongOptionsSheet(context, playlistId, song),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => AddSongsToPlaylistScreen(playlistId: playlistId)),
            ),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Songs'),
          ),
        );
      },
    );
  }

  void _showPlaylistMenu(
      BuildContext context,
      MusicProvider provider,
      String playlistId,
      String currentName,
      ) {
    showAppSheet(
      context,
      title: 'Playlist options',
      childrenBuilder: (context) => [
        SheetOptionTile(
          icon: Icons.edit_rounded,
          label: 'Rename Playlist',
          onTap: () async {
            Navigator.of(context).pop();
            final newName = await showTextInputDialog(
              context,
              title: 'Rename playlist',
              initialValue: currentName,
              hint: 'Playlist name',
            );
            if (newName != null && newName.isNotEmpty) {
              await provider.renamePlaylist(playlistId, newName);
            }
          },
        ),
        SheetOptionTile(
          icon: Icons.delete_outline_rounded,
          label: 'Delete Playlist',
          iconColor: AppColors.error,
          onTap: () async {
            Navigator.of(context).pop();
            final confirmed = await showConfirmDialog(
              context,
              title: 'Delete playlist?',
              message: 'This only deletes the playlist itself — your songs are unaffected.',
            );
            if (confirmed) {
              await provider.deletePlaylist(playlistId);
              if (context.mounted) Navigator.of(context).pop();
            }
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _EmptyPlaylist extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyPlaylist({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.playlist_add_rounded, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'This playlist is empty',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add songs from your library to get started.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Songs'),
            ),
          ],
        ),
      ),
    );
  }
}
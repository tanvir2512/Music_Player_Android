import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_song.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import 'common_dialogs.dart';
import 'sheet_shell.dart';

void showAddToPlaylistSheet(BuildContext context, AppSong song) {
  final provider = context.read<MusicProvider>();

  showAppSheet(
    context,
    title: 'Add to playlist',
    childrenBuilder: (context) => [
      SheetOptionTile(
        icon: Icons.add_rounded,
        label: 'New Playlist',
        iconColor: AppColors.vinylYellow,
        onTap: () async {
          Navigator.of(context).pop();
          final name = await showTextInputDialog(
            context,
            title: 'New playlist',
            hint: 'Playlist name',
            confirmLabel: 'Create & Add',
          );
          if (name != null && name.isNotEmpty) {
            final playlist = await provider.createPlaylist(name);
            await provider.addSongToPlaylist(playlist.id, song);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added to "${playlist.name}"')),
              );
            }
          }
        },
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Divider(color: AppColors.divider, height: 20),
      ),
      if (provider.playlists.isEmpty)
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Text(
            'No playlists yet — create one above.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ...provider.playlists.map((playlist) {
        final contains = playlist.songIds.contains(song.id);
        return SheetOptionTile(
          icon: Icons.queue_music_rounded,
          label: playlist.name,
          subtitle: '${playlist.songIds.length} songs',
          trailing: Icon(
            contains ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
            color: contains ? AppColors.primaryLight : AppColors.textSecondary,
          ),
          onTap: () async {
            if (contains) {
              await provider.removeSongFromPlaylist(playlist.id, song.id);
            } else {
              await provider.addSongToPlaylist(playlist.id, song);
            }
          },
        );
      }),
      const SizedBox(height: 8),
    ],
  );
}
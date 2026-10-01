import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_song.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import 'add_to_playlist_sheet.dart';
import 'sheet_shell.dart';

void showPlaylistSongOptionsSheet(BuildContext context, String playlistId, AppSong song) {
  final provider = context.read<MusicProvider>();

  showAppSheet(
    context,
    title: provider.displayTitle(song),
    childrenBuilder: (context) => [
      SheetOptionTile(
        icon: Icons.schedule_rounded,
        label: 'Play Later',
        onTap: () async {
          Navigator.of(context).pop();
          await provider.playLater(song);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to play later')));
          }
        },
      ),
      SheetOptionTile(
        icon: Icons.playlist_add_rounded,
        label: 'Add to Queue',
        onTap: () async {
          Navigator.of(context).pop();
          await provider.addToQueueNext(song);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to queue')));
          }
        },
      ),
      SheetOptionTile(
        icon: Icons.library_add_rounded,
        label: 'Add to Another Playlist',
        onTap: () {
          Navigator.of(context).pop();
          showAddToPlaylistSheet(context, song);
        },
      ),
      SheetOptionTile(
        icon: Icons.playlist_remove_rounded,
        label: 'Remove from Playlist',
        iconColor: AppColors.error,
        onTap: () async {
          Navigator.of(context).pop();
          await provider.removeSongFromPlaylist(playlistId, song.id);
        },
      ),
      SheetOptionTile(
        icon: Icons.share_rounded,
        label: 'Share',
        onTap: () {
          Navigator.of(context).pop();
          Share.share('${provider.displayTitle(song)} — ${provider.displayArtist(song)}');
        },
      ),
      const SizedBox(height: 8),
    ],
  );
}
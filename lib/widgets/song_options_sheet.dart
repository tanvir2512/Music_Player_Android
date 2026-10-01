import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_song.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import 'add_to_playlist_sheet.dart';
import 'common_dialogs.dart';
import 'sheet_shell.dart';

void showSongOptionsSheet(BuildContext context, AppSong song) {
  final provider = context.read<MusicProvider>();

  showAppSheet(
    context,
    title: provider.displayTitle(song),
    childrenBuilder: (context) => [
      SheetOptionTile(
        icon: Icons.edit_rounded,
        label: 'Rename',
        onTap: () async {
          Navigator.of(context).pop();
          final newTitle = await showTextInputDialog(
            context,
            title: 'Rename song',
            initialValue: provider.displayTitle(song),
            hint: 'Song title',
          );
          if (newTitle != null && newTitle.isNotEmpty) {
            await provider.renameSong(song, newTitle);
          }
        },
      ),
      SheetOptionTile(
        icon: Icons.schedule_rounded,
        label: 'Play Later',
        subtitle: 'Add to the end of the queue',
        onTap: () async {
          Navigator.of(context).pop();
          await provider.playLater(song);
          if (context.mounted) _toast(context, 'Added to play later');
        },
      ),
      SheetOptionTile(
        icon: Icons.playlist_add_rounded,
        label: 'Add to Queue',
        subtitle: 'Play right after the current song',
        onTap: () async {
          Navigator.of(context).pop();
          await provider.addToQueueNext(song);
          if (context.mounted) _toast(context, 'Added to queue');
        },
      ),
      SheetOptionTile(
        icon: Icons.library_add_rounded,
        label: 'Add to Playlist',
        onTap: () {
          Navigator.of(context).pop();
          showAddToPlaylistSheet(context, song);
        },
      ),
      SheetOptionTile(
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
        iconColor: AppColors.error,
        onTap: () async {
          Navigator.of(context).pop();
          final confirmed = await showConfirmDialog(
            context,
            title: 'Delete song?',
            message:
            '"${provider.displayTitle(song)}" will be removed from Pulse Music\'s library.',
          );
          if (confirmed) {
            await provider.deleteSong(song);
            if (context.mounted) _toast(context, 'Song deleted');
          }
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

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
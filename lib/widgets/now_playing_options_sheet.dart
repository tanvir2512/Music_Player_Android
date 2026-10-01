import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/app_song.dart';
import '../providers/music_provider.dart';
import 'add_to_playlist_sheet.dart';
import 'edit_song_info_dialog.dart';
import 'playback_speed_sheet.dart';
import 'sheet_shell.dart';
import 'sleep_timer_sheet.dart';

void showNowPlayingOptionsSheet(BuildContext context, AppSong song) {
  final provider = context.read<MusicProvider>();

  showAppSheet(
    context,
    title: 'More options',
    childrenBuilder: (context) => [
      SheetOptionTile(
        icon: Icons.library_add_rounded,
        label: 'Add to Playlist',
        onTap: () {
          Navigator.of(context).pop();
          showAddToPlaylistSheet(context, song);
        },
      ),
      SheetOptionTile(
        icon: Icons.bedtime_rounded,
        label: 'Sleep Timer',
        subtitle: provider.sleepAtEndOfTrack
            ? 'Ends after this track'
            : (provider.sleepRemaining != null ? 'Active' : 'Off'),
        onTap: () {
          Navigator.of(context).pop();
          showSleepTimerSheet(context);
        },
      ),
      SheetOptionTile(
        icon: Icons.speed_rounded,
        label: 'Playback Speed',
        subtitle: '${provider.speed.toStringAsFixed(2)}x',
        onTap: () {
          Navigator.of(context).pop();
          showPlaybackSpeedSheet(context);
        },
      ),
      SheetOptionTile(
        icon: Icons.info_outline_rounded,
        label: 'Edit Song Info',
        onTap: () {
          Navigator.of(context).pop();
          showEditSongInfoDialog(context, song);
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
      SheetOptionTile(
        icon: Icons.widgets_rounded,
        label: 'Home Screen Widget',
        onTap: () {
          Navigator.of(context).pop();
          _showWidgetInfoDialog(context);
        },
      ),
      const SizedBox(height: 8),
    ],
  );
}

void _showWidgetInfoDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Home Screen Widget'),
      content: const Text(
        'Adding a home-screen widget requires a small platform-specific '
            'integration (Android App Widgets / iOS WidgetKit), typically via '
            'the "home_widget" package. This entry is wired up as the place to '
            'launch that flow once the native widget is added to the project.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it')),
      ],
    ),
  );
}
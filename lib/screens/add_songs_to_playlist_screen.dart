import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../models/app_song.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/search_bar_field.dart';

class AddSongsToPlaylistScreen extends StatefulWidget {
  final String playlistId;
  const AddSongsToPlaylistScreen({super.key, required this.playlistId});

  @override
  State<AddSongsToPlaylistScreen> createState() => _AddSongsToPlaylistScreenState();
}

class _AddSongsToPlaylistScreenState extends State<AddSongsToPlaylistScreen> {
  String _query = '';
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    final playlist = context.read<MusicProvider>().playlistById(widget.playlistId);
    _selected = Set<String>.from(playlist?.songIds ?? const <String>[]);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final allSongs = provider.allSongs;
    final query = _query.trim().toLowerCase();
    final visible = query.isEmpty
        ? allSongs
        : allSongs
        .where((s) =>
    provider.displayTitle(s).toLowerCase().contains(query) ||
        provider.displayArtist(s).toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Add Songs',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SearchBarField(
                hintText: 'Search songs',
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: visible.isEmpty
                  ? const Center(
                child: Text('No songs found', style: TextStyle(color: AppColors.textSecondary)),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                itemCount: visible.length,
                itemBuilder: (context, index) {
                  final song = visible[index];
                  final checked = _selected.contains(song.id);
                  return _CheckableSongTile(
                    song: song,
                    title: provider.displayTitle(song),
                    artist: provider.displayArtist(song),
                    checked: checked,
                    onTap: () => setState(() {
                      checked ? _selected.remove(song.id) : _selected.add(song.id);
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            onPressed: () => _save(provider, allSongs),
            child: Text('Done  •  ${_selected.length} selected'),
          ),
        ),
      ),
    );
  }

  Future<void> _save(MusicProvider provider, List<AppSong> allSongs) async {
    final playlist = provider.playlistById(widget.playlistId);
    if (playlist == null) {
      Navigator.of(context).pop();
      return;
    }
    final original = Set<String>.from(playlist.songIds);
    for (final id in _selected.difference(original)) {
      final song = allSongs.where((s) => s.id == id).firstOrNull;
      if (song != null) await provider.addSongToPlaylist(widget.playlistId, song);
    }
    for (final id in original.difference(_selected)) {
      await provider.removeSongFromPlaylist(widget.playlistId, id);
    }
    if (mounted) Navigator.of(context).pop();
  }
}

class _CheckableSongTile extends StatelessWidget {
  final AppSong song;
  final String title;
  final String artist;
  final bool checked;
  final VoidCallback onTap;

  const _CheckableSongTile({
    required this.song,
    required this.title,
    required this.artist,
    required this.checked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: checked ? AppColors.cardAlt : Colors.transparent,
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
                  width: 48,
                  height: 48,
                  child: QueryArtworkWidget(
                    id: song.rawId,
                    type: ArtworkType.AUDIO,
                    artworkFit: BoxFit.cover,
                    artworkBorder: BorderRadius.zero,
                    nullArtworkWidget: Container(
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                      alignment: Alignment.center,
                      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14.5)),
                    const SizedBox(height: 2),
                    Text(artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Icon(
                checked ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                color: checked ? AppColors.primaryLight : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
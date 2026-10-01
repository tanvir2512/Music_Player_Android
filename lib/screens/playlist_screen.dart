import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_dialogs.dart';
import 'playlist_detail_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicProvider>(
      builder: (context, provider, _) {
        final playlists = provider.playlists;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Playlists',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                  ),
                  _CreateButton(onTap: () => _createPlaylist(context, provider)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text(
                '${playlists.length} playlist${playlists.length == 1 ? '' : 's'}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
            Expanded(
              child: playlists.isEmpty
                  ? _EmptyPlaylists(onCreate: () => _createPlaylist(context, provider))
                  : GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.88,
                ),
                itemCount: playlists.length,
                itemBuilder: (context, index) {
                  final playlist = playlists[index];
                  final count = playlist.songIds.length;
                  return _PlaylistCard(
                    name: playlist.name,
                    songCount: count,
                    index: index,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createPlaylist(BuildContext context, MusicProvider provider) async {
    final name = await showTextInputDialog(
      context,
      title: 'New playlist',
      hint: 'Playlist name',
      confirmLabel: 'Create',
    );
    if (name != null && name.isNotEmpty) {
      final playlist = await provider.createPlaylist(name);
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlistId: playlist.id)),
        );
      }
    }
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final String name;
  final int songCount;
  final int index;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.name,
    required this.songCount,
    required this.index,
    required this.onTap,
  });

  static const _gradients = [
    [Color(0xFF8B2FE0), Color(0xFFB06CFF)],
    [Color(0xFF6C2BD9), Color(0xFFFFC93C)],
    [Color(0xFF3E1E68), Color(0xFF9B5CFF)],
    [Color(0xFF5A1F9C), Color(0xFFE0A6FF)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[index % _gradients.length];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.queue_music_rounded, color: Colors.white, size: 34),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                '$songCount song${songCount == 1 ? '' : 's'}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPlaylists extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyPlaylists({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.queue_music_rounded, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No playlists yet',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create a playlist and add your favorite songs to it.',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Playlist'),
            ),
          ],
        ),
      ),
    );
  }
}
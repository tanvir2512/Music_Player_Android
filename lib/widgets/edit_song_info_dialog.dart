import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_song.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';

void showEditSongInfoDialog(BuildContext context, AppSong song) {
  final provider = context.read<MusicProvider>();
  final titleController = TextEditingController(text: provider.displayTitle(song));
  final artistController = TextEditingController(text: provider.displayArtist(song));

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit song info', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(controller: titleController, label: 'Title'),
            const SizedBox(height: 14),
            _field(controller: artistController, label: 'Artist'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.editSongInfo(
                song,
                title: titleController.text,
                artist: artistController.text,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

Widget _field({required TextEditingController controller, required String label}) {
  return TextField(
    controller: controller,
    style: const TextStyle(color: AppColors.textPrimary),
    cursorColor: AppColors.primary,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),
  );
}
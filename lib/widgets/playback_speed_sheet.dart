import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import 'sheet_shell.dart';

const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

void showPlaybackSpeedSheet(BuildContext context) {
  final provider = context.read<MusicProvider>();

  showAppSheet(
    context,
    title: 'Playback Speed',
    childrenBuilder: (context) => [
      ..._speeds.map((s) {
        final selected = (provider.speed - s).abs() < 0.001;
        return SheetOptionTile(
          icon: Icons.speed_rounded,
          label: '${s}x${s == 1.0 ? '  (Normal)' : ''}',
          iconColor: selected ? AppColors.vinylYellow : null,
          trailing: selected
              ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight)
              : null,
          onTap: () {
            provider.setSpeed(s);
            Navigator.of(context).pop();
          },
        );
      }),
      const SizedBox(height: 8),
    ],
  );
}
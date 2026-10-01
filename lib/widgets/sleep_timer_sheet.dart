import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'sheet_shell.dart';

const _presets = [15, 30, 45, 60];

void showSleepTimerSheet(BuildContext context) {
  final provider = context.read<MusicProvider>();

  showAppSheet(
    context,
    title: 'Sleep Timer',
    childrenBuilder: (context) => [
      if (provider.sleepRemaining != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'Stopping in ${formatSleepCountdown(provider.sleepRemaining!)}',
            style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600),
          ),
        ),
      SheetOptionTile(
        icon: Icons.block_rounded,
        label: 'Off',
        trailing: (provider.sleepRemaining == null && !provider.sleepAtEndOfTrack)
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight)
            : null,
        onTap: () {
          provider.cancelSleepTimer();
          Navigator.of(context).pop();
        },
      ),
      ..._presets.map(
            (minutes) => SheetOptionTile(
          icon: Icons.timer_rounded,
          label: '$minutes minutes',
          onTap: () {
            provider.setSleepTimer(Duration(minutes: minutes));
            Navigator.of(context).pop();
          },
        ),
      ),
      SheetOptionTile(
        icon: Icons.last_page_rounded,
        label: 'End of current track',
        trailing: provider.sleepAtEndOfTrack
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight)
            : null,
        onTap: () {
          provider.setSleepAtEndOfTrack();
          Navigator.of(context).pop();
        },
      ),
      const SizedBox(height: 8),
    ],
  );
}
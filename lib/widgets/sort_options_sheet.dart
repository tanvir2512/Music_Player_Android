import 'package:flutter/material.dart';

import '../models/sort_mode.dart';
import '../providers/music_provider.dart';
import '../theme/app_theme.dart';
import 'sheet_shell.dart';

void showSortOptionsSheet(BuildContext context, MusicProvider provider) {
  showAppSheet(
    context,
    title: 'Sort songs',
    childrenBuilder: (context) => [
      ...SortMode.values.map((mode) {
        final selected = provider.sortMode == mode;
        return SheetOptionTile(
          icon: mode.icon,
          label: mode.label,
          iconColor: selected ? AppColors.vinylYellow : null,
          trailing: selected
              ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryLight)
              : null,
          onTap: () {
            provider.setSortMode(mode);
            Navigator.of(context).pop();
          },
        );
      }),
      const SizedBox(height: 8),
    ],
  );
}
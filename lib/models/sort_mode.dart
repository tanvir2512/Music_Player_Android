import 'package:flutter/material.dart';

enum SortMode { dateAdded, name, playCount }

extension SortModeX on SortMode {
  String get label {
    switch (this) {
      case SortMode.dateAdded:
        return 'By Adding Time';
      case SortMode.name:
        return 'By Name';
      case SortMode.playCount:
        return 'By Times Played';
    }
  }

  IconData get icon {
    switch (this) {
      case SortMode.dateAdded:
        return Icons.access_time_rounded;
      case SortMode.name:
        return Icons.sort_by_alpha_rounded;
      case SortMode.playCount:
        return Icons.trending_up_rounded;
    }
  }
}

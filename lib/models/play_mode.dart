import 'package:flutter/material.dart';

enum PlayMode {
  repeatAll,
  repeatOne,
  shuffle;

  IconData get icon {
    switch (this) {
      case PlayMode.repeatAll:
        return Icons.repeat_rounded;
      case PlayMode.repeatOne:
        return Icons.repeat_one_rounded;
      case PlayMode.shuffle:
        return Icons.shuffle_rounded;
    }
  }

  String get label {
    switch (this) {
      case PlayMode.repeatAll:
        return 'Repeat All';
      case PlayMode.repeatOne:
        return 'Repeat One';
      case PlayMode.shuffle:
        return 'Shuffle';
    }
  }
}
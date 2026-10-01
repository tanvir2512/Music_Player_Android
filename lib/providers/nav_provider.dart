import 'package:flutter/foundation.dart';

/// Tracks which bottom-navigation tab is active. Kept separate from
/// [MusicProvider] so the Now Playing screen can send the user back to
/// "My Music" specifically when they tap back, as requested in the spec.
class NavProvider extends ChangeNotifier {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;

  static const int myMusicTab = 0;
  static const int favoriteTab = 1;
  static const int playlistTab = 2;

  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io'; // ADDED for file deletion

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/app_song.dart';
import '../models/play_mode.dart';
import '../models/playlist.dart';
import '../models/sort_mode.dart';

/// Single source of truth for the whole app: the song library, the
/// playback queue/state, favorites, playlists, play counts and a handful
/// of user preferences (sort mode, play mode, playback speed).
class MusicProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final Uuid _uuid = const Uuid();

  // ---- Library -------------------------------------------------------
  List<AppSong> _allSongs = [];
  bool _isLoading = true;
  bool _permissionGranted = false;

  // ---- Search / sort ---------------------------------------------------
  String _searchQuery = '';
  SortMode _sortMode = SortMode.dateAdded;

  // ---- Favorites / playlists / counts / overrides ---------------------
  Set<String> _favoriteIds = {};
  final Map<String, int> _playCounts = {};
  final Map<String, String> _customTitles = {};
  final Map<String, String> _customArtists = {};
  List<Playlist> _playlists = [];

  // ---- Playback queue ---------------------------------------------------
  List<AppSong> _queueSongs = [];
  ConcatenatingAudioSource? _playlistSource;
  int? _currentIndex;
  PlayMode _playMode = PlayMode.repeatAll;

  // ---- Sleep timer -------------------------------------------------------
  Duration? _sleepRemaining;
  Timer? _sleepTicker;
  bool _sleepAtEndOfTrack = false;

  // ======================================================================
  // Getters
  // ======================================================================
  bool get isLoading => _isLoading;
  bool get permissionGranted => _permissionGranted;
  String get searchQuery => _searchQuery;
  SortMode get sortMode => _sortMode;
  PlayMode get playMode => _playMode;
  List<Playlist> get playlists => List.unmodifiable(_playlists);
  List<AppSong> get allSongs => List.unmodifiable(_allSongs);
  List<AppSong> get queueSongs => List.unmodifiable(_queueSongs);

  AudioPlayer get player => _player;
  bool get isPlaying => _player.playing;
  int get currentIndex => _currentIndex ?? -1;
  Duration? get sleepRemaining => _sleepRemaining;
  bool get sleepAtEndOfTrack => _sleepAtEndOfTrack;
  double get speed => _player.speed;

  AppSong? get currentSong {
    final i = _currentIndex;
    if (i == null || i < 0 || i >= _queueSongs.length) return null;
    return _queueSongs[i];
  }

  List<AppSong> get favoriteSongs =>
      _allSongs.where((s) => _favoriteIds.contains(s.id)).toList();

  /// Search + sort applied to the full library — this backs the
  /// "My Music" list.
  List<AppSong> get filteredSongs {
    Iterable<AppSong> list = _allSongs;
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((s) =>
      displayTitle(s).toLowerCase().contains(q) ||
          displayArtist(s).toLowerCase().contains(q) ||
          s.album.toLowerCase().contains(q));
    }
    final result = list.toList();
    switch (_sortMode) {
      case SortMode.dateAdded:
        result.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SortMode.name:
        result.sort((a, b) =>
            displayTitle(a).toLowerCase().compareTo(displayTitle(b).toLowerCase()));
        break;
      case SortMode.playCount:
        result.sort((a, b) => playCountOf(b.id).compareTo(playCountOf(a.id)));
        break;
    }
    return result;
  }

  // ======================================================================
  // Init
  // ======================================================================
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await _loadPrefs();

    bool granted = await _audioQuery.checkAndRequest(
      retryRequest: true,
    );
    _permissionGranted = granted;
    if (granted) {
      await _loadSongs();
    }

    _player.currentIndexStream.listen((index) {
      _currentIndex = index;
      if (index != null) _registerPlayCount(index);
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      if (_sleepAtEndOfTrack &&
          state.processingState == ProcessingState.completed) {
        _player.pause();
        cancelSleepTimer();
      }
      notifyListeners();
    });

    _applyPlayMode();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> requestPermissionAndReload() async {
    final granted = await _audioQuery.checkAndRequest(
      retryRequest: true,
    );
    _permissionGranted = granted;
    if (granted) {
      _isLoading = true;
      notifyListeners();
      await _loadSongs();
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<void> _loadSongs() async {
    final raw = await _audioQuery.querySongs(
      orderType: OrderType.DESC_OR_GREATER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    _allSongs = raw
        .where(AppSong.isSupportedFormat)
        .map(AppSong.fromSongModel)
        .toList();
    notifyListeners();
  }

  Future<void> refreshLibrary() async {
    _isLoading = true;
    notifyListeners();
    await _loadSongs();
    _isLoading = false;
    notifyListeners();
  }

  // ======================================================================
  // Search / sort
  // ======================================================================
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortMode(SortMode mode) {
    _sortMode = mode;
    _savePrefs();
    notifyListeners();
  }

  // ======================================================================
  // Display overrides (rename / edit song info)
  // ======================================================================
  String displayTitle(AppSong song) => _customTitles[song.id] ?? song.title;
  String displayArtist(AppSong song) => _customArtists[song.id] ?? song.artist;

  Future<void> renameSong(AppSong song, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    _customTitles[song.id] = newTitle.trim();
    await _savePrefs();
    notifyListeners();
  }

  Future<void> editSongInfo(AppSong song, {String? title, String? artist}) async {
    if (title != null && title.trim().isNotEmpty) {
      _customTitles[song.id] = title.trim();
    }
    if (artist != null && artist.trim().isNotEmpty) {
      _customArtists[song.id] = artist.trim();
    }
    await _savePrefs();
    notifyListeners();
  }

  // ======================================================================
  // Favorites
  // ======================================================================
  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(AppSong song) async {
    if (_favoriteIds.contains(song.id)) {
      _favoriteIds.remove(song.id);
    } else {
      _favoriteIds.add(song.id);
    }
    await _savePrefs();
    notifyListeners();
  }

  // ======================================================================
  // Play counts
  // ======================================================================
  int playCountOf(String id) => _playCounts[id] ?? 0;

  void _registerPlayCount(int index) {
    if (index < 0 || index >= _queueSongs.length) return;
    final song = _queueSongs[index];
    _playCounts[song.id] = (_playCounts[song.id] ?? 0) + 1;
    _savePrefs();
  }

  // ======================================================================
  // Playback / queue
  // ======================================================================
  AudioSource _toAudioSource(AppSong s) {
    return AudioSource.uri(
      Uri.parse(s.filePath),
      tag: MediaItem(
        id: s.id,
        title: displayTitle(s),
        artist: displayArtist(s),
        album: s.album,
        duration: s.duration,
      ),
    );
  }

  /// Starts playing [song]. [context] is the ordered list the song belongs
  /// to so Next/Previous cycle through that same set.
  Future<void> playSong(AppSong song, {List<AppSong>? context}) async {
    // BUG 3 FIX: Check if tapped song is already the one currently playing.
    // If it is, simply ensure it's unpaused and return without resetting the track.
    if (currentSong?.id == song.id) {
      if (!_player.playing) {
        await _player.play();
      }
      return;
    }

    final list = context ?? filteredSongs;
    final index = list.indexWhere((s) => s.id == song.id);
    if (index == -1) return;
    await _loadQueue(list, index);
  }

  Future<void> _loadQueue(List<AppSong> songs, int startIndex) async {
    _queueSongs = List<AppSong>.from(songs);
    final sources = _queueSongs.map(_toAudioSource).toList();
    _playlistSource = ConcatenatingAudioSource(children: sources);
    try {
      await _player.setAudioSource(_playlistSource!, initialIndex: startIndex);
      _applyPlayMode();
      await _player.play();
    } catch (e) {
      debugPrint('MusicProvider: failed to load queue -> $e');
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (currentSong == null) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> next() async {
    if (_queueSongs.isEmpty) return;

    // BUG 2 FIX: If play mode is repeatOne (single loop),
    // tapping 'next' explicitly moves to the next song instead of looping.
    if (_playMode == PlayMode.repeatOne) {
      final current = _currentIndex ?? 0;
      final nextIndex = (current + 1) % _queueSongs.length;
      await _player.seek(Duration.zero, index: nextIndex);
      if (!_player.playing) await _player.play();
    }
    // Standard behavior
    else {
      if (_player.hasNext) {
        await _player.seekToNext();
        await _player.play();
      } else if (_playMode == PlayMode.repeatAll) {
        await _player.seek(Duration.zero, index: 0);
        await _player.play();
      }
    }
  }

  Future<void> previous() async {
    if (_player.position > const Duration(seconds: 3) || !_player.hasPrevious) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seekToPrevious();
      await _player.play();
    }
  }

  void cyclePlayMode() {
    switch (_playMode) {
      case PlayMode.repeatAll:
        _playMode = PlayMode.shuffle;
        break;
      case PlayMode.shuffle:
        _playMode = PlayMode.repeatOne;
        break;
      case PlayMode.repeatOne:
        _playMode = PlayMode.repeatAll;
        break;
    }
    _applyPlayMode();
    _savePrefs();
    notifyListeners();
  }

  void _applyPlayMode() {
    switch (_playMode) {
      case PlayMode.shuffle:
        _player.setShuffleModeEnabled(true);
        _player.setLoopMode(LoopMode.all);
        break;
      case PlayMode.repeatOne:
        _player.setShuffleModeEnabled(false);
        _player.setLoopMode(LoopMode.one); // Native loop mode
        break;
      case PlayMode.repeatAll:
        _player.setShuffleModeEnabled(false);
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  /// "Play Later" — adds the song to the end of the current queue.
  Future<void> playLater(AppSong song) async {
    if (_playlistSource == null) {
      await _loadQueue([song], 0);
      return;
    }
    _queueSongs.add(song);
    await _playlistSource!.add(_toAudioSource(song));
    notifyListeners();
  }

  /// "Add to Queue" — inserts the song right after the current track.
  Future<void> addToQueueNext(AppSong song) async {
    if (_playlistSource == null) {
      await _loadQueue([song], 0);
      return;
    }
    final insertAt = ((_currentIndex ?? -1) + 1).clamp(0, _queueSongs.length);
    _queueSongs.insert(insertAt, song);
    await _playlistSource!.insert(insertAt, _toAudioSource(song));
    notifyListeners();
  }

  // ======================================================================
  // Delete
  // ======================================================================
  Future<void> deleteSong(AppSong song) async {
    // BUG 1 FIX: Delete the physical file from the device storage
    try {
      final file = File(song.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint("Failed to delete file from storage: $e");
      // Continue removing it from app state even if file deletion fails
    }

    _allSongs.removeWhere((s) => s.id == song.id);
    _favoriteIds.remove(song.id);

    // Remove from playlists
    for (final p in _playlists) {
      p.songIds.remove(song.id);
    }

    // Manage Queue state
    _queueSongs.removeWhere((s) => s.id == song.id);
    if (currentSong?.id == song.id) {
      await _player.stop(); // Stop audio if they deleted the currently playing song
    }

    await _savePrefs();
    notifyListeners();
  }

  // ======================================================================
  // Playlists
  // ======================================================================
  Future<Playlist> createPlaylist(String name) async {
    final playlist = Playlist(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'New Playlist' : name.trim(),
    );
    _playlists.add(playlist);
    await _savePrefs();
    notifyListeners();
    return playlist;
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final playlist = _playlists.where((p) => p.id == id).firstOrNull;
    if (playlist == null || newName.trim().isEmpty) return;
    playlist.name = newName.trim();
    await _savePrefs();
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _savePrefs();
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, AppSong song) async {
    final playlist = _playlists.where((p) => p.id == playlistId).firstOrNull;
    if (playlist == null) return;
    if (!playlist.songIds.contains(song.id)) {
      playlist.songIds.add(song.id);
      await _savePrefs();
      notifyListeners();
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = _playlists.where((p) => p.id == playlistId).firstOrNull;
    if (playlist == null) return;
    playlist.songIds.remove(songId);
    await _savePrefs();
    notifyListeners();
  }

  Playlist? playlistById(String id) =>
      _playlists.where((p) => p.id == id).firstOrNull;

  List<AppSong> songsInPlaylist(String playlistId) {
    final playlist = playlistById(playlistId);
    if (playlist == null) return [];
    final result = <AppSong>[];
    for (final id in playlist.songIds) {
      final song = _findSongById(id);
      if (song != null) result.add(song);
    }
    return result;
  }

  AppSong? _findSongById(String id) {
    for (final s in _allSongs) {
      if (s.id == id) return s;
    }
    return null;
  }

  // ======================================================================
  // Sleep timer
  // ======================================================================
  void setSleepTimer(Duration duration) {
    _sleepTicker?.cancel();
    _sleepAtEndOfTrack = false;
    _sleepRemaining = duration;
    _sleepTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _sleepRemaining;
      if (remaining == null) {
        timer.cancel();
        return;
      }
      final next = remaining - const Duration(seconds: 1);
      if (next.inSeconds <= 0) {
        _player.pause();
        cancelSleepTimer();
      } else {
        _sleepRemaining = next;
        notifyListeners();
      }
    });
    notifyListeners();
  }

  void setSleepAtEndOfTrack() {
    _sleepTicker?.cancel();
    _sleepTicker = null;
    _sleepRemaining = null;
    _sleepAtEndOfTrack = true;
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTicker?.cancel();
    _sleepTicker = null;
    _sleepRemaining = null;
    _sleepAtEndOfTrack = false;
    notifyListeners();
  }

  // ======================================================================
  // Playback speed
  // ======================================================================
  Future<void> setSpeed(double newSpeed) async {
    await _player.setSpeed(newSpeed);
    notifyListeners();
  }

  // ======================================================================
  // Persistence
  // ======================================================================
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _favoriteIds = (prefs.getStringList('favorites') ?? []).toSet();

    final playCountsJson = prefs.getString('playCounts');
    if (playCountsJson != null) {
      final map = jsonDecode(playCountsJson) as Map<String, dynamic>;
      _playCounts
        ..clear()
        ..addAll(map.map((k, v) => MapEntry(k, v as int)));
    }

    final customTitlesJson = prefs.getString('customTitles');
    if (customTitlesJson != null) {
      final map = jsonDecode(customTitlesJson) as Map<String, dynamic>;
      _customTitles
        ..clear()
        ..addAll(map.map((k, v) => MapEntry(k, v as String)));
    }

    final customArtistsJson = prefs.getString('customArtists');
    if (customArtistsJson != null) {
      final map = jsonDecode(customArtistsJson) as Map<String, dynamic>;
      _customArtists
        ..clear()
        ..addAll(map.map((k, v) => MapEntry(k, v as String)));
    }

    final playlistsJson = prefs.getString('playlists');
    if (playlistsJson != null) {
      final list = jsonDecode(playlistsJson) as List<dynamic>;
      _playlists = list
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final sortStr = prefs.getString('sortMode');
    if (sortStr != null) {
      _sortMode = SortMode.values.firstWhere(
            (e) => e.name == sortStr,
        orElse: () => SortMode.dateAdded,
      );
    }

    final modeStr = prefs.getString('playMode');
    if (modeStr != null) {
      _playMode = PlayMode.values.firstWhere(
            (e) => e.name == modeStr,
        orElse: () => PlayMode.repeatAll,
      );
    }
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favoriteIds.toList());
    await prefs.setString('playCounts', jsonEncode(_playCounts));
    await prefs.setString('customTitles', jsonEncode(_customTitles));
    await prefs.setString('customArtists', jsonEncode(_customArtists));
    await prefs.setString(
        'playlists', jsonEncode(_playlists.map((p) => p.toJson()).toList()));
    await prefs.setString('sortMode', _sortMode.name);
    await prefs.setString('playMode', _playMode.name);
  }

  @override
  void dispose() {
    _sleepTicker?.cancel();
    _player.dispose();
    super.dispose();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
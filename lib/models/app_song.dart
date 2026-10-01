import 'package:on_audio_query/on_audio_query.dart';

/// Lightweight, app-owned representation of a song on the device.
///
/// [rawId] keeps the original integer id from `on_audio_query`, which is
/// needed for artwork lookups (`QueryArtworkWidget`). [id] is the string
/// key used everywhere else in the app (favorites, playlists, play counts).
class AppSong {
  final int rawId;
  final String id;
  final String title;
  final String artist;
  final String album;
  final int durationMs;
  final String filePath;
  final DateTime dateAdded;

  const AppSong({
    required this.rawId,
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.filePath,
    required this.dateAdded,
  });

  Duration get duration => Duration(milliseconds: durationMs);

  factory AppSong.fromSongModel(SongModel m) {
    return AppSong(
      rawId: m.id,
      id: m.id.toString(),
      title: _clean(m.title),
      artist: _clean(m.artist),
      album: _clean(m.album),
      durationMs: m.duration ?? 0,
      // Prefer the content:// uri (scoped-storage friendly) and fall back
      // to the raw file path if it's missing for some reason.
      filePath: (m.uri != null && m.uri!.isNotEmpty) ? m.uri! : m.data,
      dateAdded: m.dateAdded != null
          ? DateTime.fromMillisecondsSinceEpoch(m.dateAdded! * 1000)
          : DateTime.now(),
    );
  }

  static String _clean(String? value) {
    if (value == null || value.isEmpty || value == '<unknown>') {
      return 'Unknown';
    }
    return value;
  }

  /// True if the underlying file is an mp3 or m4a (the two formats this
  /// app is required to support).
  static bool isSupportedFormat(SongModel m) {
    final name = m.displayName.toLowerCase();
    return name.endsWith('.mp3') || name.endsWith('.m4a');
  }
}

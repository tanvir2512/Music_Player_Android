import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_song.dart';
import '../models/play_mode.dart';
import '../providers/music_provider.dart';
import '../providers/nav_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/now_playing_options_sheet.dart';
import '../widgets/vinyl_disc.dart';

/// Helper extension on [PlayMode] if getters aren't defined in `play_mode.dart`
extension PlayModeUi on PlayMode {
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

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 9));
    final playing = context.read<MusicProvider>().isPlaying;
    if (playing) _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  /// Sends the user back to the "My Music" tab, then pops the route.
  void _handleBack() {
    context.read<NavProvider>().setTab(NavProvider.myMusicTab);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;

    // Keep the disc's spin in sync with playback without resetting rotation.
    if (provider.isPlaying && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!provider.isPlaying && _rotationController.isAnimating) {
      _rotationController.stop();
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.read<NavProvider>().setTab(NavProvider.myMusicTab);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: song == null
                ? _NothingPlaying(onBack: _handleBack)
                : _PlayingBody(
              song: song,
              provider: provider,
              rotationController: _rotationController,
              onBack: _handleBack,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayingBody extends StatelessWidget {
  final AppSong song;
  final MusicProvider provider;
  final AnimationController rotationController;
  final VoidCallback onBack;

  const _PlayingBody({
    required this.song,
    required this.provider,
    required this.rotationController,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final discSize = size.width * 0.72;
    final isFav = provider.isFavorite(song.id);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 30),
                onPressed: onBack,
              ),
              const Expanded(
                child: Text(
                  'NOW PLAYING',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.vinylYellow,
                  size: 26,
                ),
                onPressed: () => provider.toggleFavorite(song),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
                onPressed: () => showNowPlayingOptionsSheet(context, song),
              ),
            ],
          ),
        ),
        if (provider.sleepRemaining != null || provider.sleepAtEndOfTrack)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bedtime_rounded, color: AppColors.primaryLight, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    provider.sleepAtEndOfTrack
                        ? 'Stopping after this track'
                        : 'Sleep in ${formatSleepCountdown(provider.sleepRemaining!)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
        const Spacer(),
        VinylDisc(size: discSize, controller: rotationController, songRawId: song.rawId),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(
                provider.displayTitle(song),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                provider.displayArtist(song),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SeekBar(provider: provider, song: song),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(provider.playMode.icon, color: AppColors.primaryLight, size: 24),
                tooltip: provider.playMode.label,
                onPressed: provider.cyclePlayMode,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 38),
                onPressed: provider.previous,
              ),
              GestureDetector(
                onTap: provider.togglePlayPause,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 38),
                onPressed: provider.next,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SeekBar extends StatelessWidget {
  final MusicProvider provider;
  final AppSong song;

  const _SeekBar({required this.provider, required this.song});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: provider.player.positionStream,
      builder: (context, snapshot) {
        final position = snapshot.data ?? Duration.zero;
        final total = provider.player.duration ?? song.duration;
        final maxMs = total.inMilliseconds <= 0 ? 1.0 : total.inMilliseconds.toDouble();
        final valueMs = position.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: valueMs,
                max: maxMs,
                onChanged: (v) => provider.player.seek(Duration(milliseconds: v.toInt())),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(position), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(formatDuration(total), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NothingPlaying extends StatelessWidget {
  final VoidCallback onBack;
  const _NothingPlaying({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 30),
            onPressed: onBack,
          ),
        ),
        const Expanded(
          child: Center(
            child: Text('Nothing is playing', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
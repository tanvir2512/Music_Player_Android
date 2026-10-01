import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../theme/app_theme.dart';

/// A flat, yellow-and-black vinyl record. Spins continuously while
/// [controller] is running (driven by the Now Playing screen based on
/// play/pause state) and freezes in place — rather than resetting — when
/// paused.
class VinylDisc extends StatelessWidget {
  final double size;
  final int? songRawId;
  final AnimationController controller;

  const VinylDisc({
    super.key,
    required this.size,
    required this.controller,
    this.songRawId,
  });

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: controller,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.vinylGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 44,
              spreadRadius: 2,
            ),
            const BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final ratio in [0.97, 0.85, 0.73, 0.62, 0.53])
              Container(
                width: size * ratio,
                height: size * ratio,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.vinylYellow.withOpacity(0.14),
                    width: 1,
                  ),
                ),
              ),
            // Label: album art if available, otherwise plain yellow.
            ClipOval(
              child: SizedBox(
                width: size * 0.46,
                height: size * 0.46,
                child: songRawId != null
                    ? QueryArtworkWidget(
                  id: songRawId!,
                  type: ArtworkType.AUDIO,
                  artworkFit: BoxFit.cover,
                  artworkBorder: BorderRadius.zero,
                  nullArtworkWidget: _fallbackLabel(),
                )
                    : _fallbackLabel(),
              ),
            ),
            Container(
              width: size * 0.46,
              height: size * 0.46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.vinylYellow, width: 5),
              ),
            ),
            Container(
              width: size * 0.07,
              height: size * 0.07,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackLabel() {
    return Container(
      color: AppColors.vinylYellow,
      alignment: Alignment.center,
      child: Icon(Icons.music_note_rounded, color: Colors.black.withOpacity(0.55), size: size * 0.16),
    );
  }
}
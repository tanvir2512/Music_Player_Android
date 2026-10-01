import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';

import 'providers/music_provider.dart';
import 'providers/nav_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize JustAudioBackground safely
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.pulse.music.channel.audio',
      androidNotificationChannelName: 'Pulse Music playback',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    );
  } catch (e) {
    debugPrint('JustAudioBackground init warning: $e');
  }

  // ATTACH THE WIDGET TREE TO THE SCREEN
  runApp(const PulseMusicApp());
}

class PulseMusicApp extends StatelessWidget {
  const PulseMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = MusicProvider();
            // Post frame callback ensures the UI is rendered before running init logic
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.init();
            });
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => NavProvider()),
      ],
      child: MaterialApp(
        title: 'Pulse Music',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
// lib/main.dart
// App entry point. Sets up Firebase, Provider + theme and loads player data.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/game_provider.dart';
import 'services/ad_service.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/store_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Google Mobile Ads SDK
  await AdService.initialize();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const GameGuessApp());
}

class GameGuessApp extends StatelessWidget {
  const GameGuessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..init(),
      child: MaterialApp(
        title: 'GameGuess',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SplashScreen(),
        routes: {
          '/leaderboard': (_) => const LeaderboardScreen(),
          '/store': (_) => const StoreScreen(),
        },
      ),
    );
  }
}

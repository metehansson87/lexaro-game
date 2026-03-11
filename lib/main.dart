// lib/main.dart
// App entry point. Sets up Provider + theme and loads player data.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/game_provider.dart';
import 'services/ad_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/store_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        home: const _Loader(),
        routes: {
          '/leaderboard': (_) => const LeaderboardScreen(),
          '/store': (_) => const StoreScreen(),
        },
      ),
    );
  }
}

// Shows a loading screen while GameProvider initializes
class _Loader extends StatefulWidget {
  const _Loader();

  @override
  State<_Loader> createState() => _LoaderState();
}

class _LoaderState extends State<_Loader> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Wait for provider init then navigate
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Provider is already initing via init() in the create callback.
      // Give it a brief moment then show home screen.
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return const HomeScreen();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.gamepad_rounded, color: Colors.white, size: 46),
            ),
            const SizedBox(height: 20),
            const Text(
              'GameGuess',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

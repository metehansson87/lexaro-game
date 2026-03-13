import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/puzzle/presentation/puzzle_screen.dart';
import 'features/multiplayer/presentation/matchmaking_screen.dart';
import 'features/multiplayer/presentation/match_screen.dart';
import 'features/leaderboard/presentation/leaderboard_screen.dart';
import 'features/store/presentation/store_screen.dart';
import 'features/achievements/presentation/achievements_screen.dart';
import 'features/daily_puzzle/presentation/daily_puzzle_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/live_ops/presentation/live_ops_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for consistent puzzle layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F1E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase (uncomment when Firebase is configured)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    const ProviderScope(
      child: LexaroApp(),
    ),
  );
}

/// Root application widget.
class LexaroApp extends StatelessWidget {
  const LexaroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexaro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRouter.auth,
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case AppRouter.auth:
        page = const AuthScreen();
        break;
      case AppRouter.home:
        page = const HomeScreen();
        break;
      case AppRouter.puzzle:
        final args = settings.arguments as PuzzleScreenArgs? ??
            const PuzzleScreenArgs();
        page = PuzzleScreen(args: args);
        break;
      case AppRouter.matchmaking:
        page = const MatchmakingScreen();
        break;
      case AppRouter.match:
        final args = settings.arguments as MatchScreenArgs? ??
            const MatchScreenArgs();
        page = MatchScreen(args: args);
        break;
      case AppRouter.leaderboard:
        page = const LeaderboardScreen();
        break;
      case AppRouter.store:
        page = const StoreScreen();
        break;
      case AppRouter.achievements:
        page = const AchievementsScreen();
        break;
      case AppRouter.dailyPuzzle:
        page = const DailyPuzzleScreen();
        break;
      case AppRouter.settings:
        page = const SettingsScreen();
        break;
      case AppRouter.liveOps:
        page = const LiveOpsScreen();
        break;
      default:
        page = const AuthScreen();
    }

    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

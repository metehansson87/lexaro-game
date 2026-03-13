import 'package:flutter/material.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/puzzle/presentation/puzzle_screen.dart';
import '../../features/multiplayer/presentation/matchmaking_screen.dart';
import '../../features/multiplayer/presentation/match_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/store/presentation/store_screen.dart';
import '../../features/daily_puzzle/presentation/daily_puzzle_screen.dart';
import '../../features/achievements/presentation/achievements_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';

/// Centralized route definitions and navigation.
class AppRouter {
  AppRouter._();

  // ── Route Names ───────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String puzzle = '/puzzle';
  static const String matchmaking = '/matchmaking';
  static const String match = '/match';
  static const String leaderboard = '/leaderboard';
  static const String store = '/store';
  static const String dailyPuzzle = '/daily-puzzle';
  static const String achievements = '/achievements';
  static const String settings = '/settings';
  static const String liveOps = '/live-ops';

  // ── Route Generation ──────────────────────────────────────────────────────
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case auth:
        return _buildRoute(const AuthScreen(), routeSettings);

      case home:
        return _buildRoute(const HomeScreen(), routeSettings);

      case puzzle:
        final args = routeSettings.arguments as PuzzleScreenArgs?;
        return _buildRoute(
          PuzzleScreen(args: args ?? const PuzzleScreenArgs()),
          routeSettings,
        );

      case matchmaking:
        return _buildRoute(const MatchmakingScreen(), routeSettings);

      case match:
        final args = routeSettings.arguments as MatchScreenArgs;
        return _buildRoute(MatchScreen(args: args), routeSettings);

      case leaderboard:
        return _buildRoute(const LeaderboardScreen(), routeSettings);

      case store:
        return _buildRoute(const StoreScreen(), routeSettings);

      case dailyPuzzle:
        return _buildRoute(const DailyPuzzleScreen(), routeSettings);

      case achievements:
        return _buildRoute(const AchievementsScreen(), routeSettings);

      case settings:
        return _buildRoute(const SettingsScreen(), routeSettings);

      default:
        return _buildRoute(const HomeScreen(), routeSettings);
    }
  }

  static MaterialPageRoute<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

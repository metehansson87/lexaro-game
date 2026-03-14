import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/audio_service.dart';
import '../core/services/ad_service.dart';
import '../core/services/analytics_service.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/socket_service.dart';
import '../data/models/player_model.dart';
import '../data/models/puzzle_model.dart';
import '../data/repositories/puzzle_repository.dart';
import '../data/repositories/match_repository.dart';
import '../data/repositories/leaderboard_repository.dart';

// ─── Service Providers ──────────────────────────────────────────────────────

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

// ─── Repository Providers ───────────────────────────────────────────────────

final puzzleRepositoryProvider = Provider<PuzzleRepository>((ref) {
  return PuzzleRepository();
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository();
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository();
});

// ─── State Providers ────────────────────────────────────────────────────────

/// Current player state.
final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerModel>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<PlayerModel> {
  PlayerNotifier() : super(PlayerModel.newPlayer());

  void addGold(int amount) {
    state = state.copyWith(gold: state.gold + amount);
  }

  bool spendGold(int amount) {
    if (state.gold < amount) return false;
    state = state.copyWith(gold: state.gold - amount);
    return true;
  }

  void recordPuzzleSolved(int points) {
    state = state.copyWith(
      puzzlesSolved: state.puzzlesSolved + 1,
      totalScore: state.totalScore + points,
    );
  }

  void recordPuzzleFailed() {
    state = state.copyWith(puzzlesFailed: state.puzzlesFailed + 1);
  }

  void recordMatchWin(int goldReward) {
    final newStreak = state.currentStreak + 1;
    state = state.copyWith(
      matchesWon: state.matchesWon + 1,
      gold: state.gold + goldReward,
      currentStreak: newStreak,
      bestStreak: newStreak > state.bestStreak ? newStreak : state.bestStreak,
    );
  }

  void recordMatchLoss(int goldReward) {
    state = state.copyWith(
      matchesLost: state.matchesLost + 1,
      gold: state.gold + goldReward,
      currentStreak: 0,
    );
  }

  void claimDailyReward(int goldAmount) {
    state = state.copyWith(
      gold: state.gold + goldAmount,
      lastDailyReward: DateTime.now().toUtc(),
    );
  }

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void updateDisplayName(String name) {
    state = state.copyWith(displayName: name);
  }
}

/// Selected puzzle difficulty.
final difficultyProvider = StateProvider<Difficulty>((ref) {
  return Difficulty.medium;
});

/// Selected puzzle language.
final languageProvider = StateProvider<String>((ref) {
  return 'en';
});

/// Audio enabled state.
final soundEnabledProvider = StateProvider<bool>((ref) => true);

/// Music enabled state.
final musicEnabledProvider = StateProvider<bool>((ref) => true);

/// Connectivity state.
final isOnlineProvider = StateProvider<bool>((ref) => true);

/// Puzzle count by language.
final puzzleCountProvider =
    Provider.family<int, String>((ref, language) {
  final repo = ref.watch(puzzleRepositoryProvider);
  return repo.getPuzzleCount(language: language);
});

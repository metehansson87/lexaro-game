import '../config/app_config.dart';

/// Analytics tracking service for game metrics.
/// Tracks match win rates, puzzle difficulty success, and session length.
class AnalyticsService {
  final Map<String, dynamic> _sessionData = {};
  DateTime? _sessionStart;

  void startSession() {
    if (!AppConfig.enableAnalytics) return;
    _sessionStart = DateTime.now();
    _sessionData.clear();
  }

  void endSession() {
    if (!AppConfig.enableAnalytics || _sessionStart == null) return;
    final duration = DateTime.now().difference(_sessionStart!);
    _logEvent('session_end', {'duration_seconds': duration.inSeconds});
  }

  void logMatchResult({
    required String matchId,
    required bool won,
    required int roundsWon,
    required int roundsLost,
    required String difficulty,
    required bool vsAi,
  }) {
    _logEvent('match_result', {
      'match_id': matchId,
      'won': won,
      'rounds_won': roundsWon,
      'rounds_lost': roundsLost,
      'difficulty': difficulty,
      'vs_ai': vsAi,
    });
  }

  void logPuzzleSolved({
    required String puzzleId,
    required String difficulty,
    required int timeSeconds,
    required int hintsUsed,
    required String language,
  }) {
    _logEvent('puzzle_solved', {
      'puzzle_id': puzzleId,
      'difficulty': difficulty,
      'time_seconds': timeSeconds,
      'hints_used': hintsUsed,
      'language': language,
    });
  }

  void logPuzzleFailed({
    required String puzzleId,
    required String difficulty,
    required String language,
  }) {
    _logEvent('puzzle_failed', {
      'puzzle_id': puzzleId,
      'difficulty': difficulty,
      'language': language,
    });
  }

  void logGoldEarned({required int amount, required String source}) {
    _logEvent('gold_earned', {'amount': amount, 'source': source});
  }

  void logGoldSpent({required int amount, required String item}) {
    _logEvent('gold_spent', {'amount': amount, 'item': item});
  }

  void logAdWatched({required String type}) {
    _logEvent('ad_watched', {'type': type});
  }

  void logScreenView(String screenName) {
    _logEvent('screen_view', {'screen': screenName});
  }

  void logDailyPuzzleCompleted({required int timeSeconds}) {
    _logEvent('daily_puzzle_completed', {'time_seconds': timeSeconds});
  }

  void logAchievementUnlocked(String achievementId) {
    _logEvent('achievement_unlocked', {'id': achievementId});
  }

  void _logEvent(String name, Map<String, dynamic> params) {
    if (!AppConfig.enableAnalytics) return;
    // In production: send to Firebase Analytics or custom backend
    // FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }
}

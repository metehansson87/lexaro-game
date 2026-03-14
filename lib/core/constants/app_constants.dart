/// Core game constants used across the entire application.
/// Single source of truth for all magic numbers and configuration values.
class AppConstants {
  AppConstants._();

  // ── App Info ──────────────────────────────────────────────────────────────
  static const String appName = 'Lexaro';
  static const String appTagline = 'Word Puzzle Battle';
  static const String appVersion = '1.0.0';

  // ── Match Rules ───────────────────────────────────────────────────────────
  static const int matchRounds = 5;
  static const int roundDurationSeconds = 45;
  static const int maxHintsPerRound = 5;

  // ── Economy ───────────────────────────────────────────────────────────────
  static const int startingGold = 50;
  static const int hintCostGold = 1;
  static const int dailyRewardGold = 10;
  static const int matchWinGold = 15;
  static const int matchLossGold = 3;
  static const int adRewardGold = 5;
  static const int adRewardHints = 1;
  static const int rewardedAdGold = 5;
  static const int dailyPuzzleReward = 10;

  // ── Points ────────────────────────────────────────────────────────────────
  static const int easyPoints = 5;
  static const int mediumPoints = 10;
  static const int hardPoints = 20;

  // ── Ad Frequency ──────────────────────────────────────────────────────────
  static const int interstitialAfterPuzzles = 3;
  static const int interstitialAfterMatches = 2;

  // ── Leagues ───────────────────────────────────────────────────────────────
  static const int bronzeThreshold = 0;
  static const int silverThreshold = 500;
  static const int goldThreshold = 2000;
  static const int diamondThreshold = 5000;

  // ── AI Timing (milliseconds) ──────────────────────────────────────────────
  static const int aiMinDelayEasy = 8000;
  static const int aiMaxDelayEasy = 25000;
  static const int aiMinDelayMedium = 5000;
  static const int aiMaxDelayMedium = 18000;
  static const int aiMinDelayHard = 2000;
  static const int aiMaxDelayHard = 10000;

  // ── Puzzle Database ───────────────────────────────────────────────────────
  static const int minimumPuzzleCount = 1000;
  static const List<String> supportedLanguages = [
    'en', 'tr', 'de', 'it', 'fr', 'es',
  ];
}

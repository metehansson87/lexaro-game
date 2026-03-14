/// Application-wide configuration that can be toggled per environment.
class AppConfig {
  AppConfig._();

  // ── Environment ───────────────────────────────────────────────────────────
  static const Environment environment = Environment.development;

  static bool get isDevelopment => environment == Environment.development;
  static bool get isStaging => environment == Environment.staging;
  static bool get isProduction => environment == Environment.production;

  // ── Feature Flags ─────────────────────────────────────────────────────────
  static const bool enableMultiplayer = true;
  static const bool enableAds = true;
  static const bool enableAnalytics = true;
  static const bool enableDailyPuzzle = true;
  static const bool enableLiveOps = true;
  static const bool enableAchievements = true;
  static const bool enableFirebaseAuth = true;
  static const bool enableSoundEffects = true;

  // ── AdMob IDs ─────────────────────────────────────────────────────────────
  static String get admobBannerId => isDevelopment
      ? 'ca-app-pub-3940256099942544/6300978111' // test
      : 'ca-app-pub-XXXXX/XXXXX'; // production

  static String get admobInterstitialId => isDevelopment
      ? 'ca-app-pub-3940256099942544/1033173712' // test
      : 'ca-app-pub-XXXXX/XXXXX'; // production

  static String get admobRewardedId => isDevelopment
      ? 'ca-app-pub-3940256099942544/5224354917' // test
      : 'ca-app-pub-XXXXX/XXXXX'; // production

  // ── Server ────────────────────────────────────────────────────────────────
  static String get serverUrl {
    switch (environment) {
      case Environment.development:
        return 'http://localhost:3000';
      case Environment.staging:
        return 'http://staging.lexaro.game:3000';
      case Environment.production:
        return 'http://YOUR_HETZNER_IP:3000';
    }
  }

  static String get wsUrl {
    switch (environment) {
      case Environment.development:
        return 'ws://localhost:3000';
      case Environment.staging:
        return 'ws://staging.lexaro.game:3000';
      case Environment.production:
        return 'ws://YOUR_HETZNER_IP:3000';
    }
  }
}

enum Environment { development, staging, production }

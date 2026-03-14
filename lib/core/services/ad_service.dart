import '../config/app_config.dart';

/// AdMob integration service.
/// Handles rewarded and interstitial ads with frequency capping.
///
/// Rewarded ads: +1 hint or +5 gold
/// Interstitial ads: after 3 puzzles or 2 online matches
class AdService {
  int _puzzlesSinceLastAd = 0;
  int _matchesSinceLastAd = 0;
  bool _rewardedAdLoaded = false;
  bool _interstitialAdLoaded = false;

  static Future<void> initialize() async {
    if (!AppConfig.enableAds) return;
    // Initialize Google Mobile Ads SDK
    // await MobileAds.instance.initialize();
  }

  // ── Rewarded Ads ──────────────────────────────────────────────────────────

  void loadRewardedAd() {
    if (!AppConfig.enableAds) return;
    // Load rewarded ad using AppConfig.admobRewardedId
    _rewardedAdLoaded = true; // Set to true when ad loads
  }

  /// Show rewarded ad. Returns true if reward was earned.
  Future<bool> showRewardedAd() async {
    if (!AppConfig.enableAds || !_rewardedAdLoaded) return false;

    // Show ad and wait for completion
    // RewardedAd.load(adUnitId: AppConfig.admobRewardedId, ...)

    _rewardedAdLoaded = false;
    loadRewardedAd(); // Preload next ad
    return true; // Return true if user completed the ad
  }

  bool get isRewardedAdReady => _rewardedAdLoaded;

  // ── Interstitial Ads ──────────────────────────────────────────────────────

  void loadInterstitialAd() {
    if (!AppConfig.enableAds) return;
    // Load interstitial ad using AppConfig.admobInterstitialId
    _interstitialAdLoaded = true;
  }

  /// Track puzzle completion and show interstitial if threshold reached.
  Future<void> onPuzzleCompleted() async {
    _puzzlesSinceLastAd++;
    if (_puzzlesSinceLastAd >= 3) {
      await _showInterstitialAd();
      _puzzlesSinceLastAd = 0;
    }
  }

  /// Track match completion and show interstitial if threshold reached.
  Future<void> onMatchCompleted() async {
    _matchesSinceLastAd++;
    if (_matchesSinceLastAd >= 2) {
      await _showInterstitialAd();
      _matchesSinceLastAd = 0;
    }
  }

  Future<void> _showInterstitialAd() async {
    if (!AppConfig.enableAds || !_interstitialAdLoaded) return;

    // InterstitialAd.load(adUnitId: AppConfig.admobInterstitialId, ...)

    _interstitialAdLoaded = false;
    loadInterstitialAd(); // Preload next ad
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  void dispose() {
    // Dispose loaded ads
  }
}

// lib/services/ad_service.dart
// Ads disabled — will be re-enabled later with google_mobile_ads
class AdService {
  static Future<void> initialize() async {}
  void loadRewardedAd() {}
  void loadInterstitialAd() {}
  Future<bool> showRewardedAd() async => false;
  void showInterstitialAd() {}
  void dispose() {}
}

// lib/screens/store_screen.dart
// Gold purchase store + rewarded ad option

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../theme/app_theme.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  bool _loadingAd = false;

  // Gold packages: [gold, price label, product id (for IAP)]
  static const _packages = [
    {'gold': 100,  'price': '20 TL',  'product': 'gold_100',  'popular': false},
    {'gold': 200,  'price': '35 TL',  'product': 'gold_200',  'popular': true},
    {'gold': 1000, 'price': '100 TL', 'product': 'gold_1000', 'popular': false},
  ];

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Store',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accent.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, color: AppColors.accent, size: 14),
                const SizedBox(width: 4),
                Text('${game.player.gold}',
                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text('🪙 Gold Packages',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Use gold to reveal hint letters during puzzles.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 20),

            // Gold packages
            ..._packages.map((pkg) => _GoldPackage(
              gold: pkg['gold'] as int,
              price: pkg['price'] as String,
              popular: pkg['popular'] as bool,
              onBuy: () => _buyGold(context, pkg['gold'] as int, pkg['product'] as String),
            )),

            const SizedBox(height: 28),

            // Free gold section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('🎬 Free Gold',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Watch a short ad and earn ${GameProvider.adGoldReward} gold for free!',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _loadingAd ? null : () => _watchAd(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: _loadingAd
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.play_circle_fill_rounded),
                    label: Text(_loadingAd ? 'Loading...' : 'Watch Ad (+${GameProvider.adGoldReward} Gold)'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Daily reward reminder
            if (game.canClaimDaily)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: AppColors.accent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Daily Reward Available!',
                              style: TextStyle(
                                  color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                          Text('+${GameProvider.dailyGold} gold waiting',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        game.claimDailyReward();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✅ +${GameProvider.dailyGold} gold claimed!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Claim'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _buyGold(BuildContext context, int gold, String productId) async {
    // TODO: Integrate real in-app purchase here
    // For now, simulate the purchase
    await context.read<GameProvider>().purchaseGold(gold, productId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ +$gold gold added! (Test mode)'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _watchAd(BuildContext context) async {
    setState(() => _loadingAd = true);
    final earned = await context.read<GameProvider>().watchAdForGold();
    if (!mounted) return;
    setState(() => _loadingAd = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(earned
            ? '✅ +${GameProvider.adGoldReward} gold earned!'
            : '❌ Ad not available. Try again later.'),
        backgroundColor: earned ? AppColors.success : AppColors.error,
      ),
    );
  }
}

class _GoldPackage extends StatelessWidget {
  final int gold;
  final String price;
  final bool popular;
  final VoidCallback onBuy;

  const _GoldPackage({
    required this.gold,
    required this.price,
    required this.popular,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: popular ? AppColors.accent.withOpacity(0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: popular ? AppColors.accent.withOpacity(0.6) : Colors.white.withOpacity(0.08),
          width: popular ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.circle, color: AppColors.accent, size: 28),
        ),
        title: Row(
          children: [
            Text('$gold Gold',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            if (popular) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('BEST VALUE',
                    style: TextStyle(
                        color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        subtitle: Text(price,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        trailing: ElevatedButton(
          onPressed: onBuy,
          style: ElevatedButton.styleFrom(
            backgroundColor: popular ? AppColors.accent : AppColors.primary,
            foregroundColor: popular ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Buy'),
        ),
      ),
    );
  }
}

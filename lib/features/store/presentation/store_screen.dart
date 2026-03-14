import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../providers/game_providers.dart';

/// In-game store for purchasing gold, watching ads, and unlocking cosmetics.
class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  void _purchaseGold(BuildContext context, WidgetRef ref, int amount) {
    ref.read(playerProvider.notifier).addGold(amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('+$amount gold added to your account!'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: AppDecorations.badge(color: AppColors.accent),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on, color: AppColors.accent, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${player.gold}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Free gold section
            _sectionTitle(context, 'Free Gold'),
            const SizedBox(height: 12),
            _buildFreeGoldSection(context),
            const SizedBox(height: 24),

            // Gold packages
            _sectionTitle(context, 'Gold Packages'),
            const SizedBox(height: 12),
            _buildGoldPackages(context, ref),
            const SizedBox(height: 24),

            // Avatars
            _sectionTitle(context, 'Avatars'),
            const SizedBox(height: 12),
            _buildAvatars(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _buildFreeGoldSection(BuildContext context) {
    return Column(
      children: [
        _freeGoldTile(
          context,
          icon: Icons.play_circle_filled_rounded,
          title: 'Watch Ad',
          subtitle: 'Earn +${AppConstants.rewardedAdGold} gold',
          color: AppColors.accent,
          onTap: () {
            // Show rewarded ad
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading ad...')),
            );
          },
        ),
        const SizedBox(height: 8),
        _freeGoldTile(
          context,
          icon: Icons.calendar_today_rounded,
          title: 'Daily Reward',
          subtitle: '+${AppConstants.dailyPuzzleReward} gold (complete daily puzzle)',
          color: AppColors.success,
          onTap: () {},
        ),
        const SizedBox(height: 8),
        _freeGoldTile(
          context,
          icon: Icons.lightbulb_rounded,
          title: 'Free Hint',
          subtitle: 'Watch ad for +1 hint in next puzzle',
          color: AppColors.info,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Loading ad for hint...')),
            );
          },
        ),
      ],
    );
  }

  Widget _freeGoldTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.card(color: color.withAlpha(13)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: color.withAlpha(128), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGoldPackages(BuildContext context, WidgetRef ref) {
    final packages = [
      _GoldPackage('Starter', 100, '\$0.99', AppColors.success),
      _GoldPackage('Popular', 500, '\$3.99', AppColors.primary),
      _GoldPackage('Best Value', 1500, '\$8.99', AppColors.accent),
      _GoldPackage('Pro', 5000, '\$24.99', AppColors.info),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final pkg = packages[index];
        return GestureDetector(
          onTap: () => _purchaseGold(context, ref, pkg.amount),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppDecorations.cardElevated(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (index == 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'POPULAR',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 4),
                Icon(Icons.monetization_on_rounded,
                    color: pkg.color, size: 36),
                const SizedBox(height: 8),
                Text(
                  '${pkg.amount}',
                  style: TextStyle(
                    color: pkg.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'Gold',
                  style: TextStyle(
                      color: pkg.color.withAlpha(179), fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: pkg.color.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: pkg.color.withAlpha(102)),
                  ),
                  child: Text(
                    pkg.price,
                    style: TextStyle(
                      color: pkg.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatars(BuildContext context) {
    final avatars = [
      ('Default', Icons.person, 0, true),
      ('Ninja', Icons.visibility, 100, false),
      ('Crown', Icons.auto_awesome, 250, false),
      ('Robot', Icons.smart_toy, 500, false),
      ('Phoenix', Icons.whatshot, 1000, false),
      ('Diamond', Icons.diamond, 2500, false),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final (name, icon, cost, owned) = avatars[index];
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: AppDecorations.card(
            color: owned ? AppColors.primary.withAlpha(13) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: owned ? AppColors.primary : AppColors.textMuted,
                  size: 32),
              const SizedBox(height: 6),
              Text(
                name,
                style: TextStyle(
                  color: owned ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (owned)
                const Text('Owned',
                    style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w600))
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on,
                        color: AppColors.accent, size: 12),
                    const SizedBox(width: 2),
                    Text(
                      '$cost',
                      style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GoldPackage {
  final String name;
  final int amount;
  final String price;
  final Color color;

  const _GoldPackage(this.name, this.amount, this.price, this.color);
}

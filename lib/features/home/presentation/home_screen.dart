import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/models/puzzle_model.dart';
import '../../puzzle/presentation/puzzle_screen.dart';

/// Main home screen with game mode selection, player info, and navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Difficulty _selectedDifficulty = Difficulty.medium;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildPlayerCard(context),
              const SizedBox(height: 24),
              _buildDifficultySelector(context),
              const SizedBox(height: 24),
              _buildPlayButton(context),
              const SizedBox(height: 16),
              _buildMultiplayerButton(context),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildNavigationGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LEXARO',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    letterSpacing: 3,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text(
              'Word Puzzle Battle',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Row(
          children: [
            // Gold display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: AppDecorations.badge(color: AppColors.accent),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on,
                      color: AppColors.accent, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${AppConstants.startingGold}',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.settings),
              icon: const Icon(Icons.settings_rounded,
                  color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.cardElevated(),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Player',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: AppDecorations.badge(
                        color: AppDecorations.leagueColor('Bronze'),
                      ),
                      child: Text(
                        'Bronze',
                        style: TextStyle(
                          color: AppDecorations.leagueColor('Bronze'),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '0 pts',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('0W / 0L',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text('0 solved',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(BuildContext context) {
    return Row(
      children: Difficulty.values.map((d) {
        final selected = d == _selectedDifficulty;
        final color = AppDecorations.difficultyColor(d.name);
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDifficulty = d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? color.withAlpha(51) : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? color : Colors.white.withAlpha(26),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    selected ? Icons.star : Icons.star_border,
                    color: selected ? color : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d.label,
                    style: TextStyle(
                      color: selected ? color : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.02);
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: Container(
              decoration: AppDecorations.neonButton(color: AppColors.primary),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.puzzle,
                    arguments: PuzzleScreenArgs(
                      difficulty: _selectedDifficulty,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'PLAY',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultiplayerButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () =>
            Navigator.pushNamed(context, AppRouter.matchmaking),
        icon: const Icon(Icons.people_rounded),
        label: const Text('ONLINE MATCH'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.accent.withAlpha(128)),
          foregroundColor: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _quickAction(
          context,
          icon: Icons.calendar_today_rounded,
          label: 'Daily\nPuzzle',
          color: AppColors.success,
          onTap: () =>
              Navigator.pushNamed(context, AppRouter.dailyPuzzle),
        ),
        const SizedBox(width: 12),
        _quickAction(
          context,
          icon: Icons.card_giftcard_rounded,
          label: 'Free\nGold',
          color: AppColors.accent,
          onTap: () => Navigator.pushNamed(context, AppRouter.store),
        ),
        const SizedBox(width: 12),
        _quickAction(
          context,
          icon: Icons.emoji_events_rounded,
          label: 'Achieve-\nments',
          color: AppColors.info,
          onTap: () =>
              Navigator.pushNamed(context, AppRouter.achievements),
        ),
      ],
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: AppDecorations.card(color: color.withAlpha(20)),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationGrid(BuildContext context) {
    return Row(
      children: [
        _navTile(
          context,
          icon: Icons.leaderboard_rounded,
          label: 'Leaderboard',
          onTap: () =>
              Navigator.pushNamed(context, AppRouter.leaderboard),
        ),
        const SizedBox(width: 12),
        _navTile(
          context,
          icon: Icons.store_rounded,
          label: 'Store',
          onTap: () => Navigator.pushNamed(context, AppRouter.store),
        ),
      ],
    );
  }

  Widget _navTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card(),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryLight, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

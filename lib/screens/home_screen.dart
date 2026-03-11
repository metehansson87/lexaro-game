// lib/screens/home_screen.dart
// Main menu: play, leaderboard, store, sound toggle, daily reward banner

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/game_provider.dart';
import '../models/puzzle_model.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Difficulty _selected = Difficulty.medium;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDailyReward();
    });
  }

  Future<void> _checkDailyReward() async {
    final game = context.read<GameProvider>();
    if (game.canClaimDaily) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _showDailyRewardDialog();
    }
  }

  void _showDailyRewardDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎁 Daily Reward!',
            style: TextStyle(color: AppColors.textPrimary), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.circle, color: AppColors.accent, size: 48),
            const SizedBox(height: 12),
            Text(
              '+${GameProvider.dailyGold} Gold',
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Come back tomorrow for more!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<GameProvider>().claimDailyReward();
                Navigator.pop(ctx);
              },
              child: const Text('Claim!'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // ── Top bar ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gold balance
                  _GoldBadge(gold: game.player.gold),

                  // Sound toggle
                  GestureDetector(
                    onTap: () => game.toggleSound(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: AppDecor.card(),
                      child: Icon(
                        game.audio.soundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: game.audio.soundEnabled
                            ? AppColors.primaryLight
                            : AppColors.textMuted,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Logo / Title ───────────────────────────────────────────
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.gamepad_rounded, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'GameGuess',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Guess the video game title!',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

              const SizedBox(height: 36),

              // ── Player info ────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecor.card(),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: const Icon(Icons.person, color: AppColors.primaryLight, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(game.player.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600)),
                          Text('${game.player.league} League • ${game.player.totalScore} pts',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    _LeagueBadge(league: game.player.league),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              // ── Difficulty selector ────────────────────────────────────
              const Text('Select Difficulty',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(
                children: Difficulty.values.map((d) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _DifficultyCard(
                      difficulty: d,
                      selected: _selected == d,
                      onTap: () => setState(() => _selected = d),
                    ),
                  ),
                )).toList(),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 28),

              // ── Play button ────────────────────────────────────────────
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GameScreen(difficulty: _selected),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, size: 26),
                    SizedBox(width: 8),
                    Text('Play', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).scaleXY(begin: 0.95),

              const SizedBox(height: 16),

              // ── Secondary actions ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _SecondaryButton(
                      icon: Icons.leaderboard_rounded,
                      label: 'Leaderboard',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SecondaryButton(
                      icon: Icons.store_rounded,
                      label: 'Store',
                      color: AppColors.accent,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const StoreScreen())),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _GoldBadge extends StatelessWidget {
  final int gold;
  const _GoldBadge({required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, color: AppColors.accent, size: 16),
          const SizedBox(width: 6),
          Text('$gold',
              style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }
}

class _LeagueBadge extends StatelessWidget {
  final String league;
  const _LeagueBadge({required this.league});

  Color get color {
    switch (league) {
      case 'Diamond': return Colors.cyanAccent;
      case 'Gold':    return AppColors.accent;
      case 'Silver':  return Colors.grey.shade300;
      default:        return Colors.brown.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(league, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final Difficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyCard({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  Color get _color {
    switch (difficulty) {
      case Difficulty.easy:   return AppColors.easy;
      case Difficulty.medium: return AppColors.medium;
      case Difficulty.hard:   return AppColors.hard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? _color.withOpacity(0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _color : Colors.white.withOpacity(0.08),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(difficulty.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(difficulty.label,
                style: TextStyle(
                  color: selected ? _color : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
            Text('+${difficulty.points}pt',
                style: TextStyle(
                  color: selected ? _color.withOpacity(0.7) : AppColors.textMuted,
                  fontSize: 10,
                )),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
          ],
        ),
      ),
    );
  }
}

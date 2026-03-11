// lib/widgets/game_hud.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../models/puzzle_model.dart';
import '../theme/app_theme.dart';

class GameHud extends StatelessWidget {
  const GameHud({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final timeLeft = game.timeLeft;
    final progress = timeLeft / GameProvider.roundDuration;
    final isLow = timeLeft <= 10;
    final timerColor = timeLeft > 10
        ? AppColors.success
        : timeLeft > 5
            ? AppColors.medium
            : AppColors.error;

    return Row(
      children: [
        // Timer with heartbeat
        _HeartbeatTimer(
          timeLeft: timeLeft,
          progress: progress,
          timerColor: timerColor,
          isLow: isLow,
        ),
        const SizedBox(width: 10),

        // Difficulty badge — tappable
        GestureDetector(
          onTap: () => _showDifficultyPicker(context, game),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _diffColor(game.selectedDifficulty).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _diffColor(game.selectedDifficulty).withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_diffEmoji(game.selectedDifficulty)} ${game.selectedDifficulty.label}',
                  style: TextStyle(
                    color: _diffColor(game.selectedDifficulty),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_drop_down,
                    color: _diffColor(game.selectedDifficulty), size: 16),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Score — taps to leaderboard
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/leaderboard'),
          child: _StatChip(
            icon: Icons.star_rounded,
            iconColor: AppColors.accent,
            value: '${game.player.totalScore}',
            label: 'Score',
          ),
        ),
        const SizedBox(width: 8),

        // Gold — taps to store
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/store'),
          child: _StatChip(
            icon: Icons.circle,
            iconColor: AppColors.accent,
            value: '${game.player.gold}',
            label: 'Gold',
          ),
        ),
      ],
    );
  }

  void _showDifficultyPicker(BuildContext context, GameProvider game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Difficulty',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Starting a new puzzle in selected difficulty',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ...Difficulty.values.map((d) => _DiffOption(
              difficulty: d,
              selected: game.selectedDifficulty == d,
              onTap: () {
                Navigator.pop(ctx);
                game.startRound(d);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  String _diffEmoji(Difficulty d) => d.emoji;

  Color _diffColor(Difficulty d) {
    switch (d) {
      case Difficulty.easy:   return AppColors.easy;
      case Difficulty.medium: return AppColors.medium;
      case Difficulty.hard:   return AppColors.hard;
    }
  }
}

class _DiffOption extends StatelessWidget {
  final Difficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  const _DiffOption({
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _color.withOpacity(0.15) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _color : Colors.white.withOpacity(0.08),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(difficulty.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty.label,
                    style: TextStyle(
                      color: selected ? _color : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '+${difficulty.points} points per puzzle',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: _color, size: 22),
          ],
        ),
      ),
    );
  }
}

// Heartbeat timer
class _HeartbeatTimer extends StatefulWidget {
  final int timeLeft;
  final double progress;
  final Color timerColor;
  final bool isLow;

  const _HeartbeatTimer({
    required this.timeLeft,
    required this.progress,
    required this.timerColor,
    required this.isLow,
  });

  @override
  State<_HeartbeatTimer> createState() => _HeartbeatTimerState();
}

class _HeartbeatTimerState extends State<_HeartbeatTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_HeartbeatTimer old) {
    super.didUpdateWidget(old);
    if (widget.isLow && widget.timeLeft != old.timeLeft) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: SizedBox(
        width: 52,
        height: 52,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: widget.progress,
              strokeWidth: 4,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation(widget.timerColor),
            ),
            Text(
              '${widget.timeLeft}',
              style: TextStyle(
                color: widget.timerColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: AppDecor.card(),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 14),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

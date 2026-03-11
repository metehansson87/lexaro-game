// lib/widgets/game_keyboard.dart
// On-screen keyboard that dynamically enables only the letters present in the answer.
// Tracks letter usage counts and fades/disables used-up letters.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../theme/app_theme.dart';

const _rows = [
  ['Q','W','E','R','T','Y','U','I','O','P'],
  ['A','S','D','F','G','H','J','K','L'],
  ['Z','X','C','V','B','N','M'],
];

class GameKeyboard extends StatelessWidget {
  const GameKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return ClipRect(
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Letter rows
        ..._rows.map((row) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((letter) => _KeyButton(
              letter: letter,
              available: game.isLetterAvailable(letter),
              onTap: () => game.enterLetter(letter),
            )).toList(),
          ),
        )),

        // Bottom action row: Hint | Shuffle | Backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hint (sol tarafa taşındı)
            _HintButton(
              gold: game.player.gold,
              canHint: game.canUseHint,
              onTap: game.useHint,
            ),
            const SizedBox(width: 8),

            // Shuffle (wide, like space bar)
            Expanded(
              child: _ShuffleButton(onTap: game.shuffleKeyboard),
            ),
            const SizedBox(width: 8),

            // Backspace (sağ tarafa taşındı)
            _ActionButton(
              icon: Icons.backspace_outlined,
              label: 'Del',
              onTap: game.deleteLetter,
              color: AppColors.error.withOpacity(0.8),
            ),
          ],
        ),
      ],
      ),
    );
  }
}

// Individual letter key
class _KeyButton extends StatelessWidget {
  final String letter;
  final bool available;
  final VoidCallback onTap;

  const _KeyButton({
    required this.letter,
    required this.available,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: available ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: 30,
        height: 42,
        decoration: BoxDecoration(
          color: available ? AppColors.keyActive : AppColors.keyInactive,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: available
                ? AppColors.primary.withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
          ),
          boxShadow: available
              ? [BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2))]
              : null,
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: available
                  ? AppColors.textPrimary
                  : AppColors.textMuted.withOpacity(0.3),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Backspace / action buttons
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            Text(label, style: TextStyle(color: color, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// Wide Shuffle button
class _ShuffleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ShuffleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.25),
              AppColors.primaryLight.withOpacity(0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shuffle_rounded,
                color: AppColors.primaryLight, size: 16),
            const SizedBox(width: 6),
            const Text(
              'Shuffle',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Hint button showing gold cost
class _HintButton extends StatelessWidget {
  final int gold;
  final bool canHint;
  final VoidCallback onTap;

  const _HintButton({
    required this.gold,
    required this.canHint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canHint ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 58,
        height: 42,
        decoration: BoxDecoration(
          color: canHint
              ? AppColors.accent.withOpacity(0.15)
              : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: canHint
                ? AppColors.accent.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline,
                color: canHint ? AppColors.accent : Colors.grey, size: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, color: AppColors.accent, size: 7),
                const SizedBox(width: 2),
                Text(
                  '1',
                  style: TextStyle(
                    color: canHint ? AppColors.accent : Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

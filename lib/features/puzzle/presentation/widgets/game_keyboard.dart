import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/puzzle_model.dart';

/// On-screen game keyboard that only enables letters present in the answer.
/// Tracks letter usage to prevent over-placement.
class GameKeyboard extends StatelessWidget {
  final PuzzleModel puzzle;
  final List<String?> currentLetters;
  final void Function(String letter) onLetterTap;
  final VoidCallback onDelete;
  final VoidCallback onHint;
  final VoidCallback onShuffle;
  final int hintsRemaining;

  const GameKeyboard({
    super.key,
    required this.puzzle,
    required this.currentLetters,
    required this.onLetterTap,
    required this.onDelete,
    required this.onHint,
    required this.onShuffle,
    this.hintsRemaining = AppConstants.maxHintsPerRound,
  });

  static const List<String> _row1 = ['Q','W','E','R','T','Y','U','I','O','P'];
  static const List<String> _row2 = ['A','S','D','F','G','H','J','K','L'];
  static const List<String> _row3 = ['Z','X','C','V','B','N','M'];

  @override
  Widget build(BuildContext context) {
    final availableLetters = puzzle.letterCounts;
    final usedCounts = <String, int>{};
    for (final l in currentLetters) {
      if (l != null) {
        usedCounts[l] = (usedCounts[l] ?? 0) + 1;
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(15)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Action bar
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(
                    icon: Icons.lightbulb_rounded,
                    label: 'Hint ($hintsRemaining)',
                    color: AppColors.accent,
                    onTap: hintsRemaining > 0 ? onHint : null,
                  ),
                  const SizedBox(width: 12),
                  _actionButton(
                    icon: Icons.shuffle_rounded,
                    label: 'Shuffle',
                    color: AppColors.primaryLight,
                    onTap: onShuffle,
                  ),
                  const SizedBox(width: 12),
                  _actionButton(
                    icon: Icons.backspace_rounded,
                    label: 'Delete',
                    color: AppColors.error,
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
            // Keyboard rows
            _buildRow(_row1, availableLetters, usedCounts),
            const SizedBox(height: 4),
            _buildRow(_row2, availableLetters, usedCounts),
            const SizedBox(height: 4),
            _buildRow(_row3, availableLetters, usedCounts),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    List<String> letters,
    Map<String, int> availableLetters,
    Map<String, int> usedCounts,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) {
        final maxCount = availableLetters[letter] ?? 0;
        final usedCount = usedCounts[letter] ?? 0;
        final isAvailable = maxCount > 0;
        final canPlace = usedCount < maxCount;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: SizedBox(
            width: 32,
            height: 42,
            child: Material(
              color: !isAvailable
                  ? AppColors.keyInactive
                  : canPlace
                      ? AppColors.keyActive
                      : AppColors.keyInactive,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: isAvailable && canPlace ? () => onLetterTap(letter) : null,
                borderRadius: BorderRadius.circular(6),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: !isAvailable
                          ? AppColors.textDisabled
                          : canPlace
                              ? AppColors.textPrimary
                              : AppColors.textDisabled,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? color.withAlpha(26) : AppColors.keyInactive,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled ? color.withAlpha(102) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: enabled ? color : AppColors.textDisabled),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: enabled ? color : AppColors.textDisabled,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../data/models/puzzle_model.dart';

/// Responsive answer box display that groups multi-word answers
/// and auto-resizes based on word length. Never goes under keyboard.
class AnswerBoxes extends StatelessWidget {
  final PuzzleModel puzzle;
  final List<String?> answerLetters;
  final Set<int> hintIndices;
  final bool solved;

  const AnswerBoxes({
    super.key,
    required this.puzzle,
    required this.answerLetters,
    required this.hintIndices,
    this.solved = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 32;
    final words = puzzle.words;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _buildWordRows(words, screenWidth),
    );
  }

  List<Widget> _buildWordRows(List<String> words, double maxWidth) {
    final rows = <Widget>[];
    int letterIndex = 0;

    for (int w = 0; w < words.length; w++) {
      final wordLength = words[w].length;
      final boxSize = _calculateBoxSize(wordLength, maxWidth);

      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: List.generate(wordLength, (i) {
              final idx = letterIndex + i;
              final letter = idx < answerLetters.length ? answerLetters[idx] : null;
              final isHint = hintIndices.contains(idx);
              final isFilled = letter != null;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: boxSize,
                  height: boxSize,
                  decoration: solved
                      ? BoxDecoration(
                          color: AppColors.success.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.success),
                        )
                      : AppDecorations.letterBox(
                          selected: false,
                          filled: isFilled,
                          hint: isHint,
                        ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        letter ?? '',
                        key: ValueKey('$idx-$letter'),
                        style: TextStyle(
                          color: solved
                              ? AppColors.success
                              : isHint
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: boxSize * 0.45,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );

      letterIndex += wordLength;
    }

    return rows;
  }

  /// Calculate box size based on word length and available width.
  /// Ensures boxes never overflow the screen.
  double _calculateBoxSize(int wordLength, double maxWidth) {
    final maxBoxWidth = (maxWidth - (wordLength * 4)) / wordLength;
    const idealSize = 44.0;
    const minSize = 28.0;

    if (idealSize * wordLength + (wordLength * 4) <= maxWidth) {
      return idealSize;
    }
    return maxBoxWidth.clamp(minSize, idealSize);
  }
}

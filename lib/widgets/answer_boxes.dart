// lib/widgets/answer_boxes.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/game_provider.dart';
import '../models/puzzle_model.dart';
import '../theme/app_theme.dart';

String _scrambleWord(String word) {
  final chars = word.split('');
  for (int i = 0; i < 10; i++) {
    chars.shuffle(Random());
    if (chars.join() != word) break;
  }
  return chars.join();
}

class AnswerBoxes extends StatefulWidget {
  const AnswerBoxes({super.key});
  @override
  State<AnswerBoxes> createState() => _AnswerBoxesState();
}

class _AnswerBoxesState extends State<AnswerBoxes> {
  String? _lastPuzzleId;
  List<String> _scrambledWords = [];
  int _lastShuffleCount = -1;

  void _updateScramble(List<String> words, String puzzleId, int shuffleCount) {
    if (_lastPuzzleId != puzzleId || _lastShuffleCount != shuffleCount) {
      _lastPuzzleId = puzzleId;
      _lastShuffleCount = shuffleCount;
      _scrambledWords = words.map(_scrambleWord).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final puzzle = game.puzzle;
    if (puzzle == null) return const SizedBox();

    final words = puzzle.words;
    _updateScramble(words, puzzle.id, game.shuffleCount);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // Calculate box size that fits the longest word on one row
        final longestWordLen = words.map((w) => w.length).reduce(max);
        // spacing between boxes = 5, padding on sides = 0
        // boxWidth * count + 5 * (count-1) <= maxWidth
        double boxW = ((maxWidth - 5 * (longestWordLen - 1)) / longestWordLen)
            .clamp(22.0, 38.0);
        double boxH = (boxW * 42 / 36).clamp(26.0, 44.0);
        double fontSize = (boxW * 0.5).clamp(11.0, 18.0);

        int boxIndex = 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Text(
                puzzle.category.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Scrambled: each word on its own row
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  const Text(
                    'SCRAMBLED',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(_scrambledWords.length, (wi) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _scrambledWords[wi]
                            .split('')
                            .map((ch) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: _ScrambledBox(
                                    letter: ch,
                                    width: boxW * 0.8,
                                    height: boxH * 0.8,
                                    fontSize: fontSize * 0.85,
                                  ),
                                ))
                            .toList(),
                      ),
                    );
                  }),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 16),

            // YOUR ANSWER label
            const Text(
              'YOUR ANSWER',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),

            // Answer boxes: each word on its own row, all fit on screen
            ...words.map((word) {
              final wordBoxes = <Widget>[];
              for (int i = 0; i < word.length; i++) {
                final idx = boxIndex;
                final letter = game.boxes.length > idx ? game.boxes[idx] : '';
                final isSelected = game.selectedBox == idx;
                final isFilled = letter.isNotEmpty;
                wordBoxes.add(
                  _LetterBox(
                    letter: letter,
                    isSelected: isSelected,
                    isFilled: isFilled,
                    width: boxW,
                    height: boxH,
                    fontSize: fontSize,
                    onTap: () => game.selectBox(idx),
                  ),
                );
                boxIndex++;
              }
              boxIndex++; // skip space

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: wordBoxes
                      .map((b) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5),
                            child: b,
                          ))
                      .toList(),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

class _LetterBox extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isFilled;
  final double width;
  final double height;
  final double fontSize;
  final VoidCallback onTap;

  const _LetterBox({
    required this.letter,
    required this.isSelected,
    required this.isFilled,
    required this.width,
    required this.height,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: AppDecor.letterBox(selected: isSelected, filled: isFilled),
        child: Center(
          child: Text(
            letter.toUpperCase(),
            style: TextStyle(
              color: isSelected
                  ? AppColors.primaryLight
                  : isFilled
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ).animate(target: isFilled ? 1 : 0)
          .scaleXY(begin: 1, end: 1.08, duration: 100.ms)
          .then()
          .scaleXY(begin: 1.08, end: 1, duration: 100.ms),
    );
  }
}

class _ScrambledBox extends StatelessWidget {
  final String letter;
  final double width;
  final double height;
  final double fontSize;
  const _ScrambledBox({
    required this.letter,
    required this.width,
    required this.height,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            color: AppColors.primaryLight,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

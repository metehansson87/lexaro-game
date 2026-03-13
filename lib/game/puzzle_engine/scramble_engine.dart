import 'dart:math';
import '../../data/models/puzzle_model.dart';

/// Engine responsible for scrambling puzzle words and validating answers.
class ScrambleEngine {
  final Random _random = Random();

  /// Scramble all letters of a puzzle word (spaces removed).
  /// Guarantees the result differs from the original.
  String scramble(String word) {
    final normalized = word.replaceAll(' ', '').toUpperCase();
    if (normalized.length <= 1) return normalized;

    final chars = normalized.split('');
    for (int attempt = 0; attempt < 50; attempt++) {
      chars.shuffle(_random);
      if (chars.join() != normalized) break;
    }
    return chars.join();
  }

  /// Validate a player's answer against the puzzle.
  bool validateAnswer(PuzzleModel puzzle, String playerAnswer) {
    final normalized = playerAnswer.replaceAll(' ', '').toUpperCase().trim();
    return normalized == puzzle.normalizedAnswer;
  }

  /// Reveal a single letter hint at a random unrevealed position.
  /// Returns the index and letter to reveal, or null if fully revealed.
  HintResult? revealHint({
    required PuzzleModel puzzle,
    required List<String?> currentLetters,
  }) {
    final answer = puzzle.normalizedAnswer;
    final unrevealed = <int>[];

    for (int i = 0; i < answer.length; i++) {
      if (i >= currentLetters.length || currentLetters[i] == null) {
        unrevealed.add(i);
      }
    }

    if (unrevealed.isEmpty) return null;

    final index = unrevealed[_random.nextInt(unrevealed.length)];
    return HintResult(index: index, letter: answer[index]);
  }

  /// Get the available letters for the keyboard based on the puzzle.
  Set<String> availableLetters(PuzzleModel puzzle) {
    return puzzle.normalizedAnswer.split('').toSet();
  }

  /// Check if a letter can still be placed (respects letter frequency).
  bool canPlaceLetter({
    required String letter,
    required PuzzleModel puzzle,
    required List<String?> currentLetters,
  }) {
    final maxCount = puzzle.letterCounts[letter.toUpperCase()] ?? 0;
    final currentCount =
        currentLetters.where((l) => l?.toUpperCase() == letter.toUpperCase()).length;
    return currentCount < maxCount;
  }
}

/// Result of a hint reveal operation.
class HintResult {
  final int index;
  final String letter;

  const HintResult({required this.index, required this.letter});
}

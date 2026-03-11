// lib/models/puzzle_model.dart
// Core data model for a puzzle (game title to guess)

class PuzzleModel {
  final String id;
  final String answer;       // e.g. "TOMB RAIDER"
  final String category;     // e.g. "Action", "RPG"
  final Difficulty difficulty;
  final String? hint;        // Optional flavor hint text

  const PuzzleModel({
    required this.id,
    required this.answer,
    required this.category,
    required this.difficulty,
    this.hint,
  });

  // Points awarded for this puzzle
  int get points => difficulty.points;

  // Letters in answer (uppercase, no spaces)
  String get answerLetters => answer.replaceAll(' ', '').toUpperCase();

  // Words split for multi-word display
  List<String> get words => answer.toUpperCase().split(' ');

  // Count how many times each letter appears
  Map<String, int> get letterCounts {
    final counts = <String, int>{};
    for (final char in answerLetters.split('')) {
      counts[char] = (counts[char] ?? 0) + 1;
    }
    return counts;
  }
}

enum Difficulty {
  easy,
  medium,
  hard;

  int get points {
    switch (this) {
      case Difficulty.easy:   return 5;
      case Difficulty.medium: return 10;
      case Difficulty.hard:   return 20;
    }
  }

  String get label {
    switch (this) {
      case Difficulty.easy:   return 'Easy';
      case Difficulty.medium: return 'Medium';
      case Difficulty.hard:   return 'Hard';
    }
  }

  String get emoji {
    switch (this) {
      case Difficulty.easy:   return '🟢';
      case Difficulty.medium: return '🟡';
      case Difficulty.hard:   return '🔴';
    }
  }
}

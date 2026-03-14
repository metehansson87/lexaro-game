/// Core puzzle data model representing a single word puzzle.
class PuzzleModel {
  final String id;
  final String word;
  final String category;
  final Difficulty difficulty;
  final String language;
  final String? hint;

  const PuzzleModel({
    required this.id,
    required this.word,
    required this.category,
    required this.difficulty,
    this.language = 'en',
    this.hint,
  });

  /// Points awarded for solving this puzzle.
  int get points => difficulty.points;

  /// Normalized answer: uppercase, no spaces.
  String get normalizedAnswer => word.replaceAll(' ', '').toUpperCase();

  /// Individual words for multi-word display.
  List<String> get words => word.toUpperCase().split(' ').where((w) => w.isNotEmpty).toList();

  /// Total letter count (excluding spaces).
  int get letterCount => normalizedAnswer.length;

  /// Letter frequency map for the answer.
  Map<String, int> get letterCounts {
    final counts = <String, int>{};
    for (final char in normalizedAnswer.split('')) {
      counts[char] = (counts[char] ?? 0) + 1;
    }
    return counts;
  }

  /// Whether this is a multi-word puzzle.
  bool get isMultiWord => word.contains(' ');

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'word': word,
        'category': category,
        'difficulty': difficulty.name,
        'language': language,
        'hint': hint,
      };

  factory PuzzleModel.fromJson(Map<String, dynamic> json) => PuzzleModel(
        id: json['id'] as String,
        word: json['word'] as String,
        category: json['category'] as String,
        difficulty: Difficulty.fromString(json['difficulty'] as String),
        language: json['language'] as String? ?? 'en',
        hint: json['hint'] as String?,
      );
}

/// Puzzle difficulty levels with associated point values.
enum Difficulty {
  easy,
  medium,
  hard;

  int get points {
    switch (this) {
      case Difficulty.easy:
        return 5;
      case Difficulty.medium:
        return 10;
      case Difficulty.hard:
        return 20;
    }
  }

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  String get icon {
    switch (this) {
      case Difficulty.easy:
        return '1';
      case Difficulty.medium:
        return '2';
      case Difficulty.hard:
        return '3';
    }
  }

  static Difficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hard':
        return Difficulty.hard;
      case 'medium':
        return Difficulty.medium;
      default:
        return Difficulty.easy;
    }
  }
}

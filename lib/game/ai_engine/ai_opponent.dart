import 'dart:async';
import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../data/models/puzzle_model.dart';

/// Server-side AI opponent that simulates human-like behavior.
/// Runs locally for offline play, server-side for online matches.
class AiOpponent {
  final AiDifficulty difficulty;
  final Random _random = Random();
  Timer? _solveTimer;
  Timer? _hintTimer;

  AiOpponent({required this.difficulty});

  // Callbacks
  void Function(String answer)? onAnswer;
  void Function()? onHintUsed;
  void Function(String wrongAnswer)? onWrongAnswer;

  // ── Configuration Per Difficulty ──────────────────────────────────────────

  int get _minDelayMs {
    switch (difficulty) {
      case AiDifficulty.easy:
        return AppConstants.aiMinDelayEasy;
      case AiDifficulty.medium:
        return AppConstants.aiMinDelayMedium;
      case AiDifficulty.hard:
        return AppConstants.aiMinDelayHard;
    }
  }

  int get _maxDelayMs {
    switch (difficulty) {
      case AiDifficulty.easy:
        return AppConstants.aiMaxDelayEasy;
      case AiDifficulty.medium:
        return AppConstants.aiMaxDelayMedium;
      case AiDifficulty.hard:
        return AppConstants.aiMaxDelayHard;
    }
  }

  /// Probability of solving the puzzle (0.0 - 1.0).
  double get _solveChance {
    switch (difficulty) {
      case AiDifficulty.easy:
        return 0.4;
      case AiDifficulty.medium:
        return 0.65;
      case AiDifficulty.hard:
        return 0.85;
    }
  }

  /// Probability of making a mistake before correct answer.
  double get _mistakeChance {
    switch (difficulty) {
      case AiDifficulty.easy:
        return 0.3;
      case AiDifficulty.medium:
        return 0.15;
      case AiDifficulty.hard:
        return 0.05;
    }
  }

  /// Probability of using a hint.
  double get _hintChance {
    switch (difficulty) {
      case AiDifficulty.easy:
        return 0.4;
      case AiDifficulty.medium:
        return 0.2;
      case AiDifficulty.hard:
        return 0.1;
    }
  }

  int _hintsUsed = 0;

  int get hintsUsed => _hintsUsed;

  // ── Behavior ──────────────────────────────────────────────────────────────

  /// Start the AI's attempt to solve a puzzle.
  void startSolving(PuzzleModel puzzle) {
    _hintsUsed = 0;
    _cancelTimers();

    final willSolve = _random.nextDouble() < _solveChance;
    final solveDelay = _minDelayMs + _random.nextInt(_maxDelayMs - _minDelayMs);

    // Possibly use hints before solving
    _scheduleHints(puzzle, solveDelay);

    // Possibly make a mistake first
    if (_random.nextDouble() < _mistakeChance) {
      final mistakeDelay = solveDelay ~/ 3 + _random.nextInt(solveDelay ~/ 3);
      Timer(Duration(milliseconds: mistakeDelay), () {
        final wrongAnswer = _generateWrongAnswer(puzzle);
        onWrongAnswer?.call(wrongAnswer);
      });
    }

    if (willSolve) {
      _solveTimer = Timer(Duration(milliseconds: solveDelay), () {
        onAnswer?.call(puzzle.word.toUpperCase());
      });
    }
  }

  /// Schedule hint usage during solving.
  void _scheduleHints(PuzzleModel puzzle, int totalDelay) {
    if (_random.nextDouble() >= _hintChance) return;

    final hintCount = 1 + _random.nextInt(3);
    for (int i = 0; i < hintCount; i++) {
      final hintDelay = (totalDelay * (0.2 + 0.15 * i)).toInt();
      Timer(Duration(milliseconds: hintDelay), () {
        if (_hintsUsed < AppConstants.maxHintsPerRound) {
          _hintsUsed++;
          onHintUsed?.call();
        }
      });
    }
  }

  /// Generate a plausible wrong answer by scrambling letters.
  String _generateWrongAnswer(PuzzleModel puzzle) {
    final chars = puzzle.normalizedAnswer.split('');
    chars.shuffle(_random);
    // Take a subset to make it look like a real attempt
    final length = (chars.length * 0.7).ceil();
    return chars.take(length).join();
  }

  /// Stop the AI from solving (round ended or match cancelled).
  void stop() {
    _cancelTimers();
  }

  void _cancelTimers() {
    _solveTimer?.cancel();
    _solveTimer = null;
    _hintTimer?.cancel();
    _hintTimer = null;
  }

  void dispose() {
    _cancelTimers();
  }
}

enum AiDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case AiDifficulty.easy:
        return 'Easy';
      case AiDifficulty.medium:
        return 'Medium';
      case AiDifficulty.hard:
        return 'Hard';
    }
  }

  static AiDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hard':
        return AiDifficulty.hard;
      case 'medium':
        return AiDifficulty.medium;
      default:
        return AiDifficulty.easy;
    }
  }
}

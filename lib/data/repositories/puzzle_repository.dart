import 'dart:math';
import '../models/puzzle_model.dart';
import '../../game/puzzle_engine/puzzle_database.dart';
import '../../core/utils/date_utils.dart';

/// Repository for puzzle data access and selection logic.
class PuzzleRepository {
  final Random _random = Random();

  /// Get all puzzles for a specific language and difficulty.
  List<PuzzleModel> getPuzzles({
    required String language,
    required Difficulty difficulty,
  }) {
    return PuzzleDatabase.getPuzzles(language: language, difficulty: difficulty);
  }

  /// Get the next unsolved puzzle for a given difficulty and language.
  PuzzleModel? getNextPuzzle({
    required String language,
    required Difficulty difficulty,
    required Set<String> solvedIds,
  }) {
    final puzzles = getPuzzles(language: language, difficulty: difficulty);
    final unsolved = puzzles.where((p) => !solvedIds.contains(p.id)).toList();

    if (unsolved.isEmpty) return null;
    return unsolved[_random.nextInt(unsolved.length)];
  }

  /// Get today's daily puzzle (deterministic, same worldwide).
  PuzzleModel getDailyPuzzle({required String language}) {
    final seed = AppDateUtils.dailySeed();
    final allPuzzles = PuzzleDatabase.getAllPuzzles(language: language);
    if (allPuzzles.isEmpty) {
      return PuzzleDatabase.getAllPuzzles(language: 'en')[0];
    }
    final index = seed % allPuzzles.length;
    return allPuzzles[index];
  }

  /// Get a random puzzle for multiplayer matches.
  PuzzleModel getMatchPuzzle({
    required String language,
    required Difficulty difficulty,
    List<String> excludeIds = const [],
  }) {
    final puzzles = getPuzzles(language: language, difficulty: difficulty)
        .where((p) => !excludeIds.contains(p.id))
        .toList();

    if (puzzles.isEmpty) {
      return getPuzzles(language: language, difficulty: difficulty).first;
    }
    return puzzles[_random.nextInt(puzzles.length)];
  }

  /// Get total puzzle count for a language.
  int getPuzzleCount({required String language}) {
    return PuzzleDatabase.getAllPuzzles(language: language).length;
  }

  /// Validate an answer against a puzzle.
  bool validateAnswer(PuzzleModel puzzle, String answer) {
    return puzzle.normalizedAnswer == answer.replaceAll(' ', '').toUpperCase();
  }
}

import '../../data/models/puzzle_model.dart';
import 'puzzles_en.dart';
import 'puzzles_tr.dart';
import 'puzzles_de.dart';
import 'puzzles_it.dart';
import 'puzzles_fr.dart';
import 'puzzles_es.dart';

/// Central puzzle database providing access to 1000+ puzzles across 6 languages.
class PuzzleDatabase {
  PuzzleDatabase._();

  static final Map<String, List<PuzzleModel>> _cache = {};

  /// Get all puzzles for a specific language.
  static List<PuzzleModel> getAllPuzzles({required String language}) {
    if (_cache.containsKey(language)) return _cache[language]!;

    final puzzles = _loadPuzzlesForLanguage(language);
    _cache[language] = puzzles;
    return puzzles;
  }

  /// Get puzzles filtered by language and difficulty.
  static List<PuzzleModel> getPuzzles({
    required String language,
    required Difficulty difficulty,
  }) {
    return getAllPuzzles(language: language)
        .where((p) => p.difficulty == difficulty)
        .toList();
  }

  /// Get total puzzle count across all languages.
  static int get totalPuzzleCount {
    int count = 0;
    for (final lang in ['en', 'tr', 'de', 'it', 'fr', 'es']) {
      count += getAllPuzzles(language: lang).length;
    }
    return count;
  }

  static List<PuzzleModel> _loadPuzzlesForLanguage(String language) {
    switch (language) {
      case 'tr':
        return PuzzlesTr.all;
      case 'de':
        return PuzzlesDe.all;
      case 'it':
        return PuzzlesIt.all;
      case 'fr':
        return PuzzlesFr.all;
      case 'es':
        return PuzzlesEs.all;
      case 'en':
      default:
        return PuzzlesEn.all;
    }
  }
}

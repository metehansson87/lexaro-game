import 'puzzle_model.dart';

/// Daily puzzle model - one puzzle per day, same worldwide.
class DailyPuzzleModel {
  final String dateKey; // Format: "2026-03-13"
  final PuzzleModel puzzle;
  final bool completed;
  final int? solveTimeSeconds;
  final int hintsUsed;

  const DailyPuzzleModel({
    required this.dateKey,
    required this.puzzle,
    this.completed = false,
    this.solveTimeSeconds,
    this.hintsUsed = 0,
  });

  DailyPuzzleModel copyWith({
    bool? completed,
    int? solveTimeSeconds,
    int? hintsUsed,
  }) {
    return DailyPuzzleModel(
      dateKey: dateKey,
      puzzle: puzzle,
      completed: completed ?? this.completed,
      solveTimeSeconds: solveTimeSeconds ?? this.solveTimeSeconds,
      hintsUsed: hintsUsed ?? this.hintsUsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'puzzle': puzzle.toJson(),
        'completed': completed,
        'solveTimeSeconds': solveTimeSeconds,
        'hintsUsed': hintsUsed,
      };

  factory DailyPuzzleModel.fromJson(Map<String, dynamic> json) =>
      DailyPuzzleModel(
        dateKey: json['dateKey'] as String,
        puzzle: PuzzleModel.fromJson(json['puzzle'] as Map<String, dynamic>),
        completed: json['completed'] as bool? ?? false,
        solveTimeSeconds: json['solveTimeSeconds'] as int?,
        hintsUsed: json['hintsUsed'] as int? ?? 0,
      );
}

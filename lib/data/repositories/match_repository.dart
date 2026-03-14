import '../models/match_model.dart';
import '../models/puzzle_model.dart';

/// Repository for match data and multiplayer coordination.
class MatchRepository {
  final List<MatchModel> _matchHistory = [];

  /// Get match history for a player.
  List<MatchModel> getMatchHistory(String playerId) {
    return _matchHistory
        .where((m) =>
            m.player1.id == playerId || m.player2.id == playerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Add a completed match to history.
  void addMatch(MatchModel match) {
    _matchHistory.add(match);
  }

  /// Get win count for a player.
  int getWinCount(String playerId) {
    return _matchHistory.where((m) => m.winnerId == playerId).length;
  }

  /// Get loss count for a player.
  int getLossCount(String playerId) {
    return _matchHistory
        .where((m) =>
            m.isComplete &&
            m.winnerId != null &&
            m.winnerId != playerId &&
            (m.player1.id == playerId || m.player2.id == playerId))
        .length;
  }

  /// Create a new match model for a local vs AI game.
  MatchModel createAiMatch({
    required MatchPlayer player,
    required MatchPlayer aiPlayer,
    required Difficulty difficulty,
  }) {
    return MatchModel(
      id: 'match_${DateTime.now().millisecondsSinceEpoch}',
      player1: player,
      player2: aiPlayer,
      difficulty: difficulty,
      createdAt: DateTime.now().toUtc(),
    );
  }
}

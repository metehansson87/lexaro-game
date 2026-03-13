import '../models/leaderboard_entry.dart';
import '../models/player_model.dart';

/// Repository for leaderboard data access.
/// Uses mock data locally, connects to server API in production.
class LeaderboardRepository {
  /// Fetch global leaderboard entries.
  Future<List<LeaderboardEntry>> fetchGlobalLeaderboard({int limit = 50}) async {
    // In production: HTTP GET to /api/leaderboard?limit=$limit
    await Future.delayed(const Duration(milliseconds: 300));
    return _generateMockLeaderboard(limit);
  }

  /// Submit player score to the leaderboard.
  Future<void> submitScore({
    required String playerId,
    required String displayName,
    required int score,
  }) async {
    // In production: HTTP POST to /api/leaderboard/submit
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Get rank for a specific player.
  Future<int?> getPlayerRank(String playerId) async {
    final board = await fetchGlobalLeaderboard();
    final entry = board.where((e) => e.playerId == playerId).toList();
    return entry.isEmpty ? null : entry.first.rank;
  }

  /// Fetch league-specific leaderboard.
  Future<List<LeaderboardEntry>> fetchLeagueLeaderboard({
    required String league,
    int limit = 50,
  }) async {
    final global = await fetchGlobalLeaderboard(limit: 100);
    return global
        .where((e) => e.league.toLowerCase() == league.toLowerCase())
        .take(limit)
        .toList();
  }

  List<LeaderboardEntry> _generateMockLeaderboard(int limit) {
    final mockPlayers = [
      _mock('p1', 'WordKing', 8500, 42),
      _mock('p2', 'PuzzleMaster', 7200, 38),
      _mock('p3', 'LexaroChamp', 6100, 35),
      _mock('p4', 'BrainStorm', 5400, 30),
      _mock('p5', 'QuickWord', 4800, 28),
      _mock('p6', 'LetterNinja', 3900, 25),
      _mock('p7', 'WordSmith', 3200, 20),
      _mock('p8', 'PuzzleHero', 2600, 18),
      _mock('p9', 'SpeedTyper', 2100, 15),
      _mock('p10', 'CasualGamer', 1500, 10),
      _mock('p11', 'NewPlayer01', 800, 5),
      _mock('p12', 'Rookie', 400, 3),
      _mock('p13', 'Beginner', 150, 1),
    ];

    mockPlayers.sort((a, b) => b.score.compareTo(a.score));

    return mockPlayers
        .take(limit)
        .toList()
        .asMap()
        .entries
        .map((e) => LeaderboardEntry(
              playerId: e.value.playerId,
              playerName: e.value.playerName,
              avatarId: e.value.avatarId,
              score: e.value.score,
              league: PlayerModel.leagueForScore(e.value.score),
              rank: e.key + 1,
              matchesWon: e.value.matchesWon,
            ))
        .toList();
  }

  LeaderboardEntry _mock(String id, String name, int score, int wins) =>
      LeaderboardEntry(
        playerId: id,
        playerName: name,
        score: score,
        league: PlayerModel.leagueForScore(score),
        rank: 0,
        matchesWon: wins,
      );
}

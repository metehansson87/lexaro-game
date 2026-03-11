// lib/services/leaderboard_service.dart
// Leaderboard & league logic.
// Currently uses mock data. Swap fetchGlobal() with a real API call later.

import '../models/player_model.dart';

class LeaderboardService {
  // Mock global leaderboard data
  // TODO: Replace with HTTP fetch from your backend
  Future<List<LeaderboardEntry>> fetchGlobal({int limit = 50}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final mock = _mockEntries();
    mock.sort((a, b) => b.score.compareTo(a.score));
    return mock
        .take(limit)
        .toList()
        .asMap()
        .entries
        .map((e) => LeaderboardEntry(
              playerId: e.value.playerId,
              playerName: e.value.playerName,
              score: e.value.score,
              league: PlayerModel.leagueForScore(e.value.score),
              rank: e.key + 1,
            ))
        .toList();
  }

  // Submit this player's score to the backend
  // TODO: Replace with real HTTP POST
  Future<void> submitScore(String playerId, String name, int score) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // HTTP POST to /api/leaderboard { playerId, name, score }
  }

  // Find rank of a specific player
  Future<int?> getRankFor(String playerId) async {
    final board = await fetchGlobal();
    final entry = board.where((e) => e.playerId == playerId).toList();
    return entry.isEmpty ? null : entry.first.rank;
  }

  // ─── Mock data ───────────────────────────────────────────────────────────────
  List<LeaderboardEntry> _mockEntries() => [
    _e('p1', 'GamerKing',    7200, 1),
    _e('p2', 'PixelHunter',  5800, 2),
    _e('p3', 'NightOwl',     4100, 3),
    _e('p4', 'QuestMaster',  3500, 4),
    _e('p5', 'SpeedRunner',  2900, 5),
    _e('p6', 'RetroFan',     2200, 6),
    _e('p7', 'JoystickJoe',  1600, 7),
    _e('p8', 'CasualPlayer', 800,  8),
    _e('p9', 'Newbie123',    150,  9),
  ];

  LeaderboardEntry _e(String id, String name, int score, int rank) =>
      LeaderboardEntry(
        playerId: id,
        playerName: name,
        score: score,
        league: PlayerModel.leagueForScore(score),
        rank: rank,
      );
}

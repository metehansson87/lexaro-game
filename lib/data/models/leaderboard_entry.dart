/// Leaderboard entry representing a ranked player.
class LeaderboardEntry {
  final String playerId;
  final String playerName;
  final String avatarId;
  final int score;
  final String league;
  final int rank;
  final int matchesWon;

  const LeaderboardEntry({
    required this.playerId,
    required this.playerName,
    this.avatarId = 'default',
    required this.score,
    required this.league,
    required this.rank,
    this.matchesWon = 0,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'playerName': playerName,
        'avatarId': avatarId,
        'score': score,
        'league': league,
        'rank': rank,
        'matchesWon': matchesWon,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        playerId: json['playerId'] as String,
        playerName: json['playerName'] as String,
        avatarId: json['avatarId'] as String? ?? 'default',
        score: json['score'] as int,
        league: json['league'] as String,
        rank: json['rank'] as int,
        matchesWon: json['matchesWon'] as int? ?? 0,
      );
}

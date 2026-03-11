// lib/models/player_model.dart
// Player data: score, gold, daily rewards, stats

class PlayerModel {
  final String id;
  final String name;
  final int totalScore;
  final int gold;
  final int puzzlesSolved;
  final int currentStreak;
  final DateTime? lastDailyReward;
  final String league;

  const PlayerModel({
    required this.id,
    required this.name,
    this.totalScore = 0,
    this.gold = 0,
    this.puzzlesSolved = 0,
    this.currentStreak = 0,
    this.lastDailyReward,
    this.league = 'Bronze',
  });

  // Check if daily reward is available today
  bool get canClaimDailyReward {
    if (lastDailyReward == null) return true;
    final now = DateTime.now();
    final last = lastDailyReward!;
    return now.year != last.year ||
           now.month != last.month ||
           now.day != last.day;
  }

  // League based on total score
  static String leagueForScore(int score) {
    if (score >= 5000) return 'Diamond';
    if (score >= 2000) return 'Gold';
    if (score >= 500)  return 'Silver';
    return 'Bronze';
  }

  PlayerModel copyWith({
    String? name,
    int? totalScore,
    int? gold,
    int? puzzlesSolved,
    int? currentStreak,
    DateTime? lastDailyReward,
  }) {
    return PlayerModel(
      id: id,
      name: name ?? this.name,
      totalScore: totalScore ?? this.totalScore,
      gold: gold ?? this.gold,
      puzzlesSolved: puzzlesSolved ?? this.puzzlesSolved,
      currentStreak: currentStreak ?? this.currentStreak,
      lastDailyReward: lastDailyReward ?? this.lastDailyReward,
      league: leagueForScore(totalScore ?? this.totalScore),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'totalScore': totalScore,
    'gold': gold,
    'puzzlesSolved': puzzlesSolved,
    'currentStreak': currentStreak,
    'lastDailyReward': lastDailyReward?.toIso8601String(),
    'league': league,
  };

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
    id: json['id'] as String,
    name: json['name'] as String,
    totalScore: json['totalScore'] as int? ?? 0,
    gold: json['gold'] as int? ?? 0,
    puzzlesSolved: json['puzzlesSolved'] as int? ?? 0,
    currentStreak: json['currentStreak'] as int? ?? 0,
    lastDailyReward: json['lastDailyReward'] != null
        ? DateTime.parse(json['lastDailyReward'] as String)
        : null,
    league: json['league'] as String? ?? 'Bronze',
  );

  factory PlayerModel.newPlayer() => PlayerModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: 'Player',
    gold: 10, // Starting gold
  );
}

// Leaderboard entry
class LeaderboardEntry {
  final String playerId;
  final String playerName;
  final int score;
  final String league;
  final int rank;

  const LeaderboardEntry({
    required this.playerId,
    required this.playerName,
    required this.score,
    required this.league,
    required this.rank,
  });
}

import '../../core/constants/app_constants.dart';

/// Player data model with economy, stats, and progression tracking.
class PlayerModel {
  final String id;
  final String displayName;
  final String avatarId;
  final int totalScore;
  final int gold;
  final int puzzlesSolved;
  final int puzzlesFailed;
  final int matchesWon;
  final int matchesLost;
  final int currentStreak;
  final int bestStreak;
  final DateTime? lastDailyReward;
  final DateTime? lastLogin;
  final String league;
  final String language;
  final List<String> unlockedAchievements;
  final List<String> unlockedAvatars;

  const PlayerModel({
    required this.id,
    required this.displayName,
    this.avatarId = 'default',
    this.totalScore = 0,
    this.gold = 0,
    this.puzzlesSolved = 0,
    this.puzzlesFailed = 0,
    this.matchesWon = 0,
    this.matchesLost = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lastDailyReward,
    this.lastLogin,
    this.league = 'Bronze',
    this.language = 'en',
    this.unlockedAchievements = const [],
    this.unlockedAvatars = const ['default'],
  });

  // ── Computed Properties ───────────────────────────────────────────────────

  bool get canClaimDailyReward {
    if (lastDailyReward == null) return true;
    final now = DateTime.now().toUtc();
    final last = lastDailyReward!;
    return now.year != last.year ||
        now.month != last.month ||
        now.day != last.day;
  }

  double get winRate {
    final total = matchesWon + matchesLost;
    if (total == 0) return 0;
    return matchesWon / total;
  }

  int get totalMatches => matchesWon + matchesLost;

  static String leagueForScore(int score) {
    if (score >= AppConstants.diamondThreshold) return 'Diamond';
    if (score >= AppConstants.goldThreshold) return 'Gold';
    if (score >= AppConstants.silverThreshold) return 'Silver';
    return 'Bronze';
  }

  // ── Copy With ─────────────────────────────────────────────────────────────

  PlayerModel copyWith({
    String? displayName,
    String? avatarId,
    int? totalScore,
    int? gold,
    int? puzzlesSolved,
    int? puzzlesFailed,
    int? matchesWon,
    int? matchesLost,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastDailyReward,
    DateTime? lastLogin,
    String? language,
    List<String>? unlockedAchievements,
    List<String>? unlockedAvatars,
  }) {
    final newScore = totalScore ?? this.totalScore;
    return PlayerModel(
      id: id,
      displayName: displayName ?? this.displayName,
      avatarId: avatarId ?? this.avatarId,
      totalScore: newScore,
      gold: gold ?? this.gold,
      puzzlesSolved: puzzlesSolved ?? this.puzzlesSolved,
      puzzlesFailed: puzzlesFailed ?? this.puzzlesFailed,
      matchesWon: matchesWon ?? this.matchesWon,
      matchesLost: matchesLost ?? this.matchesLost,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastDailyReward: lastDailyReward ?? this.lastDailyReward,
      lastLogin: lastLogin ?? this.lastLogin,
      league: leagueForScore(newScore),
      language: language ?? this.language,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      unlockedAvatars: unlockedAvatars ?? this.unlockedAvatars,
    );
  }

  // ── Serialization ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'avatarId': avatarId,
        'totalScore': totalScore,
        'gold': gold,
        'puzzlesSolved': puzzlesSolved,
        'puzzlesFailed': puzzlesFailed,
        'matchesWon': matchesWon,
        'matchesLost': matchesLost,
        'currentStreak': currentStreak,
        'bestStreak': bestStreak,
        'lastDailyReward': lastDailyReward?.toIso8601String(),
        'lastLogin': lastLogin?.toIso8601String(),
        'league': league,
        'language': language,
        'unlockedAchievements': unlockedAchievements,
        'unlockedAvatars': unlockedAvatars,
      };

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
        id: json['id'] as String,
        displayName: json['displayName'] as String? ?? 'Player',
        avatarId: json['avatarId'] as String? ?? 'default',
        totalScore: json['totalScore'] as int? ?? 0,
        gold: json['gold'] as int? ?? 0,
        puzzlesSolved: json['puzzlesSolved'] as int? ?? 0,
        puzzlesFailed: json['puzzlesFailed'] as int? ?? 0,
        matchesWon: json['matchesWon'] as int? ?? 0,
        matchesLost: json['matchesLost'] as int? ?? 0,
        currentStreak: json['currentStreak'] as int? ?? 0,
        bestStreak: json['bestStreak'] as int? ?? 0,
        lastDailyReward: json['lastDailyReward'] != null
            ? DateTime.parse(json['lastDailyReward'] as String)
            : null,
        lastLogin: json['lastLogin'] != null
            ? DateTime.parse(json['lastLogin'] as String)
            : null,
        league: json['league'] as String? ?? 'Bronze',
        language: json['language'] as String? ?? 'en',
        unlockedAchievements:
            (json['unlockedAchievements'] as List<dynamic>?)
                    ?.cast<String>() ??
                [],
        unlockedAvatars:
            (json['unlockedAvatars'] as List<dynamic>?)?.cast<String>() ??
                ['default'],
      );

  factory PlayerModel.newPlayer({String? id, String? name}) => PlayerModel(
        id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        displayName: name ?? 'Player',
        gold: AppConstants.startingGold,
        lastLogin: DateTime.now().toUtc(),
      );
}

import 'puzzle_model.dart';

/// Represents a multiplayer match (Best of 5 rounds).
class MatchModel {
  final String id;
  final MatchPlayer player1;
  final MatchPlayer player2;
  final List<RoundResult> rounds;
  final MatchStatus status;
  final Difficulty difficulty;
  final DateTime createdAt;
  final String? winnerId;

  const MatchModel({
    required this.id,
    required this.player1,
    required this.player2,
    this.rounds = const [],
    this.status = MatchStatus.waiting,
    this.difficulty = Difficulty.medium,
    required this.createdAt,
    this.winnerId,
  });

  /// Current round number (1-indexed).
  int get currentRound => rounds.length + 1;

  /// Score for player 1.
  int get player1Score => rounds.where((r) => r.winnerId == player1.id).length;

  /// Score for player 2.
  int get player2Score => rounds.where((r) => r.winnerId == player2.id).length;

  /// Whether the match is complete.
  bool get isComplete => status == MatchStatus.completed;

  /// Required wins to win the match (best of 5 = first to 3).
  static const int winsRequired = 3;

  MatchModel copyWith({
    List<RoundResult>? rounds,
    MatchStatus? status,
    String? winnerId,
  }) {
    return MatchModel(
      id: id,
      player1: player1,
      player2: player2,
      rounds: rounds ?? this.rounds,
      status: status ?? this.status,
      difficulty: difficulty,
      createdAt: createdAt,
      winnerId: winnerId ?? this.winnerId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'player1': player1.toJson(),
        'player2': player2.toJson(),
        'rounds': rounds.map((r) => r.toJson()).toList(),
        'status': status.name,
        'difficulty': difficulty.name,
        'createdAt': createdAt.toIso8601String(),
        'winnerId': winnerId,
      };

  factory MatchModel.fromJson(Map<String, dynamic> json) => MatchModel(
        id: json['id'] as String,
        player1:
            MatchPlayer.fromJson(json['player1'] as Map<String, dynamic>),
        player2:
            MatchPlayer.fromJson(json['player2'] as Map<String, dynamic>),
        rounds: (json['rounds'] as List<dynamic>?)
                ?.map(
                    (r) => RoundResult.fromJson(r as Map<String, dynamic>))
                .toList() ??
            [],
        status: MatchStatus.values
            .firstWhere((s) => s.name == json['status'], orElse: () => MatchStatus.waiting),
        difficulty: Difficulty.fromString(json['difficulty'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        winnerId: json['winnerId'] as String?,
      );
}

/// A player within a match context.
class MatchPlayer {
  final String id;
  final String displayName;
  final String avatarId;
  final bool isAi;
  final String? aiDifficulty;

  const MatchPlayer({
    required this.id,
    required this.displayName,
    this.avatarId = 'default',
    this.isAi = false,
    this.aiDifficulty,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'avatarId': avatarId,
        'isAi': isAi,
        'aiDifficulty': aiDifficulty,
      };

  factory MatchPlayer.fromJson(Map<String, dynamic> json) => MatchPlayer(
        id: json['id'] as String,
        displayName: json['displayName'] as String,
        avatarId: json['avatarId'] as String? ?? 'default',
        isAi: json['isAi'] as bool? ?? false,
        aiDifficulty: json['aiDifficulty'] as String?,
      );
}

/// Result of a single round within a match.
class RoundResult {
  final int roundNumber;
  final String puzzleId;
  final String puzzleWord;
  final String? winnerId;
  final int? winnerTimeMs;
  final int player1HintsUsed;
  final int player2HintsUsed;
  final bool timeout;

  const RoundResult({
    required this.roundNumber,
    required this.puzzleId,
    required this.puzzleWord,
    this.winnerId,
    this.winnerTimeMs,
    this.player1HintsUsed = 0,
    this.player2HintsUsed = 0,
    this.timeout = false,
  });

  Map<String, dynamic> toJson() => {
        'roundNumber': roundNumber,
        'puzzleId': puzzleId,
        'puzzleWord': puzzleWord,
        'winnerId': winnerId,
        'winnerTimeMs': winnerTimeMs,
        'player1HintsUsed': player1HintsUsed,
        'player2HintsUsed': player2HintsUsed,
        'timeout': timeout,
      };

  factory RoundResult.fromJson(Map<String, dynamic> json) => RoundResult(
        roundNumber: json['roundNumber'] as int,
        puzzleId: json['puzzleId'] as String,
        puzzleWord: json['puzzleWord'] as String,
        winnerId: json['winnerId'] as String?,
        winnerTimeMs: json['winnerTimeMs'] as int?,
        player1HintsUsed: json['player1HintsUsed'] as int? ?? 0,
        player2HintsUsed: json['player2HintsUsed'] as int? ?? 0,
        timeout: json['timeout'] as bool? ?? false,
      );
}

enum MatchStatus {
  waiting,
  starting,
  inProgress,
  completed,
  cancelled,
  disconnected,
}

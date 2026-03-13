/// Achievement definition and progress tracking.
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final int goldReward;
  final AchievementType type;
  final int targetValue;
  final int currentValue;
  final bool unlocked;
  final DateTime? unlockedAt;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.goldReward,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.unlocked = false,
    this.unlockedAt,
  });

  double get progress => targetValue > 0
      ? (currentValue / targetValue).clamp(0.0, 1.0)
      : 0.0;

  AchievementModel copyWith({
    int? currentValue,
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      iconName: iconName,
      goldReward: goldReward,
      type: type,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconName': iconName,
        'goldReward': goldReward,
        'type': type.name,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory AchievementModel.fromJson(Map<String, dynamic> json) =>
      AchievementModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        iconName: json['iconName'] as String,
        goldReward: json['goldReward'] as int,
        type: AchievementType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => AchievementType.puzzlesSolved,
        ),
        targetValue: json['targetValue'] as int,
        currentValue: json['currentValue'] as int? ?? 0,
        unlocked: json['unlocked'] as bool? ?? false,
        unlockedAt: json['unlockedAt'] != null
            ? DateTime.parse(json['unlockedAt'] as String)
            : null,
      );

  /// Predefined achievements list.
  static List<AchievementModel> get allAchievements => [
        const AchievementModel(
          id: 'first_puzzle',
          title: 'First Steps',
          description: 'Solve your first puzzle',
          iconName: 'star',
          goldReward: 5,
          type: AchievementType.puzzlesSolved,
          targetValue: 1,
        ),
        const AchievementModel(
          id: 'puzzle_10',
          title: 'Word Learner',
          description: 'Solve 10 puzzles',
          iconName: 'book',
          goldReward: 10,
          type: AchievementType.puzzlesSolved,
          targetValue: 10,
        ),
        const AchievementModel(
          id: 'puzzle_50',
          title: 'Word Master',
          description: 'Solve 50 puzzles',
          iconName: 'school',
          goldReward: 25,
          type: AchievementType.puzzlesSolved,
          targetValue: 50,
        ),
        const AchievementModel(
          id: 'puzzle_100',
          title: 'Lexicon Expert',
          description: 'Solve 100 puzzles',
          iconName: 'trophy',
          goldReward: 50,
          type: AchievementType.puzzlesSolved,
          targetValue: 100,
        ),
        const AchievementModel(
          id: 'puzzle_500',
          title: 'Word Legend',
          description: 'Solve 500 puzzles',
          iconName: 'diamond',
          goldReward: 200,
          type: AchievementType.puzzlesSolved,
          targetValue: 500,
        ),
        const AchievementModel(
          id: 'match_first',
          title: 'Challenger',
          description: 'Win your first match',
          iconName: 'swords',
          goldReward: 10,
          type: AchievementType.matchesWon,
          targetValue: 1,
        ),
        const AchievementModel(
          id: 'match_10',
          title: 'Competitor',
          description: 'Win 10 matches',
          iconName: 'medal',
          goldReward: 25,
          type: AchievementType.matchesWon,
          targetValue: 10,
        ),
        const AchievementModel(
          id: 'match_50',
          title: 'Champion',
          description: 'Win 50 matches',
          iconName: 'crown',
          goldReward: 100,
          type: AchievementType.matchesWon,
          targetValue: 50,
        ),
        const AchievementModel(
          id: 'streak_3',
          title: 'On Fire',
          description: 'Get a 3-day streak',
          iconName: 'fire',
          goldReward: 15,
          type: AchievementType.streak,
          targetValue: 3,
        ),
        const AchievementModel(
          id: 'streak_7',
          title: 'Dedicated',
          description: 'Get a 7-day streak',
          iconName: 'calendar',
          goldReward: 30,
          type: AchievementType.streak,
          targetValue: 7,
        ),
        const AchievementModel(
          id: 'streak_30',
          title: 'Unstoppable',
          description: 'Get a 30-day streak',
          iconName: 'lightning',
          goldReward: 100,
          type: AchievementType.streak,
          targetValue: 30,
        ),
        const AchievementModel(
          id: 'daily_7',
          title: 'Daily Player',
          description: 'Complete 7 daily puzzles',
          iconName: 'sunrise',
          goldReward: 20,
          type: AchievementType.dailyPuzzles,
          targetValue: 7,
        ),
        const AchievementModel(
          id: 'speed_demon',
          title: 'Speed Demon',
          description: 'Solve a hard puzzle in under 10 seconds',
          iconName: 'timer',
          goldReward: 50,
          type: AchievementType.speedSolve,
          targetValue: 1,
        ),
        const AchievementModel(
          id: 'no_hints',
          title: 'Pure Skill',
          description: 'Win a match without using any hints',
          iconName: 'brain',
          goldReward: 30,
          type: AchievementType.noHintWin,
          targetValue: 1,
        ),
        const AchievementModel(
          id: 'silver_league',
          title: 'Rising Star',
          description: 'Reach Silver League',
          iconName: 'arrow_up',
          goldReward: 20,
          type: AchievementType.leagueReached,
          targetValue: 1,
        ),
        const AchievementModel(
          id: 'gold_league',
          title: 'Golden Touch',
          description: 'Reach Gold League',
          iconName: 'gold',
          goldReward: 50,
          type: AchievementType.leagueReached,
          targetValue: 2,
        ),
        const AchievementModel(
          id: 'diamond_league',
          title: 'Diamond Mind',
          description: 'Reach Diamond League',
          iconName: 'diamond',
          goldReward: 200,
          type: AchievementType.leagueReached,
          targetValue: 3,
        ),
      ];
}

enum AchievementType {
  puzzlesSolved,
  matchesWon,
  streak,
  dailyPuzzles,
  speedSolve,
  noHintWin,
  leagueReached,
}

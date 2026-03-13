import 'puzzle_model.dart';

/// Live operations event model for time-limited events and special challenges.
class LiveOpsEvent {
  final String id;
  final String title;
  final String description;
  final LiveOpsEventType type;
  final DateTime startDate;
  final DateTime endDate;
  final int goldReward;
  final int bonusMultiplier;
  final List<PuzzleModel>? specialPuzzles;
  final Map<String, dynamic>? metadata;

  const LiveOpsEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.goldReward = 0,
    this.bonusMultiplier = 1,
    this.specialPuzzles,
    this.metadata,
  });

  bool get isActive {
    final now = DateTime.now().toUtc();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming => DateTime.now().toUtc().isBefore(startDate);
  bool get isExpired => DateTime.now().toUtc().isAfter(endDate);

  Duration get timeRemaining => endDate.difference(DateTime.now().toUtc());

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'goldReward': goldReward,
        'bonusMultiplier': bonusMultiplier,
        'metadata': metadata,
      };

  factory LiveOpsEvent.fromJson(Map<String, dynamic> json) => LiveOpsEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: LiveOpsEventType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => LiveOpsEventType.specialPuzzle,
        ),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        goldReward: json['goldReward'] as int? ?? 0,
        bonusMultiplier: json['bonusMultiplier'] as int? ?? 1,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}

enum LiveOpsEventType {
  specialPuzzle,
  doubleGold,
  tournament,
  limitedTimeChallenge,
  seasonalEvent,
}

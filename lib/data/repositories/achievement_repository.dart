import '../models/achievement_model.dart';
import '../models/player_model.dart';
import '../../core/services/storage_service.dart';

/// Repository for achievement tracking and unlocking.
class AchievementRepository {
  final StorageService _storage;

  AchievementRepository(this._storage);

  /// Get all achievements with current progress for the player.
  List<AchievementModel> getAchievements(PlayerModel player) {
    final unlocked = _storage.loadAchievements().toSet();

    return AchievementModel.allAchievements.map((achievement) {
      final isUnlocked = unlocked.contains(achievement.id);
      final currentValue = _getProgressForAchievement(achievement, player);

      return achievement.copyWith(
        currentValue: currentValue,
        unlocked: isUnlocked,
      );
    }).toList();
  }

  /// Check and unlock any newly completed achievements.
  /// Returns list of newly unlocked achievements.
  Future<List<AchievementModel>> checkAndUnlock(PlayerModel player) async {
    final unlocked = _storage.loadAchievements().toSet();
    final newlyUnlocked = <AchievementModel>[];

    for (final achievement in AchievementModel.allAchievements) {
      if (unlocked.contains(achievement.id)) continue;

      final progress = _getProgressForAchievement(achievement, player);
      if (progress >= achievement.targetValue) {
        unlocked.add(achievement.id);
        newlyUnlocked.add(achievement.copyWith(
          unlocked: true,
          unlockedAt: DateTime.now().toUtc(),
          currentValue: progress,
        ));
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      await _storage.saveAchievements(unlocked.toList());
    }

    return newlyUnlocked;
  }

  int _getProgressForAchievement(
      AchievementModel achievement, PlayerModel player) {
    switch (achievement.type) {
      case AchievementType.puzzlesSolved:
        return player.puzzlesSolved;
      case AchievementType.matchesWon:
        return player.matchesWon;
      case AchievementType.streak:
        return player.bestStreak;
      case AchievementType.dailyPuzzles:
        return player.puzzlesSolved; // Simplified
      case AchievementType.speedSolve:
        return 0; // Tracked per-event
      case AchievementType.noHintWin:
        return 0; // Tracked per-event
      case AchievementType.leagueReached:
        return _leagueLevel(player.league);
    }
  }

  int _leagueLevel(String league) {
    switch (league.toLowerCase()) {
      case 'diamond':
        return 3;
      case 'gold':
        return 2;
      case 'silver':
        return 1;
      default:
        return 0;
    }
  }

  /// Manually unlock a specific achievement (for special events).
  Future<void> unlockAchievement(String achievementId) async {
    final unlocked = _storage.loadAchievements().toSet();
    unlocked.add(achievementId);
    await _storage.saveAchievements(unlocked.toList());
  }
}

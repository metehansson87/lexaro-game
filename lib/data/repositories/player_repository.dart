import '../models/player_model.dart';
import '../../core/services/storage_service.dart';

/// Repository for player data persistence and retrieval.
class PlayerRepository {
  final StorageService _storage;

  PlayerRepository(this._storage);

  /// Load player from local storage, or create new if none exists.
  PlayerModel loadPlayer() {
    final data = _storage.loadPlayerData();
    if (data == null) {
      final newPlayer = PlayerModel.newPlayer();
      savePlayer(newPlayer);
      return newPlayer;
    }
    return PlayerModel.fromJson(data);
  }

  /// Save player data to local storage.
  Future<void> savePlayer(PlayerModel player) async {
    await _storage.savePlayerData(player.toJson());
  }

  /// Update player gold balance.
  Future<PlayerModel> addGold(PlayerModel player, int amount) async {
    final updated = player.copyWith(gold: player.gold + amount);
    await savePlayer(updated);
    return updated;
  }

  /// Deduct gold from player (with validation).
  Future<PlayerModel?> spendGold(PlayerModel player, int amount) async {
    if (player.gold < amount) return null;
    final updated = player.copyWith(gold: player.gold - amount);
    await savePlayer(updated);
    return updated;
  }

  /// Update score and recalculate league.
  Future<PlayerModel> addScore(PlayerModel player, int points) async {
    final updated = player.copyWith(
      totalScore: player.totalScore + points,
    );
    await savePlayer(updated);
    return updated;
  }

  /// Record a puzzle solve.
  Future<PlayerModel> recordPuzzleSolved(PlayerModel player) async {
    final updated = player.copyWith(
      puzzlesSolved: player.puzzlesSolved + 1,
    );
    await savePlayer(updated);
    return updated;
  }

  /// Record a puzzle failure.
  Future<PlayerModel> recordPuzzleFailed(PlayerModel player) async {
    final updated = player.copyWith(
      puzzlesFailed: player.puzzlesFailed + 1,
    );
    await savePlayer(updated);
    return updated;
  }

  /// Record a match win.
  Future<PlayerModel> recordMatchWin(PlayerModel player) async {
    final newStreak = player.currentStreak + 1;
    final updated = player.copyWith(
      matchesWon: player.matchesWon + 1,
      currentStreak: newStreak,
      bestStreak:
          newStreak > player.bestStreak ? newStreak : player.bestStreak,
    );
    await savePlayer(updated);
    return updated;
  }

  /// Record a match loss.
  Future<PlayerModel> recordMatchLoss(PlayerModel player) async {
    final updated = player.copyWith(
      matchesLost: player.matchesLost + 1,
      currentStreak: 0,
    );
    await savePlayer(updated);
    return updated;
  }

  /// Claim daily reward.
  Future<PlayerModel> claimDailyReward(PlayerModel player, int goldAmount) async {
    final updated = player.copyWith(
      gold: player.gold + goldAmount,
      lastDailyReward: DateTime.now().toUtc(),
    );
    await savePlayer(updated);
    return updated;
  }

  /// Update display name.
  Future<PlayerModel> updateDisplayName(
      PlayerModel player, String name) async {
    final updated = player.copyWith(displayName: name);
    await savePlayer(updated);
    return updated;
  }

  /// Update selected language.
  Future<PlayerModel> updateLanguage(
      PlayerModel player, String language) async {
    final updated = player.copyWith(language: language);
    await savePlayer(updated);
    return updated;
  }

  /// Get solved puzzle IDs.
  Set<String> getSolvedIds() => _storage.loadSolvedIds();

  /// Mark a puzzle as solved.
  Future<void> markPuzzleSolved(String puzzleId) async {
    await _storage.markPuzzleSolved(puzzleId);
  }
}

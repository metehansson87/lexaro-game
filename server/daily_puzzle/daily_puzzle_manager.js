const { DAILY_PUZZLE_REWARD } = require('../config/constants');

/**
 * Manages daily puzzle system.
 * Same puzzle worldwide per day, deterministic based on date.
 * Tracks completions per player.
 */
class DailyPuzzleManager {
  constructor(puzzleEngine) {
    this.puzzleEngine = puzzleEngine;
    this.completions = new Map(); // "playerId:dateKey" -> completion data
  }

  /**
   * Get today's daily puzzle for a given language.
   */
  getDailyPuzzle(language = 'en') {
    const puzzle = this.puzzleEngine.getDailyPuzzle(language);
    const dateKey = this._getDateKey();

    return {
      dateKey,
      puzzle: this.puzzleEngine.getClientPuzzle(puzzle),
      reward: DAILY_PUZZLE_REWARD,
    };
  }

  /**
   * Record daily puzzle completion. Returns gold reward if first completion.
   */
  completeDailyPuzzle(playerId, solveTimeSeconds, hintsUsed) {
    const dateKey = this._getDateKey();
    const key = `${playerId}:${dateKey}`;

    if (this.completions.has(key)) {
      return {
        success: false,
        message: 'Already completed today',
        goldReward: 0,
      };
    }

    this.completions.set(key, {
      playerId,
      dateKey,
      solveTimeSeconds,
      hintsUsed,
      completedAt: Date.now(),
    });

    // Clean up old completions (keep only last 7 days)
    this._cleanup();

    return {
      success: true,
      message: 'Daily puzzle completed!',
      goldReward: DAILY_PUZZLE_REWARD,
    };
  }

  /**
   * Check if a player has completed today's puzzle.
   */
  hasCompleted(playerId) {
    const dateKey = this._getDateKey();
    return this.completions.has(`${playerId}:${dateKey}`);
  }

  _getDateKey() {
    const now = new Date();
    return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
  }

  _cleanup() {
    const now = new Date();
    const sevenDaysAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

    for (const [key, data] of this.completions) {
      if (data.completedAt < sevenDaysAgo.getTime()) {
        this.completions.delete(key);
      }
    }
  }
}

module.exports = { DailyPuzzleManager };

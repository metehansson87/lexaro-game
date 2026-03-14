const { LEAGUE_BRONZE, LEAGUE_SILVER, LEAGUE_GOLD, LEAGUE_DIAMOND } = require('../config/constants');

/**
 * Manages global leaderboard and league rankings.
 * In production, this would be backed by a database (Firestore/PostgreSQL).
 */
class LeaderboardManager {
  constructor() {
    this.players = new Map(); // playerId -> { score, wins, losses, league }
  }

  /**
   * Record a match win.
   */
  recordWin(playerId, scoreGained = 10) {
    const entry = this._getOrCreate(playerId);
    entry.wins++;
    entry.score += scoreGained;
    entry.league = this._calculateLeague(entry.score);
    this.players.set(playerId, entry);
  }

  /**
   * Record a match loss.
   */
  recordLoss(playerId) {
    const entry = this._getOrCreate(playerId);
    entry.losses++;
    this.players.set(playerId, entry);
  }

  /**
   * Get leaderboard entries sorted by score.
   */
  getLeaderboard(league = null, limit = 50) {
    let entries = Array.from(this.players.entries()).map(([id, data]) => ({
      playerId: id,
      ...data,
    }));

    if (league && league !== 'Global') {
      entries = entries.filter((e) => e.league === league);
    }

    entries.sort((a, b) => b.score - a.score);
    return entries.slice(0, limit).map((e, i) => ({
      ...e,
      rank: i + 1,
    }));
  }

  /**
   * Get a player's rank.
   */
  getPlayerRank(playerId) {
    const sorted = Array.from(this.players.entries())
      .sort((a, b) => b[1].score - a[1].score);

    const index = sorted.findIndex(([id]) => id === playerId);
    return index >= 0 ? index + 1 : null;
  }

  _getOrCreate(playerId) {
    if (!this.players.has(playerId)) {
      this.players.set(playerId, {
        score: 0,
        wins: 0,
        losses: 0,
        league: 'Bronze',
      });
    }
    return this.players.get(playerId);
  }

  _calculateLeague(score) {
    if (score >= LEAGUE_DIAMOND) return 'Diamond';
    if (score >= LEAGUE_GOLD) return 'Gold';
    if (score >= LEAGUE_SILVER) return 'Silver';
    return 'Bronze';
  }
}

module.exports = { LeaderboardManager };

/**
 * Analytics manager for tracking game events and generating reports.
 * Tracks match win rates, puzzle difficulty success, session length.
 * In production, this would integrate with a proper analytics service.
 */
class AnalyticsManager {
  constructor() {
    this.events = [];
    this.sessionStarts = new Map(); // socketId -> timestamp
    this.stats = {
      totalMatches: 0,
      totalRounds: 0,
      matchCompletions: 0,
      disconnects: 0,
      avgRoundTimeMs: 0,
      roundTimesSum: 0,
      roundTimesCount: 0,
      difficultyStats: {
        easy: { played: 0, solved: 0 },
        medium: { played: 0, solved: 0 },
        hard: { played: 0, solved: 0 },
      },
    };
  }

  /**
   * Track a game event.
   */
  trackEvent(eventName, data = {}) {
    const event = {
      name: eventName,
      timestamp: Date.now(),
      ...data,
    };

    this.events.push(event);

    // Keep only last 10000 events to prevent memory leak
    if (this.events.length > 10000) {
      this.events = this.events.slice(-5000);
    }

    // Update stats
    this._updateStats(eventName, data);
  }

  /**
   * Get analytics summary.
   */
  getSummary() {
    return {
      totalMatches: this.stats.totalMatches,
      totalRounds: this.stats.totalRounds,
      completionRate: this.stats.totalMatches > 0
        ? (this.stats.matchCompletions / this.stats.totalMatches * 100).toFixed(1) + '%'
        : '0%',
      avgRoundTimeMs: this.stats.roundTimesCount > 0
        ? Math.round(this.stats.roundTimesSum / this.stats.roundTimesCount)
        : 0,
      difficultyStats: this.stats.difficultyStats,
      recentEvents: this.events.slice(-20),
    };
  }

  _updateStats(eventName, data) {
    switch (eventName) {
      case 'match_complete':
        this.stats.totalMatches++;
        if (data.reason !== 'disconnect') {
          this.stats.matchCompletions++;
        } else {
          this.stats.disconnects++;
        }
        break;

      case 'round_complete':
        this.stats.totalRounds++;
        if (data.timeMs) {
          this.stats.roundTimesSum += data.timeMs;
          this.stats.roundTimesCount++;
        }
        break;

      case 'player_connect':
        if (data.socketId) {
          this.sessionStarts.set(data.socketId, Date.now());
        }
        break;

      case 'player_disconnect':
        if (data.socketId) {
          this.sessionStarts.delete(data.socketId);
        }
        break;
    }
  }
}

module.exports = { AnalyticsManager };

/**
 * Server-side player model.
 * In production, this would be stored in Firestore/PostgreSQL.
 */
class Player {
  constructor({
    id,
    displayName = 'Player',
    avatarId = 'default',
    totalScore = 0,
    gold = 50,
    matchesWon = 0,
    matchesLost = 0,
    puzzlesSolved = 0,
    league = 'Bronze',
    language = 'en',
  } = {}) {
    this.id = id;
    this.displayName = displayName;
    this.avatarId = avatarId;
    this.totalScore = totalScore;
    this.gold = gold;
    this.matchesWon = matchesWon;
    this.matchesLost = matchesLost;
    this.puzzlesSolved = puzzlesSolved;
    this.league = league;
    this.language = language;
    this.createdAt = new Date();
    this.lastLogin = new Date();
  }

  toJSON() {
    return {
      id: this.id,
      displayName: this.displayName,
      avatarId: this.avatarId,
      totalScore: this.totalScore,
      gold: this.gold,
      matchesWon: this.matchesWon,
      matchesLost: this.matchesLost,
      puzzlesSolved: this.puzzlesSolved,
      league: this.league,
      language: this.language,
    };
  }
}

module.exports = { Player };

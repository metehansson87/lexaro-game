const EventEmitter = require('events');
const { v4: uuidv4 } = require('uuid');
const {
  MATCH_ROUNDS,
  WINS_REQUIRED,
  ROUND_DURATION_SECONDS,
  MAX_HINTS_PER_ROUND,
  MATCH_WIN_GOLD,
  MATCH_LOSS_GOLD,
} = require('../config/constants');

/**
 * Manages active game rooms / matches.
 * Handles round lifecycle, answer validation, scoring, and disconnect recovery.
 */
class GameRoomManager extends EventEmitter {
  constructor(puzzleEngine, leaderboardManager, analyticsManager) {
    super();
    this.rooms = new Map(); // matchId -> GameRoom
    this.playerRooms = new Map(); // socketId -> matchId
    this.puzzleEngine = puzzleEngine;
    this.leaderboard = leaderboardManager;
    this.analytics = analyticsManager;
  }

  get activeMatchCount() {
    return this.rooms.size;
  }

  /**
   * Create a new match.
   */
  createMatch(matchData) {
    const matchId = uuidv4();
    const room = new GameRoom({
      matchId,
      ...matchData,
      puzzleEngine: this.puzzleEngine,
    });

    this.rooms.set(matchId, room);

    if (matchData.player1.socketId) {
      this.playerRooms.set(matchData.player1.socketId, matchId);
    }
    if (matchData.player2.socketId) {
      this.playerRooms.set(matchData.player2.socketId, matchId);
    }

    console.log(`Match created: ${matchId} (${matchData.player1.displayName} vs ${matchData.player2.displayName})`);

    this.emit('match:created', room);

    // Start first round after a short delay
    setTimeout(() => this._startNextRound(matchId), 2000);

    return room;
  }

  /**
   * Submit an answer for a round.
   */
  submitAnswer(matchId, socketId, answer) {
    const room = this.rooms.get(matchId);
    if (!room || room.status !== 'in_progress') return null;
    if (!room.currentPuzzle) return null;

    // Server-side validation (never trust client)
    const isCorrect = this.puzzleEngine.validateAnswer(room.currentPuzzle.id, answer);
    if (!isCorrect) return null;

    // Determine which player answered
    const isPlayer1 = room.player1.socketId === socketId;
    const winnerId = isPlayer1 ? room.player1.playerId : room.player2.playerId;

    return this._endRound(matchId, winnerId);
  }

  /**
   * Record a hint usage.
   */
  useHint(matchId, socketId) {
    const room = this.rooms.get(matchId);
    if (!room) return;

    const isPlayer1 = room.player1.socketId === socketId;
    if (isPlayer1) {
      room.player1HintsThisRound = Math.min(
        (room.player1HintsThisRound || 0) + 1,
        MAX_HINTS_PER_ROUND,
      );
    } else {
      room.player2HintsThisRound = Math.min(
        (room.player2HintsThisRound || 0) + 1,
        MAX_HINTS_PER_ROUND,
      );
    }
  }

  /**
   * Handle player disconnect.
   */
  handleDisconnect(socketId) {
    const matchId = this.playerRooms.get(socketId);
    if (!matchId) return;

    const room = this.rooms.get(matchId);
    if (!room) return;

    room.disconnectedPlayer = socketId;
    room.disconnectTime = Date.now();

    // Allow 30 seconds to reconnect
    room.disconnectTimer = setTimeout(() => {
      if (room.disconnectedPlayer === socketId) {
        // Forfeit the match
        const isPlayer1 = room.player1.socketId === socketId;
        const winnerId = isPlayer1 ? room.player2.playerId : room.player1.playerId;
        this._completeMatch(matchId, winnerId, 'disconnect');
      }
    }, 30000);
  }

  /**
   * Handle player reconnection.
   */
  reconnect(matchId, playerId, newSocketId) {
    const room = this.rooms.get(matchId);
    if (!room) return null;

    if (room.player1.playerId === playerId) {
      const oldSocket = room.player1.socketId;
      room.player1.socketId = newSocketId;
      this.playerRooms.delete(oldSocket);
      this.playerRooms.set(newSocketId, matchId);
    } else if (room.player2.playerId === playerId) {
      const oldSocket = room.player2.socketId;
      room.player2.socketId = newSocketId;
      this.playerRooms.delete(oldSocket);
      this.playerRooms.set(newSocketId, matchId);
    } else {
      return null;
    }

    if (room.disconnectTimer) {
      clearTimeout(room.disconnectTimer);
      room.disconnectTimer = null;
    }
    room.disconnectedPlayer = null;

    return room;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  _startNextRound(matchId) {
    const room = this.rooms.get(matchId);
    if (!room || room.status === 'completed') return;

    // Check if match is over
    if (room.player1Score >= WINS_REQUIRED || room.player2Score >= WINS_REQUIRED) {
      const winnerId = room.player1Score >= WINS_REQUIRED
        ? room.player1.playerId
        : room.player2.playerId;
      this._completeMatch(matchId, winnerId, 'score');
      return;
    }

    if (room.currentRound >= MATCH_ROUNDS) {
      const winnerId = room.player1Score > room.player2Score
        ? room.player1.playerId
        : room.player2Score > room.player1Score
          ? room.player2.playerId
          : null;
      this._completeMatch(matchId, winnerId, 'rounds_complete');
      return;
    }

    room.currentRound++;
    room.status = 'in_progress';
    room.player1HintsThisRound = 0;
    room.player2HintsThisRound = 0;

    // Get a new puzzle
    const puzzle = this.puzzleEngine.getMatchPuzzle(
      room.language,
      room.difficulty,
      room.usedPuzzleIds,
    );
    room.currentPuzzle = puzzle;
    room.usedPuzzleIds.push(puzzle.id);
    room.roundStartTime = Date.now();

    const clientPuzzle = this.puzzleEngine.getClientPuzzle(puzzle);

    this.emit('round:start', {
      matchId,
      round: room.currentRound,
      puzzle: clientPuzzle,
      duration: ROUND_DURATION_SECONDS,
    });

    // Start round timer
    room.remaining = ROUND_DURATION_SECONDS;
    room.roundTimer = setInterval(() => {
      room.remaining--;
      this.emit('round:tick', { matchId, remaining: room.remaining });

      if (room.remaining <= 0) {
        clearInterval(room.roundTimer);
        this._endRound(matchId, null);
      }
    }, 1000);

    // If AI opponent, schedule AI answer
    if (room.player2.isAi) {
      this._scheduleAiAnswer(room);
    }
  }

  _endRound(matchId, winnerId) {
    const room = this.rooms.get(matchId);
    if (!room) return null;

    if (room.roundTimer) {
      clearInterval(room.roundTimer);
      room.roundTimer = null;
    }
    if (room.aiTimer) {
      clearTimeout(room.aiTimer);
      room.aiTimer = null;
    }

    const elapsed = Date.now() - room.roundStartTime;

    if (winnerId === room.player1.playerId) {
      room.player1Score++;
    } else if (winnerId === room.player2.playerId) {
      room.player2Score++;
    }

    const roundResult = {
      matchId,
      round: room.currentRound,
      winnerId,
      puzzleWord: room.currentPuzzle?.word || '',
      timeMs: elapsed,
      player1Score: room.player1Score,
      player2Score: room.player2Score,
      player1Hints: room.player1HintsThisRound,
      player2Hints: room.player2HintsThisRound,
      timeout: winnerId === null,
    };

    room.rounds.push(roundResult);
    room.currentPuzzle = null;

    this.emit('round:result', roundResult);

    // Analytics
    this.analytics.trackEvent('round_complete', {
      matchId,
      round: room.currentRound,
      winnerId,
      timeMs: elapsed,
    });

    // Start next round after delay
    setTimeout(() => this._startNextRound(matchId), 3000);

    return roundResult;
  }

  _completeMatch(matchId, winnerId, reason) {
    const room = this.rooms.get(matchId);
    if (!room) return;

    room.status = 'completed';
    room.winnerId = winnerId;

    if (room.roundTimer) {
      clearInterval(room.roundTimer);
    }
    if (room.aiTimer) {
      clearTimeout(room.aiTimer);
      room.aiTimer = null;
    }

    // Update leaderboard
    if (winnerId) {
      this.leaderboard.recordWin(winnerId, room.player1Score + room.player2Score);
      const loserId = winnerId === room.player1.playerId
        ? room.player2.playerId
        : room.player1.playerId;
      this.leaderboard.recordLoss(loserId);
    }

    const matchResult = {
      matchId,
      winnerId,
      reason,
      player1Score: room.player1Score,
      player2Score: room.player2Score,
      rounds: room.rounds,
      goldReward: winnerId ? MATCH_WIN_GOLD : MATCH_LOSS_GOLD,
    };

    this.emit('match:complete', matchResult);

    // Analytics
    this.analytics.trackEvent('match_complete', {
      matchId,
      winnerId,
      reason,
      rounds: room.rounds.length,
    });

    // Cleanup after delay
    setTimeout(() => {
      this.rooms.delete(matchId);
      // Clean up player room mappings
      for (const [sid, mid] of this.playerRooms) {
        if (mid === matchId) this.playerRooms.delete(sid);
      }
    }, 60000);

    console.log(`Match completed: ${matchId} winner=${winnerId} reason=${reason}`);
  }

  _scheduleAiAnswer(room) {
    const { AI_EASY_MIN_MS, AI_EASY_MAX_MS, AI_MEDIUM_MIN_MS, AI_MEDIUM_MAX_MS, AI_HARD_MIN_MS, AI_HARD_MAX_MS } = require('../config/constants');

    let minMs, maxMs, solveChance;
    switch (room.difficulty) {
      case 'easy':
        minMs = AI_EASY_MIN_MS;
        maxMs = AI_EASY_MAX_MS;
        solveChance = 0.4;
        break;
      case 'hard':
        minMs = AI_HARD_MIN_MS;
        maxMs = AI_HARD_MAX_MS;
        solveChance = 0.85;
        break;
      default:
        minMs = AI_MEDIUM_MIN_MS;
        maxMs = AI_MEDIUM_MAX_MS;
        solveChance = 0.65;
    }

    if (Math.random() > solveChance) return; // AI doesn't solve this round

    const delay = minMs + Math.random() * (maxMs - minMs);
    room.aiTimer = setTimeout(() => {
      if (room.currentPuzzle && room.status === 'in_progress') {
        this._endRound(room.matchId, room.player2.playerId);
      }
    }, delay);
  }
}

/**
 * Represents a single game room / active match.
 */
class GameRoom {
  constructor({ matchId, player1, player2, difficulty, language, puzzleEngine }) {
    this.matchId = matchId;
    this.player1 = { ...player1 };
    this.player2 = { ...player2 };
    this.difficulty = difficulty;
    this.language = language;

    this.status = 'waiting'; // waiting, in_progress, completed
    this.currentRound = 0;
    this.player1Score = 0;
    this.player2Score = 0;
    this.rounds = [];
    this.usedPuzzleIds = [];
    this.currentPuzzle = null;
    this.roundStartTime = null;
    this.remaining = 0;
    this.roundTimer = null;
    this.aiTimer = null;
    this.player1HintsThisRound = 0;
    this.player2HintsThisRound = 0;
    this.winnerId = null;
    this.disconnectedPlayer = null;
    this.disconnectTime = null;
    this.disconnectTimer = null;

    this.player1SocketId = player1.socketId;
    this.player2SocketId = player2.socketId;
  }

  getState() {
    return {
      matchId: this.matchId,
      player1: {
        playerId: this.player1.playerId,
        displayName: this.player1.displayName,
        avatarId: this.player1.avatarId,
        isAi: this.player1.isAi || false,
      },
      player2: {
        playerId: this.player2.playerId,
        displayName: this.player2.displayName,
        avatarId: this.player2.avatarId,
        isAi: this.player2.isAi || false,
        aiDifficulty: this.player2.aiDifficulty,
      },
      status: this.status,
      currentRound: this.currentRound,
      player1Score: this.player1Score,
      player2Score: this.player2Score,
      rounds: this.rounds,
      difficulty: this.difficulty,
      language: this.language,
      remaining: this.remaining,
    };
  }
}

module.exports = { GameRoomManager };

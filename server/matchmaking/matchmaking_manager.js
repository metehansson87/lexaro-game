const { AI_FALLBACK_DELAY_MS } = require('../config/constants');

/**
 * Manages player matchmaking queue.
 * Pairs players by difficulty and language, falls back to AI after timeout.
 */
class MatchmakingManager {
  constructor(gameRoomManager, aiPlayerManager) {
    this.queue = new Map(); // socketId -> player info
    this.gameRooms = gameRoomManager;
    this.aiPlayers = aiPlayerManager;
    this.aiTimers = new Map(); // socketId -> timeout
  }

  get queueSize() {
    return this.queue.size;
  }

  /**
   * Add a player to the matchmaking queue.
   */
  joinQueue(playerInfo) {
    const { socketId, playerId, displayName, avatarId, difficulty, language } = playerInfo;

    // Remove from queue if already in it
    this.leaveQueue(socketId);

    this.queue.set(socketId, {
      socketId,
      playerId,
      displayName,
      avatarId,
      difficulty,
      language,
      joinedAt: Date.now(),
    });

    console.log(`Player ${displayName} joined queue (${difficulty}/${language}). Queue size: ${this.queue.size}`);

    // Try to find a match
    const match = this._findMatch(socketId);
    if (match) {
      this._createMatch(match.player1, match.player2);
    } else {
      // Set AI fallback timer
      const timer = setTimeout(() => {
        if (this.queue.has(socketId)) {
          console.log(`AI fallback for ${displayName}`);
          const player = this.queue.get(socketId);
          this.queue.delete(socketId);
          this._createAiMatch(player);
        }
      }, AI_FALLBACK_DELAY_MS);

      this.aiTimers.set(socketId, timer);
    }
  }

  /**
   * Remove a player from the queue.
   */
  leaveQueue(socketId) {
    this.queue.delete(socketId);
    const timer = this.aiTimers.get(socketId);
    if (timer) {
      clearTimeout(timer);
      this.aiTimers.delete(socketId);
    }
  }

  /**
   * Find a compatible opponent in the queue.
   */
  _findMatch(socketId) {
    const player = this.queue.get(socketId);
    if (!player) return null;

    for (const [otherId, other] of this.queue) {
      if (otherId === socketId) continue;
      if (other.difficulty === player.difficulty && other.language === player.language) {
        return { player1: player, player2: other };
      }
    }

    return null;
  }

  /**
   * Create a match between two players.
   */
  _createMatch(player1, player2) {
    this.leaveQueue(player1.socketId);
    this.leaveQueue(player2.socketId);

    this.gameRooms.createMatch({
      player1: {
        socketId: player1.socketId,
        playerId: player1.playerId,
        displayName: player1.displayName,
        avatarId: player1.avatarId,
        isAi: false,
      },
      player2: {
        socketId: player2.socketId,
        playerId: player2.playerId,
        displayName: player2.displayName,
        avatarId: player2.avatarId,
        isAi: false,
      },
      difficulty: player1.difficulty,
      language: player1.language,
    });
  }

  /**
   * Create a match with an AI opponent.
   */
  _createAiMatch(player) {
    const aiPlayer = this.aiPlayers.createAiPlayer(player.difficulty);

    this.gameRooms.createMatch({
      player1: {
        socketId: player.socketId,
        playerId: player.playerId,
        displayName: player.displayName,
        avatarId: player.avatarId,
        isAi: false,
      },
      player2: {
        socketId: null,
        playerId: aiPlayer.id,
        displayName: aiPlayer.displayName,
        avatarId: aiPlayer.avatarId,
        isAi: true,
        aiDifficulty: player.difficulty,
      },
      difficulty: player.difficulty,
      language: player.language,
    });
  }
}

module.exports = { MatchmakingManager };

const { v4: uuidv4 } = require('uuid');

/**
 * Manages AI player creation and behavior.
 * AI players simulate human-like behavior with configurable difficulty.
 */
class AiPlayerManager {
  constructor(gameRoomManager) {
    this.gameRooms = gameRoomManager;
    this.aiNames = [
      'WordBot', 'PuzzleMaster', 'LetterNinja', 'WordSmith',
      'BrainStorm', 'QuickType', 'LexiBot', 'AlphaWord',
      'CipherBot', 'VocabPro', 'SpellCheck', 'WordWiz',
      'LetterKing', 'PuzzleAce', 'SmartWord', 'QuizBot',
    ];
    this.aiAvatars = ['robot', 'ninja', 'crown', 'phoenix'];
  }

  /**
   * Create an AI player with the given difficulty.
   */
  createAiPlayer(difficulty = 'medium') {
    const name = this.aiNames[Math.floor(Math.random() * this.aiNames.length)];
    const avatar = this.aiAvatars[Math.floor(Math.random() * this.aiAvatars.length)];

    return {
      id: `ai_${uuidv4().slice(0, 8)}`,
      displayName: name,
      avatarId: avatar,
      isAi: true,
      aiDifficulty: difficulty,
    };
  }
}

module.exports = { AiPlayerManager };

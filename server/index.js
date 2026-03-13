const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');

const { MatchmakingManager } = require('./matchmaking/matchmaking_manager');
const { GameRoomManager } = require('./game_rooms/game_room_manager');
const { PuzzleEngine } = require('./puzzle_engine/puzzle_engine');
const { AiPlayerManager } = require('./ai_players/ai_player_manager');
const { LeaderboardManager } = require('./leaderboard/leaderboard_manager');
const { AnalyticsManager } = require('./analytics/analytics_manager');
const { DailyPuzzleManager } = require('./daily_puzzle/daily_puzzle_manager');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
  pingTimeout: 60000,
  pingInterval: 25000,
});

app.use(cors());
app.use(express.json());

// ── Initialize Managers ─────────────────────────────────────────────────────

const puzzleEngine = new PuzzleEngine();
const leaderboard = new LeaderboardManager();
const analytics = new AnalyticsManager();
const dailyPuzzle = new DailyPuzzleManager(puzzleEngine);
const gameRooms = new GameRoomManager(puzzleEngine, leaderboard, analytics);
const aiPlayers = new AiPlayerManager(gameRooms);
const matchmaking = new MatchmakingManager(gameRooms, aiPlayers);

// ── REST API ────────────────────────────────────────────────────────────────

app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    activeMatches: gameRooms.activeMatchCount,
    playersInQueue: matchmaking.queueSize,
  });
});

app.get('/api/leaderboard', (req, res) => {
  const { league, limit } = req.query;
  const entries = leaderboard.getLeaderboard(league, parseInt(limit) || 50);
  res.json(entries);
});

app.get('/api/daily-puzzle', (req, res) => {
  const { language } = req.query;
  const puzzle = dailyPuzzle.getDailyPuzzle(language || 'en');
  res.json(puzzle);
});

app.post('/api/daily-puzzle/complete', (req, res) => {
  const { playerId, solveTimeSeconds, hintsUsed } = req.body;
  const result = dailyPuzzle.completeDailyPuzzle(playerId, solveTimeSeconds, hintsUsed);
  res.json(result);
});

app.get('/api/analytics/summary', (req, res) => {
  res.json(analytics.getSummary());
});

// ── Socket.io Events ────────────────────────────────────────────────────────

io.on('connection', (socket) => {
  console.log(`Player connected: ${socket.id}`);
  analytics.trackEvent('player_connect', { socketId: socket.id });

  // ── Matchmaking ─────────────────────────────────────────────────────────

  socket.on('match:queue', (data) => {
    const { playerId, displayName, avatarId, difficulty, language } = data;
    matchmaking.joinQueue({
      socketId: socket.id,
      playerId: playerId || socket.id,
      displayName: displayName || 'Player',
      avatarId: avatarId || 'default',
      difficulty: difficulty || 'medium',
      language: language || 'en',
    });
  });

  socket.on('match:leave_queue', () => {
    matchmaking.leaveQueue(socket.id);
  });

  // ── Game Events ─────────────────────────────────────────────────────────

  socket.on('round:answer', (data) => {
    const { matchId, answer } = data;
    const result = gameRooms.submitAnswer(matchId, socket.id, answer);
    if (result) {
      io.to(matchId).emit('round:result', result);
    }
  });

  socket.on('round:hint', (data) => {
    const { matchId } = data;
    gameRooms.useHint(matchId, socket.id);
    socket.to(matchId).emit('opponent:hint', { playerId: socket.id });
  });

  // ── Reconnection ────────────────────────────────────────────────────────

  socket.on('match:reconnect', (data) => {
    const { matchId, playerId } = data;
    const room = gameRooms.reconnect(matchId, playerId, socket.id);
    if (room) {
      socket.join(matchId);
      socket.emit('match:state', room.getState());
    }
  });

  // ── Disconnect ──────────────────────────────────────────────────────────

  socket.on('disconnect', () => {
    console.log(`Player disconnected: ${socket.id}`);
    matchmaking.leaveQueue(socket.id);
    gameRooms.handleDisconnect(socket.id);
    analytics.trackEvent('player_disconnect', { socketId: socket.id });
  });
});

// ── Match Events from GameRoomManager ───────────────────────────────────────

gameRooms.on('match:created', (match) => {
  const { player1SocketId, player2SocketId, matchId } = match;
  const socket1 = io.sockets.sockets.get(player1SocketId);
  const socket2 = io.sockets.sockets.get(player2SocketId);

  if (socket1) socket1.join(matchId);
  if (socket2) socket2.join(matchId);

  io.to(matchId).emit('match:start', match.getState());
});

gameRooms.on('round:start', (data) => {
  io.to(data.matchId).emit('round:start', data);
});

gameRooms.on('round:tick', (data) => {
  io.to(data.matchId).emit('round:tick', { remaining: data.remaining });
});

gameRooms.on('round:timeout', (data) => {
  io.to(data.matchId).emit('round:timeout', data);
});

gameRooms.on('round:result', (data) => {
  io.to(data.matchId).emit('round:result', data);
});

gameRooms.on('match:complete', (data) => {
  io.to(data.matchId).emit('match:complete', data);
});

// ── Start Server ────────────────────────────────────────────────────────────

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Lexaro server running on port ${PORT}`);
  console.log(`Loaded ${puzzleEngine.totalPuzzleCount} puzzles`);
});

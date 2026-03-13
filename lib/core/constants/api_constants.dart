/// API and network configuration constants.
/// Update [serverBaseUrl] with your Hetzner VPS IP before deployment.
class ApiConstants {
  ApiConstants._();

  // ── Server ────────────────────────────────────────────────────────────────
  static const String serverBaseUrl = 'http://localhost:3000';
  static const String wsUrl = 'ws://localhost:3000';

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static const String authLogin = '/api/auth/login';
  static const String authRegister = '/api/auth/register';
  static const String authGuest = '/api/auth/guest';
  static const String leaderboardGlobal = '/api/leaderboard';
  static const String leaderboardSubmit = '/api/leaderboard/submit';
  static const String playerProfile = '/api/player/profile';
  static const String playerUpdate = '/api/player/update';
  static const String dailyPuzzle = '/api/daily-puzzle';
  static const String dailyPuzzleComplete = '/api/daily-puzzle/complete';
  static const String puzzleValidate = '/api/puzzle/validate';
  static const String achievements = '/api/achievements';
  static const String analytics = '/api/analytics';
  static const String liveOpsEvents = '/api/live-ops/events';

  // ── Socket Events ─────────────────────────────────────────────────────────
  static const String socketMatchQueue = 'match:queue';
  static const String socketMatchFound = 'match:found';
  static const String socketMatchStart = 'match:start';
  static const String socketRoundStart = 'round:start';
  static const String socketRoundAnswer = 'round:answer';
  static const String socketRoundResult = 'round:result';
  static const String socketRoundEnd = 'round:end';
  static const String socketMatchEnd = 'match:end';
  static const String socketHintUsed = 'hint:used';
  static const String socketPlayerDisconnect = 'player:disconnect';
  static const String socketPlayerReconnect = 'player:reconnect';
  static const String socketError = 'error';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration matchmakingTimeout = Duration(seconds: 30);
  static const Duration reconnectTimeout = Duration(seconds: 15);
}

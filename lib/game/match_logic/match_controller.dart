import 'dart:async';
import '../../core/constants/app_constants.dart';
import '../../data/models/match_model.dart';
import '../../data/models/puzzle_model.dart';
import '../../data/repositories/puzzle_repository.dart';

/// Controls the flow of a match (Best of 5 rounds).
/// Manages round lifecycle, timing, scoring, and match completion.
class MatchController {
  final PuzzleRepository _puzzleRepo;
  final String _language;
  final Difficulty _difficulty;

  MatchModel? _match;
  int _currentRoundNumber = 0;
  PuzzleModel? _currentPuzzle;
  Timer? _roundTimer;
  int _remainingSeconds = AppConstants.roundDurationSeconds;
  final List<String> _usedPuzzleIds = [];

  // Callbacks
  void Function(int seconds)? onTimerTick;
  void Function()? onTimerExpired;
  void Function(RoundResult result)? onRoundComplete;
  void Function(MatchModel match)? onMatchComplete;

  MatchController({
    required PuzzleRepository puzzleRepo,
    required String language,
    required Difficulty difficulty,
  })  : _puzzleRepo = puzzleRepo,
        _language = language,
        _difficulty = difficulty;

  // ── Getters ───────────────────────────────────────────────────────────────

  MatchModel? get match => _match;
  PuzzleModel? get currentPuzzle => _currentPuzzle;
  int get currentRoundNumber => _currentRoundNumber;
  int get remainingSeconds => _remainingSeconds;
  bool get isMatchComplete => _match?.isComplete ?? false;

  int get player1Score => _match?.player1Score ?? 0;
  int get player2Score => _match?.player2Score ?? 0;

  // ── Match Lifecycle ───────────────────────────────────────────────────────

  /// Initialize a new match.
  void initMatch(MatchModel matchModel) {
    _match = matchModel;
    _currentRoundNumber = 0;
    _usedPuzzleIds.clear();
  }

  /// Start the next round. Returns the puzzle for this round.
  PuzzleModel? startNextRound() {
    if (_match == null) return null;
    if (player1Score >= MatchModel.winsRequired ||
        player2Score >= MatchModel.winsRequired) {
      _completeMatch();
      return null;
    }
    if (_currentRoundNumber >= AppConstants.matchRounds) {
      _completeMatch();
      return null;
    }

    _currentRoundNumber++;
    _currentPuzzle = _puzzleRepo.getMatchPuzzle(
      language: _language,
      difficulty: _difficulty,
      excludeIds: _usedPuzzleIds,
    );
    if (_currentPuzzle != null) {
      _usedPuzzleIds.add(_currentPuzzle!.id);
    }

    _startTimer();
    return _currentPuzzle;
  }

  /// Submit an answer for the current round.
  RoundResult? submitAnswer({
    required String playerId,
    required String answer,
    required int player1HintsUsed,
    required int player2HintsUsed,
  }) {
    if (_currentPuzzle == null || _match == null) return null;

    final isCorrect =
        answer.replaceAll(' ', '').toUpperCase() == _currentPuzzle!.normalizedAnswer;

    if (!isCorrect) return null;

    _stopTimer();

    final elapsed = AppConstants.roundDurationSeconds - _remainingSeconds;
    final result = RoundResult(
      roundNumber: _currentRoundNumber,
      puzzleId: _currentPuzzle!.id,
      puzzleWord: _currentPuzzle!.word,
      winnerId: playerId,
      winnerTimeMs: elapsed * 1000,
      player1HintsUsed: player1HintsUsed,
      player2HintsUsed: player2HintsUsed,
    );

    _recordRoundResult(result);
    return result;
  }

  /// Handle round timeout (no one answered correctly).
  RoundResult handleTimeout({
    required int player1HintsUsed,
    required int player2HintsUsed,
  }) {
    _stopTimer();

    final result = RoundResult(
      roundNumber: _currentRoundNumber,
      puzzleId: _currentPuzzle?.id ?? '',
      puzzleWord: _currentPuzzle?.word ?? '',
      winnerId: null,
      timeout: true,
      player1HintsUsed: player1HintsUsed,
      player2HintsUsed: player2HintsUsed,
    );

    _recordRoundResult(result);
    return result;
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

  void _startTimer() {
    _remainingSeconds = AppConstants.roundDurationSeconds;
    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remainingSeconds--;
      onTimerTick?.call(_remainingSeconds);

      if (_remainingSeconds <= 0) {
        _stopTimer();
        onTimerExpired?.call();
      }
    });
  }

  void _stopTimer() {
    _roundTimer?.cancel();
    _roundTimer = null;
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _recordRoundResult(RoundResult result) {
    if (_match == null) return;

    final updatedRounds = [..._match!.rounds, result];
    _match = _match!.copyWith(
      rounds: updatedRounds,
      status: MatchStatus.inProgress,
    );

    onRoundComplete?.call(result);

    // Check if match is over
    if (player1Score >= MatchModel.winsRequired ||
        player2Score >= MatchModel.winsRequired ||
        _currentRoundNumber >= AppConstants.matchRounds) {
      _completeMatch();
    }
  }

  void _completeMatch() {
    if (_match == null) return;

    String? winnerId;
    if (player1Score > player2Score) {
      winnerId = _match!.player1.id;
    } else if (player2Score > player1Score) {
      winnerId = _match!.player2.id;
    }

    _match = _match!.copyWith(
      status: MatchStatus.completed,
      winnerId: winnerId,
    );

    onMatchComplete?.call(_match!);
  }

  void dispose() {
    _stopTimer();
  }
}

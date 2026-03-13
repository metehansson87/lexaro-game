import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../data/models/match_model.dart';
import '../../../data/models/puzzle_model.dart';

import '../../../game/ai_engine/ai_opponent.dart';
import '../../../game/puzzle_engine/puzzle_database.dart';
import '../../../game/puzzle_engine/scramble_engine.dart';
import '../../puzzle/presentation/widgets/answer_boxes.dart';
import '../../puzzle/presentation/widgets/game_keyboard.dart';
import 'matchmaking_screen.dart';

/// Match gameplay screen. Handles Best of 5 rounds with real-time scoring.
class MatchScreen extends StatefulWidget {
  final MatchScreenArgs args;

  const MatchScreen({super.key, required this.args});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  final ScrambleEngine _scrambleEngine = ScrambleEngine();
  final Random _random = Random();

  // Match state
  int _currentRound = 0;
  int _player1Score = 0;
  int _player2Score = 0;
  bool _matchOver = false;

  // Round state
  PuzzleModel? _puzzle;
  String _scrambled = '';
  List<String?> _answerLetters = [];
  Set<int> _hintIndices = {};
  int _hintsUsed = 0;
  int _remainingSeconds = AppConstants.roundDurationSeconds;
  Timer? _timer;
  bool _roundOver = false;
  String? _roundWinner;

  // AI
  AiOpponent? _aiOpponent;
  int _aiHintsUsed = 0;

  final List<String> _usedPuzzleIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.args.isAiMatch) {
      _aiOpponent = AiOpponent(
        difficulty: AiDifficulty.fromString(widget.args.difficulty.name),
      );
      _aiOpponent!.onAnswer = _handleAiAnswer;
      _aiOpponent!.onHintUsed = _handleAiHint;
    }
    _startNextRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _aiOpponent?.dispose();
    super.dispose();
  }

  void _startNextRound() {
    if (_matchOver) return;

    // Check if someone already won (first to 3)
    if (_player1Score >= MatchModel.winsRequired ||
        _player2Score >= MatchModel.winsRequired) {
      setState(() => _matchOver = true);
      return;
    }

    _currentRound++;
    if (_currentRound > AppConstants.matchRounds) {
      setState(() => _matchOver = true);
      return;
    }

    final puzzles = PuzzleDatabase.getPuzzles(
      language: 'en',
      difficulty: widget.args.difficulty,
    );
    final available = puzzles.where((p) => !_usedPuzzleIds.contains(p.id)).toList();
    if (available.isEmpty) return;

    _puzzle = available[_random.nextInt(available.length)];
    _usedPuzzleIds.add(_puzzle!.id);
    _scrambled = _scrambleEngine.scramble(_puzzle!.word);
    _answerLetters = List.filled(_puzzle!.letterCount, null);
    _hintIndices = {};
    _hintsUsed = 0;
    _aiHintsUsed = 0;
    _roundOver = false;
    _roundWinner = null;
    _remainingSeconds = AppConstants.roundDurationSeconds;

    _aiOpponent?.startSolving(_puzzle!);
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _endRound(null);
        }
      });
    });
  }

  void _handleAiAnswer(String answer) {
    if (_roundOver || _matchOver) return;
    if (_puzzle == null) return;
    if (answer.replaceAll(' ', '').toUpperCase() == _puzzle!.normalizedAnswer) {
      _endRound('AI');
    }
  }

  void _handleAiHint() {
    if (_roundOver) return;
    setState(() => _aiHintsUsed++);
  }

  void _enterLetter(String letter) {
    if (_roundOver || _matchOver) return;
    for (int i = 0; i < _answerLetters.length; i++) {
      if (_answerLetters[i] == null && !_hintIndices.contains(i)) {
        setState(() => _answerLetters[i] = letter.toUpperCase());
        if (!_answerLetters.contains(null)) {
          _checkAnswer();
        }
        return;
      }
    }
  }

  void _deleteLetter() {
    if (_roundOver || _matchOver) return;
    for (int i = _answerLetters.length - 1; i >= 0; i--) {
      if (_answerLetters[i] != null && !_hintIndices.contains(i)) {
        setState(() => _answerLetters[i] = null);
        return;
      }
    }
  }

  void _checkAnswer() {
    final answer = _answerLetters.join();
    if (_scrambleEngine.validateAnswer(_puzzle!, answer)) {
      _endRound('Player');
    } else {
      setState(() {
        for (int i = 0; i < _answerLetters.length; i++) {
          if (!_hintIndices.contains(i)) {
            _answerLetters[i] = null;
          }
        }
      });
    }
  }

  void _endRound(String? winner) {
    _timer?.cancel();
    _aiOpponent?.stop();
    setState(() {
      _roundOver = true;
      _roundWinner = winner;
      if (winner == 'Player') {
        _player1Score++;
      } else if (winner == 'AI') {
        _player2Score++;
      }
    });

    // Auto-advance after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _startNextRound();
    });
  }

  void _useHint() {
    if (_roundOver || _matchOver || _puzzle == null) return;
    if (_hintsUsed >= AppConstants.maxHintsPerRound) return;

    final hint = _scrambleEngine.revealHint(
      puzzle: _puzzle!,
      currentLetters: _answerLetters,
    );
    if (hint != null) {
      setState(() {
        _answerLetters[hint.index] = hint.letter;
        _hintIndices.add(hint.index);
        _hintsUsed++;
      });
      if (!_answerLetters.contains(null)) {
        _checkAnswer();
      }
    }
  }

  void _shuffleLetters() {
    if (_roundOver || _matchOver || _puzzle == null) return;
    setState(() {
      _scrambled = _scrambleEngine.scramble(_puzzle!.word);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_matchOver) return _buildMatchResult(context);
    if (_puzzle == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildMatchHud(context),
            // Hint counter for online matches
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withAlpha(77)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lightbulb_rounded,
                            color: AppColors.accent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Hints: $_hintsUsed / ${AppConstants.maxHintsPerRound}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Round $_currentRound / ${AppConstants.matchRounds}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _puzzle!.category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    AnswerBoxes(
                      puzzle: _puzzle!,
                      answerLetters: _answerLetters,
                      hintIndices: _hintIndices,
                      solved: _roundOver && _roundWinner == 'Player',
                    ),
                    const SizedBox(height: 24),
                    _buildScrambled(),
                    if (_roundOver) _buildRoundResult(context),
                  ],
                ),
              ),
            ),
            if (!_roundOver)
              GameKeyboard(
                puzzle: _puzzle!,
                currentLetters: _answerLetters,
                onLetterTap: _enterLetter,
                onDelete: _deleteLetter,
                onHint: _useHint,
                onShuffle: _shuffleLetters,
                hintsRemaining: AppConstants.maxHintsPerRound - _hintsUsed,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHud(BuildContext context) {
    final timerColor = _remainingSeconds <= 10
        ? AppColors.error
        : _remainingSeconds <= 20
            ? AppColors.warning
            : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Player 1 score
          _scoreChip('You', _player1Score, AppColors.primary),
          const Spacer(),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: timerColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: timerColor.withAlpha(102)),
            ),
            child: Text(
              '${_remainingSeconds}s',
              style: TextStyle(
                color: timerColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const Spacer(),
          // Player 2 / AI score
          _scoreChip(
            widget.args.isAiMatch ? 'AI' : 'Opponent',
            _player2Score,
            AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _scoreChip(String label, int score, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withAlpha(102)),
          ),
          child: Text(
            '$score',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrambled() {
    final letters = _scrambled.split('');
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: letters.map((letter) {
        return Container(
          width: 36,
          height: 36,
          decoration: AppDecorations.scrambledBox(),
          child: Center(
            child: Text(
              letter,
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoundResult(BuildContext context) {
    final Color color;
    final String message;
    if (_roundWinner == 'Player') {
      color = AppColors.success;
      message = 'You won this round!';
    } else if (_roundWinner == 'AI' || _roundWinner == 'Opponent') {
      color = AppColors.error;
      message = 'Opponent won this round!';
    } else {
      color = AppColors.warning;
      message = "Time's up! No winner.";
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(color: color.withAlpha(26)),
        child: Text(
          message,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildMatchResult(BuildContext context) {
    final playerWon = _player1Score > _player2Score;
    final draw = _player1Score == _player2Score;
    final goldEarned = draw
        ? AppConstants.matchLossGold
        : playerWon
            ? AppConstants.matchWinGold
            : AppConstants.matchLossGold;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  draw
                      ? Icons.handshake_rounded
                      : playerWon
                          ? Icons.emoji_events_rounded
                          : Icons.sentiment_dissatisfied_rounded,
                  size: 72,
                  color: draw
                      ? AppColors.warning
                      : playerWon
                          ? AppColors.accent
                          : AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  draw ? 'Draw!' : playerWon ? 'Victory!' : 'Defeat',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: draw
                            ? AppColors.warning
                            : playerWon
                                ? AppColors.accent
                                : AppColors.error,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$_player1Score - $_player2Score',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  decoration: AppDecorations.badge(color: AppColors.accent),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on,
                          color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '+$goldEarned Gold',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

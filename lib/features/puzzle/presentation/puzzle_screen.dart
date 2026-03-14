import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';

import '../../../data/models/puzzle_model.dart';
import '../../../game/puzzle_engine/puzzle_database.dart';
import '../../../game/puzzle_engine/scramble_engine.dart';
import 'widgets/answer_boxes.dart';
import 'widgets/game_keyboard.dart';

/// Arguments passed to the puzzle screen.
class PuzzleScreenArgs {
  final Difficulty difficulty;
  final String language;
  final PuzzleModel? specificPuzzle;

  const PuzzleScreenArgs({
    this.difficulty = Difficulty.medium,
    this.language = 'en',
    this.specificPuzzle,
  });
}

/// Main puzzle gameplay screen with responsive layout.
/// Answer area never goes under keyboard; boxes resize automatically.
class PuzzleScreen extends StatefulWidget {
  final PuzzleScreenArgs args;

  const PuzzleScreen({super.key, required this.args});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen>
    with TickerProviderStateMixin {
  final ScrambleEngine _scrambleEngine = ScrambleEngine();
  final Random _random = Random();

  PuzzleModel? _puzzle;
  String _scrambled = '';
  List<String?> _answerLetters = [];
  Set<int> _hintIndices = {};
  int _hintsUsed = 0;
  int _remainingSeconds = AppConstants.roundDurationSeconds;
  Timer? _timer;
  bool _solved = false;
  bool _failed = false;
  int _score = 0;

  late AnimationController _successController;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _loadPuzzle();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _successController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _loadPuzzle() {
    if (widget.args.specificPuzzle != null) {
      _puzzle = widget.args.specificPuzzle;
    } else {
      final puzzles = PuzzleDatabase.getPuzzles(
        language: widget.args.language,
        difficulty: widget.args.difficulty,
      );
      if (puzzles.isNotEmpty) {
        _puzzle = puzzles[_random.nextInt(puzzles.length)];
      }
    }

    if (_puzzle != null) {
      _scrambled = _scrambleEngine.scramble(_puzzle!.word);
      _answerLetters = List.filled(_puzzle!.letterCount, null);
      _hintIndices = {};
      _hintsUsed = 0;
      _solved = false;
      _failed = false;
      _remainingSeconds = AppConstants.roundDurationSeconds;
      _startTimer();
    }
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          _failed = true;
        }
      });
    });
  }

  void _enterLetter(String letter) {
    if (_solved || _failed) return;

    // Find first empty non-hint slot
    for (int i = 0; i < _answerLetters.length; i++) {
      if (_answerLetters[i] == null && !_hintIndices.contains(i)) {
        setState(() => _answerLetters[i] = letter.toUpperCase());

        // Check if complete
        if (!_answerLetters.contains(null)) {
          _checkAnswer();
        }
        return;
      }
    }
  }

  void _deleteLetter() {
    if (_solved || _failed) return;

    // Find last filled non-hint slot
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
      _timer?.cancel();
      setState(() {
        _solved = true;
        _score += _puzzle!.points;
      });
      _successController.forward();
    } else {
      _shakeController.forward(from: 0);
      // Clear non-hint letters
      setState(() {
        for (int i = 0; i < _answerLetters.length; i++) {
          if (!_hintIndices.contains(i)) {
            _answerLetters[i] = null;
          }
        }
      });
    }
  }

  void _useHint() {
    if (_solved || _failed || _puzzle == null) return;
    // Offline mode: unlimited hints (no limit check)

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

      // Check if puzzle is complete after hint
      if (!_answerLetters.contains(null)) {
        _checkAnswer();
      }
    }
  }

  void _shuffleLetters() {
    if (_solved || _failed || _puzzle == null) return;
    setState(() {
      _scrambled = _scrambleEngine.scramble(_puzzle!.word);
    });
  }

  void _nextPuzzle() {
    _loadPuzzle();
  }

  @override
  Widget build(BuildContext context) {
    if (_puzzle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Puzzle')),
        body: const Center(child: Text('No puzzles available')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HUD
            _buildHud(context),
            // Puzzle area (expands to fill available space above keyboard)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category
                    Text(
                      _puzzle!.category.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Answer boxes
                    AnswerBoxes(
                      puzzle: _puzzle!,
                      answerLetters: _answerLetters,
                      hintIndices: _hintIndices,
                      solved: _solved,
                    ),
                    const SizedBox(height: 24),
                    // Scrambled letters
                    _buildScrambled(context),
                    const SizedBox(height: 16),
                    // Overlays
                    if (_solved) _buildSuccessOverlay(context),
                    if (_failed) _buildFailOverlay(context),
                  ],
                ),
              ),
            ),
            // Keyboard (always at bottom, never overlaps answer)
            if (!_solved && !_failed)
              GameKeyboard(
                puzzle: _puzzle!,
                currentLetters: _answerLetters,
                onLetterTap: _enterLetter,
                onDelete: _deleteLetter,
                onHint: _useHint,
                onShuffle: _shuffleLetters,
                hintsRemaining: -1, // unlimited hints in offline mode
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHud(BuildContext context) {
    final timerColor = _remainingSeconds <= 10
        ? AppColors.error
        : _remainingSeconds <= 20
            ? AppColors.warning
            : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          // Difficulty badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: AppDecorations.badge(
              color: AppDecorations.difficultyColor(_puzzle!.difficulty.name),
            ),
            child: Text(
              _puzzle!.difficulty.label,
              style: TextStyle(
                color:
                    AppDecorations.difficultyColor(_puzzle!.difficulty.name),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: timerColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: timerColor.withAlpha(102)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_rounded, color: timerColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_remainingSeconds}s',
                  style: TextStyle(
                    color: timerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: AppDecorations.badge(color: AppColors.accent),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    color: AppColors.accent, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_score',
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
    );
  }

  Widget _buildScrambled(BuildContext context) {
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

  Widget _buildSuccessOverlay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(color: AppColors.success.withAlpha(26)),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 48),
          const SizedBox(height: 8),
          Text(
            'Correct!',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.success,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            '+${_puzzle!.points} points',
            style: const TextStyle(color: AppColors.accent),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _nextPuzzle,
            child: const Text('Next Puzzle'),
          ),
        ],
      ),
    );
  }

  Widget _buildFailOverlay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(color: AppColors.error.withAlpha(26)),
      child: Column(
        children: [
          const Icon(Icons.timer_off_rounded,
              color: AppColors.error, size: 48),
          const SizedBox(height: 8),
          Text(
            "Time's Up!",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.error,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'The answer was: ${_puzzle!.word}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _nextPuzzle,
            child: const Text('Try Another'),
          ),
        ],
      ),
    );
  }
}

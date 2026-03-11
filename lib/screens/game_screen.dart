// lib/screens/game_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_provider.dart';
import '../models/puzzle_model.dart';
import '../theme/app_theme.dart';
import '../widgets/game_keyboard.dart';
import '../widgets/game_hud.dart';
import '../widgets/success_overlay.dart';

class GameScreen extends StatefulWidget {
  final Difficulty difficulty;
  const GameScreen({super.key, required this.difficulty});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startRound(widget.difficulty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textSecondary),
          onPressed: () => _confirmExit(context),
        ),
        title: const Text('GameGuess',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(
              game.audio.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () => game.toggleSound(),
          ),
        ],
      ),
      body: ClipRect(
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // HUD
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: const GameHud(),
                  ),

                  // Puzzle area takes all remaining space
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return _PuzzleArea(
                            availableWidth: constraints.maxWidth,
                            availableHeight: constraints.maxHeight,
                          );
                        },
                      ),
                    ),
                  ),

                  // Keyboard pinned at bottom
                  const Padding(
                    padding: EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: GameKeyboard(),
                  ),
                ],
              ),
            ),
            if (game.roundState == RoundState.won)
              SuccessOverlay(
                onNextPuzzle: () => game.startRound(game.selectedDifficulty),
              ),
            if (game.roundState == RoundState.lost)
              FailOverlay(
                onRetry: () => game.startRound(game.selectedDifficulty),
                onMenu: () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leave Game?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Your current progress will be lost.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay', style: TextStyle(color: AppColors.primaryLight)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Puzzle Area ──────────────────────────────────────────────────────────────

class _PuzzleArea extends StatefulWidget {
  final double availableWidth;
  final double availableHeight;

  const _PuzzleArea({
    required this.availableWidth,
    required this.availableHeight,
  });

  @override
  State<_PuzzleArea> createState() => _PuzzleAreaState();
}

class _PuzzleAreaState extends State<_PuzzleArea> {
  String? _lastPuzzleId;
  int _lastShuffleCount = -1;
  final Map<String, String> _scrambleCache = {};

  String _scrambleWord(String word) {
    final chars = word.split('');
    for (int i = 0; i < 10; i++) {
      chars.shuffle(Random());
      if (chars.join() != word) break;
    }
    return chars.join();
  }

  void _updateScramble(List<String> words, String puzzleId, int shuffleCount) {
    if (_lastPuzzleId != puzzleId || _lastShuffleCount != shuffleCount) {
      _lastPuzzleId = puzzleId;
      _lastShuffleCount = shuffleCount;
      _scrambleCache.clear();
      for (final w in words) {
        _scrambleCache[w] = _scrambleWord(w);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final puzzle = game.puzzle;
    if (puzzle == null) return const SizedBox();

    final words = puzzle.words;
    _updateScramble(words, puzzle.id, game.shuffleCount);

    final int wordCount = words.length;
    final int longestWord = words.map((w) => w.length).reduce((a, b) => a > b ? a : b);

    // --- Box sizing ---
    // Fit longest word row into available width
    final double boxW = ((widget.availableWidth - 5.0 * (longestWord - 1)) / longestWord)
        .clamp(18.0, 40.0);
    final double boxH = (boxW * 1.1).clamp(22.0, 44.0);
    final double fontSize = (boxW * 0.46).clamp(9.0, 18.0);

    // Scrambled boxes
    final double sW = (boxW * 0.75).clamp(15.0, 30.0);
    final double sH = (sW * 1.1).clamp(18.0, 34.0);
    final double sFs = (sW * 0.46).clamp(8.0, 14.0);

    // Height budget check — shrink if needed
    // Scrambled: label(16) + rows(wordCount * (sH+4)) + padding(16)
    // Answer: label(16) + rows(wordCount * (boxH+5))
    // Category: 28, gaps: ~40
    double scrambledH = 16 + wordCount * (sH + 4) + 16;
    double answerH = 16 + wordCount * (boxH + 5);
    double totalNeeded = 28 + scrambledH + answerH + 40;

    // If too tall, scale everything down
    if (totalNeeded > widget.availableHeight) {
      final double scale = widget.availableHeight / totalNeeded;
      final double scaledBoxW = (boxW * scale).clamp(14.0, 40.0);
      final double scaledBoxH = (scaledBoxW * 1.1).clamp(16.0, 44.0);
      final double scaledFs = (scaledBoxW * 0.46).clamp(8.0, 18.0);
      return _buildContent(
        context, game, words,
        scaledBoxW, scaledBoxH, scaledFs,
        scaledBoxW * 0.75, scaledBoxH * 0.75, scaledFs * 0.82,
      );
    }

    return _buildContent(
      context, game, words,
      boxW, boxH, fontSize,
      sW, sH, sFs,
    );
  }

  Widget _buildContent(
    BuildContext context,
    GameProvider game,
    List<String> words,
    double boxW, double boxH, double fontSize,
    double sW, double sH, double sFs,
  ) {
    int boxIndex = 0;
    final puzzleData = game.puzzle!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Category
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Text(
            puzzleData.category.toUpperCase(),
            style: const TextStyle(
              color: AppColors.primaryLight, fontSize: 10,
              fontWeight: FontWeight.w600, letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // SCRAMBLED
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(
            children: [
              const Text('SCRAMBLED',
                style: TextStyle(color: AppColors.textMuted, fontSize: 9,
                  fontWeight: FontWeight.w600, letterSpacing: 2)),
              const SizedBox(height: 5),
              ...words.map((word) {
                final scrambled = _scrambleCache[word] ?? word;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: scrambled.split('').map((ch) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.5),
                      child: _ScrambledBox(letter: ch, w: sW, h: sH, fs: sFs),
                    )).toList(),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // YOUR ANSWER
        const Text('YOUR ANSWER',
          style: TextStyle(color: AppColors.textMuted, fontSize: 9,
            fontWeight: FontWeight.w600, letterSpacing: 2)),
        const SizedBox(height: 5),

        ...words.map((word) {
          final cells = <Widget>[];
          for (int i = 0; i < word.length; i++) {
            final idx = boxIndex;
            final letter = game.boxes.length > idx ? game.boxes[idx] : '';
            final isSelected = game.selectedBox == idx;
            final isFilled = letter.isNotEmpty;
            final isHinted = game.hintedBoxes.contains(idx);
            cells.add(Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _AnswerBox(
                letter: letter,
                isSelected: isSelected,
                isFilled: isFilled,
                isHinted: isHinted,
                w: boxW, h: boxH, fs: fontSize,
                onTap: () => game.selectBox(idx),
              ),
            ));
            boxIndex++;
          }
          boxIndex++;

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: cells,
            ),
          );
        }),
      ],
    );
  }

}

// ─── Box widgets ──────────────────────────────────────────────────────────────

class _ScrambledBox extends StatelessWidget {
  final String letter;
  final double w;
  final double h;
  final double fs;

  const _ScrambledBox({
    required this.letter,
    required this.w,
    required this.h,
    required this.fs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.18),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: TextStyle(
            color: AppColors.primaryLight,
            fontSize: fs,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _AnswerBox extends StatelessWidget {
  final String letter;
  final bool isSelected;
  final bool isFilled;
  final bool isHinted;
  final double w;
  final double h;
  final double fs;
  final VoidCallback onTap;

  const _AnswerBox({
    required this.letter,
    required this.isSelected,
    required this.isFilled,
    required this.isHinted,
    required this.w,
    required this.h,
    required this.fs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Hinted boxes get a golden border to visually distinguish them
    final BoxDecoration decoration = isHinted
        ? BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFFD700), width: 2),
          )
        : AppDecor.letterBox(selected: isSelected, filled: isFilled);

    final Color textColor = isHinted
        ? const Color(0xFFFFD700)
        : isSelected
            ? AppColors.primaryLight
            : isFilled
                ? AppColors.textPrimary
                : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: w,
        height: h,
        decoration: decoration,
        child: Center(
          child: Text(
            letter.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: fs,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

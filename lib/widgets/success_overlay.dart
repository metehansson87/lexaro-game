// lib/widgets/success_overlay.dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/game_provider.dart';
import '../theme/app_theme.dart';

class SuccessOverlay extends StatefulWidget {
  final VoidCallback onNextPuzzle;
  const SuccessOverlay({super.key, required this.onNextPuzzle});

  @override
  State<SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<SuccessOverlay> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _share(BuildContext context) {
    final game = context.read<GameProvider>();
    final puzzle = game.puzzle;
    if (puzzle == null) return;

    final timeUsed = GameProvider.roundDuration - game.timeLeft;
    final wordCount = puzzle.answer.split(' ').length;
    final boxes = List.filled(wordCount, '').map((_) => '🟩').join('');

    final text = 'I solved GameGuess! 🎮\n'
        '$boxes\n'
        '${puzzle.answer}\n'
        'Time: ${timeUsed}s\n'
        'Can you beat me? #GameGuess';

    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final points = game.puzzle?.points ?? 0;
    final timeUsed = GameProvider.roundDuration - game.timeLeft;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.accent,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Well Done! 🎉',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    game.puzzle?.answer ?? '',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solved in ${timeUsed}s',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Points
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accent, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '+$points points',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Share button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _share(context),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share Result'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Next puzzle button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: widget.onNextPuzzle,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Next Puzzle'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 30,
          gravity: 0.2,
          colors: const [
            AppColors.primary,
            AppColors.accent,
            AppColors.success,
            Colors.pink,
            Colors.cyan,
          ],
        ),
      ],
    );
  }
}

class FailOverlay extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onMenu;
  const FailOverlay({super.key, required this.onRetry, required this.onMenu});

  @override
  Widget build(BuildContext context) {
    final puzzle = context.read<GameProvider>().puzzle;
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.error.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_off_rounded, color: AppColors.error, size: 52),
              const SizedBox(height: 14),
              const Text("Time's Up!",
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (puzzle != null) ...[
                const Text('The answer was:',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Text(puzzle.answer,
                    style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onMenu,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.surfaceLight),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Menu'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
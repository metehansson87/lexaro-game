import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../data/models/puzzle_model.dart';
import '../../../data/repositories/puzzle_repository.dart';
import '../../puzzle/presentation/puzzle_screen.dart';
import '../../../core/routing/app_router.dart';

/// Daily puzzle screen with countdown timer and completion tracking.
class DailyPuzzleScreen extends StatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  State<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends State<DailyPuzzleScreen> {
  final PuzzleRepository _repo = PuzzleRepository();
  final bool _completed = false;
  PuzzleModel? _dailyPuzzle;

  @override
  void initState() {
    super.initState();
    _dailyPuzzle = _repo.getDailyPuzzle(language: 'en');
  }

  @override
  Widget build(BuildContext context) {
    final timeRemaining = app_date.AppDateUtils.timeUntilNextDay();
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes % 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Puzzle'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Calendar icon
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withAlpha(26),
                  border: Border.all(
                      color: AppColors.success.withAlpha(102), width: 2),
                ),
                child: Icon(
                  _completed
                      ? Icons.check_circle_rounded
                      : Icons.calendar_today_rounded,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _completed ? 'Completed!' : "Today's Challenge",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _completed
                    ? 'Come back tomorrow for a new puzzle!'
                    : 'Solve the daily puzzle to earn gold',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Reward info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(
                    color: AppColors.accent.withAlpha(13)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on,
                        color: AppColors.accent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+${AppConstants.dailyPuzzleReward} Gold Reward',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Timer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Next puzzle in ${hours}h ${minutes}m',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Play button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _completed || _dailyPuzzle == null
                      ? null
                      : () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.puzzle,
                            arguments: PuzzleScreenArgs(
                              specificPuzzle: _dailyPuzzle,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  child: Text(
                    _completed ? 'Completed' : 'Solve Daily Puzzle',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

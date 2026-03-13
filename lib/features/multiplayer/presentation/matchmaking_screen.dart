import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/routing/app_router.dart';
import '../../../data/models/puzzle_model.dart';

/// Matchmaking screen where players wait in queue for an opponent.
/// Supports both online matching and AI opponent selection.
class MatchmakingScreen extends StatefulWidget {
  const MatchmakingScreen({super.key});

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen>
    with SingleTickerProviderStateMixin {
  bool _searching = false;
  int _elapsedSeconds = 0;
  Timer? _searchTimer;
  Difficulty _selectedDifficulty = Difficulty.medium;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _dotController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _searching = true;
      _elapsedSeconds = 0;
    });
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);

      // Auto-match with AI after 10 seconds (configurable)
      if (_elapsedSeconds >= 10) {
        _matchWithAi();
      }
    });
  }

  void _cancelSearch() {
    _searchTimer?.cancel();
    setState(() => _searching = false);
  }

  void _matchWithAi() {
    _searchTimer?.cancel();
    Navigator.pushReplacementNamed(
      context,
      AppRouter.match,
      arguments: MatchScreenArgs(
        isAiMatch: true,
        difficulty: _selectedDifficulty,
      ),
    );
  }

  void _playVsAi() {
    Navigator.pushReplacementNamed(
      context,
      AppRouter.match,
      arguments: MatchScreenArgs(
        isAiMatch: true,
        difficulty: _selectedDifficulty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Match'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            _cancelSearch();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              if (_searching) _buildSearching(context) else _buildOptions(context),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Column(
      children: [
        // Match icon
        Container(
          padding: const EdgeInsets.all(24),
          decoration: AppDecorations.cardElevated(),
          child: const Icon(Icons.sports_esports_rounded,
              size: 64, color: AppColors.primary),
        ),
        const SizedBox(height: 32),
        Text(
          'Choose your challenge',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 32),

        // Difficulty selector
        Row(
          children: Difficulty.values.map((d) {
            final selected = d == _selectedDifficulty;
            final color = AppDecorations.difficultyColor(d.name);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDifficulty = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? color.withAlpha(51) : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? color : Colors.white.withAlpha(26),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      d.label,
                      style: TextStyle(
                        color: selected ? color : AppColors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),

        // Online match button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _startSearch,
            icon: const Icon(Icons.people_rounded),
            label: const Text('Find Opponent'),
          ),
        ),
        const SizedBox(height: 12),

        // AI match button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _playVsAi,
            icon: const Icon(Icons.smart_toy_rounded),
            label: const Text('Play vs AI'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.primary.withAlpha(128)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearching(BuildContext context) {
    return Column(
      children: [
        // Animated search indicator
        AnimatedBuilder(
          animation: _dotController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withAlpha(
                    (128 + 127 * _dotController.value).toInt(),
                  ),
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.search_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Searching for opponent...',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '${_elapsedSeconds}s',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        if (_elapsedSeconds >= 5) ...[
          const SizedBox(height: 16),
          Text(
            'AI opponent available...',
            style: TextStyle(
              color: AppColors.accent.withAlpha(179),
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: _cancelSearch,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              foregroundColor: AppColors.error,
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}

/// Arguments for the match screen.
class MatchScreenArgs {
  final bool isAiMatch;
  final Difficulty difficulty;
  final String? matchId;

  const MatchScreenArgs({
    this.isAiMatch = false,
    this.difficulty = Difficulty.medium,
    this.matchId,
  });
}

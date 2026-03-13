import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../data/models/achievement_model.dart';

/// Achievements screen displaying all achievements with progress tracking.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementModel.allAchievements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return _buildAchievementTile(context, achievement);
        },
      ),
    );
  }

  Widget _buildAchievementTile(
      BuildContext context, AchievementModel achievement) {
    final progress = achievement.progress.clamp(0.0, 1.0);
    final isUnlocked = achievement.unlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.card(
        color: isUnlocked ? AppColors.accent.withAlpha(13) : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.accent.withAlpha(26)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: isUnlocked
                  ? Border.all(color: AppColors.accent.withAlpha(102))
                  : null,
            ),
            child: Icon(
              _getIcon(achievement.iconName),
              color: isUnlocked ? AppColors.accent : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (isUnlocked)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.accent, size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUnlocked ? AppColors.accent : AppColors.primary,
                    ),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${achievement.currentValue} / ${achievement.targetValue}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on,
                            color: AppColors.accent, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '+${achievement.goldReward}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'puzzle':
        return Icons.extension_rounded;
      case 'trophy':
        return Icons.emoji_events_rounded;
      case 'fire':
        return Icons.whatshot_rounded;
      case 'calendar':
        return Icons.calendar_today_rounded;
      case 'speed':
        return Icons.speed_rounded;
      case 'brain':
        return Icons.psychology_rounded;
      case 'league':
        return Icons.leaderboard_rounded;
      case 'star':
        return Icons.star_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../data/models/live_ops_event.dart';

/// Live operations screen displaying active and upcoming events.
class LiveOpsScreen extends StatelessWidget {
  const LiveOpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample events for UI demonstration
    final events = <LiveOpsEvent>[
      LiveOpsEvent(
        id: 'double_gold_weekend',
        title: 'Double Gold Weekend',
        description: 'Earn 2x gold from all matches this weekend!',
        type: LiveOpsEventType.doubleGold,
        startDate: DateTime.now().subtract(const Duration(hours: 6)),
        endDate: DateTime.now().add(const Duration(days: 2)),
        goldReward: 0,
        bonusMultiplier: 2,
      ),
      LiveOpsEvent(
        id: 'spring_tournament',
        title: 'Spring Tournament',
        description: 'Compete in the seasonal tournament for exclusive rewards!',
        type: LiveOpsEventType.tournament,
        startDate: DateTime.now().add(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        goldReward: 500,
        bonusMultiplier: 1,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: events.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded,
                      color: AppColors.textMuted, size: 48),
                  SizedBox(height: 16),
                  Text('No active events',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (context, index) =>
                  _buildEventCard(context, events[index]),
            ),
    );
  }

  Widget _buildEventCard(BuildContext context, LiveOpsEvent event) {
    final isActive = event.isActive;
    final color = _eventColor(event.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppDecorations.cardElevated(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withAlpha(77), color.withAlpha(26)],
              ),
            ),
            child: Row(
              children: [
                Icon(_eventIcon(event.type), color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isActive ? AppColors.success : AppColors.info)
                              .withAlpha(51),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isActive ? 'ACTIVE' : 'UPCOMING',
                          style: TextStyle(
                            color: isActive ? AppColors.success : AppColors.info,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                if (event.goldReward > 0)
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: AppColors.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Reward: ${event.goldReward} Gold',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                if (event.bonusMultiplier > 1)
                  Row(
                    children: [
                      const Icon(Icons.double_arrow_rounded,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${event.bonusMultiplier}x Multiplier',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Text(
                  isActive
                      ? 'Ends in ${event.timeRemaining}'
                      : 'Starts in ${event.timeRemaining}',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _eventColor(LiveOpsEventType type) {
    switch (type) {
      case LiveOpsEventType.doubleGold:
        return AppColors.accent;
      case LiveOpsEventType.tournament:
        return AppColors.primary;
      case LiveOpsEventType.specialPuzzle:
        return AppColors.success;
      case LiveOpsEventType.limitedTimeChallenge:
        return AppColors.info;
      case LiveOpsEventType.seasonalEvent:
        return Colors.purpleAccent;
    }
  }

  IconData _eventIcon(LiveOpsEventType type) {
    switch (type) {
      case LiveOpsEventType.doubleGold:
        return Icons.monetization_on_rounded;
      case LiveOpsEventType.tournament:
        return Icons.emoji_events_rounded;
      case LiveOpsEventType.specialPuzzle:
        return Icons.extension_rounded;
      case LiveOpsEventType.limitedTimeChallenge:
        return Icons.timer_rounded;
      case LiveOpsEventType.seasonalEvent:
        return Icons.park_rounded;
    }
  }
}

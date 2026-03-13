/// Date utility functions for daily puzzles, rewards, and streaks.
class AppDateUtils {
  AppDateUtils._();

  /// Check if two dates are on the same calendar day (UTC).
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if a date is today (UTC).
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now().toUtc());
  }

  /// Check if a date is yesterday (UTC).
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Get a deterministic daily seed for consistent puzzle selection worldwide.
  static int dailySeed([DateTime? date]) {
    final d = date ?? DateTime.now().toUtc();
    return d.year * 10000 + d.month * 100 + d.day;
  }

  /// Get time remaining until next UTC midnight (for daily puzzle reset).
  static Duration timeUntilNextDay() {
    final now = DateTime.now().toUtc();
    final nextMidnight = DateTime.utc(now.year, now.month, now.day + 1);
    return nextMidnight.difference(now);
  }

  /// Format time remaining as "Xh Ym" or "Ym Zs".
  static String formatTimeRemaining(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
  }
}

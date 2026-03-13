import 'dart:math';

/// String utility functions used across the game.
class StringUtils {
  StringUtils._();

  /// Remove all spaces and convert to uppercase for answer comparison.
  static String normalizeAnswer(String input) {
    return input.replaceAll(' ', '').toUpperCase().trim();
  }

  /// Split a multi-word answer into individual words.
  static List<String> splitWords(String answer) {
    return answer.toUpperCase().split(' ').where((w) => w.isNotEmpty).toList();
  }

  /// Count occurrences of each letter in a string (ignoring spaces).
  static Map<String, int> letterFrequency(String text) {
    final counts = <String, int>{};
    for (final char in normalizeAnswer(text).split('')) {
      counts[char] = (counts[char] ?? 0) + 1;
    }
    return counts;
  }

  /// Scramble letters of a word, ensuring the result differs from original.
  static String scrambleWord(String word) {
    final chars = word.toUpperCase().split('');
    if (chars.length <= 1) return word;

    for (int attempt = 0; attempt < 20; attempt++) {
      chars.shuffle(Random());
      if (chars.join() != word.toUpperCase()) break;
    }
    return chars.join();
  }

  /// Generate a random alphanumeric ID of given length.
  static String generateId([int length = 16]) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rng = Random();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  /// Format duration as MM:SS.
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format large numbers with K/M suffixes.
  static String formatCompactNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

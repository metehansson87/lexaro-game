/// Input validation utilities.
class Validators {
  Validators._();

  /// Validate a display name (2-20 characters, alphanumeric + spaces).
  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 20) {
      return 'Name must be 20 characters or less';
    }
    if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value.trim())) {
      return 'Only letters, numbers, and spaces allowed';
    }
    return null;
  }

  /// Validate email format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w{2,}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validate password (minimum 6 characters).
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate a puzzle answer (non-empty, letters only).
  static bool isValidAnswer(String answer) {
    return answer.isNotEmpty &&
        RegExp(r'^[A-Za-z ]+$').hasMatch(answer);
  }
}

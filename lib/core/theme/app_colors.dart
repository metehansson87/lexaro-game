import 'package:flutter/material.dart';

/// Centralized color palette for the entire application.
/// Dark theme with neon accents — professional mobile game aesthetic.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0F0F1E);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF25253E);
  static const Color surfaceElevated = Color(0xFF2D2D4A);

  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B85FF);
  static const Color primaryDark = Color(0xFF4A42CC);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFFFD700);
  static const Color accentLight = Color(0xFFFFE44D);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color error = Color(0xFFFF5252);
  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF29B6F6);

  // ── Difficulty ────────────────────────────────────────────────────────────
  static const Color easy = Color(0xFF4CAF50);
  static const Color medium = Color(0xFFFFC107);
  static const Color hard = Color(0xFFFF5252);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color textMuted = Color(0xFF6B6B8E);
  static const Color textDisabled = Color(0xFF4A4A68);

  // ── Letter Box ────────────────────────────────────────────────────────────
  static const Color boxEmpty = Color(0xFF252540);
  static const Color boxFilled = Color(0xFF3A3A6E);
  static const Color boxSelected = Color(0xFF6C63FF);
  static const Color boxHint = Color(0xFFFFD700);
  static const Color boxCorrect = Color(0xFF4CAF50);

  // ── Keyboard ──────────────────────────────────────────────────────────────
  static const Color keyActive = Color(0xFF3D3D6B);
  static const Color keyInactive = Color(0xFF1E1E3A);
  static const Color keyBg = Color(0xFF2A2A4A);

  // ── League Colors ─────────────────────────────────────────────────────────
  static const Color leagueBronze = Color(0xFFCD7F32);
  static const Color leagueSilver = Color(0xFFC0C0C0);
  static const Color leagueGold = Color(0xFFFFD700);
  static const Color leagueDiamond = Color(0xFF00E5FF);

  // ── Neon Glow Effects ─────────────────────────────────────────────────────
  static Color neonPurple = primary.withAlpha(102);
  static Color neonGold = accent.withAlpha(102);
  static Color neonGreen = success.withAlpha(102);
  static Color neonRed = error.withAlpha(102);
}

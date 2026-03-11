// lib/theme/app_theme.dart
// Visual design system: colors, typography, spacing, decoration helpers

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Brand palette
  static const background   = Color(0xFF0F0F1E); // Deep dark navy
  static const surface      = Color(0xFF1A1A2E); // Card surface
  static const surfaceLight = Color(0xFF25253E); // Elevated surface
  static const primary      = Color(0xFF6C63FF); // Purple accent
  static const primaryLight = Color(0xFF8B85FF);
  static const accent       = Color(0xFFFFD700); // Gold
  static const success      = Color(0xFF4CAF50); // Green
  static const error        = Color(0xFFFF5252); // Red

  // Difficulty colors
  static const easy   = Color(0xFF4CAF50);
  static const medium = Color(0xFFFFC107);
  static const hard   = Color(0xFFFF5252);

  // Text
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0CC);
  static const textMuted     = Color(0xFF6B6B8E);

  // Letter box
  static const boxEmpty    = Color(0xFF252540);
  static const boxFilled   = Color(0xFF3A3A6E);
  static const boxSelected = Color(0xFF6C63FF);
  static const boxHint     = Color(0xFFFFD700);

  // Keyboard key
  static const keyActive   = Color(0xFF3D3D6B);
  static const keyInactive = Color(0xFF1E1E3A);
  static const keyBg       = Color(0xFF2A2A4A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.primary,
      secondary: AppColors.accent,
      surface:   AppColors.surface,
      error:     AppColors.error,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.poppins(
        color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
      bodyMedium: GoogleFonts.poppins(
        color: AppColors.textSecondary, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
  );
}

// Decorations reused across widgets
class AppDecor {
  AppDecor._();

  static BoxDecoration card({Color? color, double radius = 16}) => BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white.withOpacity(0.06)),
  );

  static BoxDecoration letterBox({required bool selected, required bool filled, bool hint = false}) =>
      BoxDecoration(
        color: hint
            ? AppColors.boxHint.withOpacity(0.2)
            : filled
              ? AppColors.boxFilled
              : selected
                ? AppColors.boxSelected.withOpacity(0.3)
                : AppColors.boxEmpty,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hint
              ? AppColors.boxHint
              : selected
                ? AppColors.boxSelected
                : filled
                  ? AppColors.primary.withOpacity(0.6)
                  : Colors.white.withOpacity(0.15),
          width: selected ? 2 : 1.5,
        ),
      );
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Reusable decoration factories for consistent visual language across the app.
class AppDecorations {
  AppDecorations._();

  // ── Card ──────────────────────────────────────────────────────────────────
  static BoxDecoration card({Color? color, double radius = 16}) => BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withAlpha(15)),
      );

  static BoxDecoration cardElevated({double radius = 16}) => BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(64),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // ── Letter Box ────────────────────────────────────────────────────────────
  static BoxDecoration letterBox({
    required bool selected,
    required bool filled,
    bool hint = false,
  }) =>
      BoxDecoration(
        color: hint
            ? AppColors.boxHint.withAlpha(51)
            : filled
                ? AppColors.boxFilled
                : selected
                    ? AppColors.boxSelected.withAlpha(77)
                    : AppColors.boxEmpty,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hint
              ? AppColors.boxHint
              : selected
                  ? AppColors.boxSelected
                  : filled
                      ? AppColors.primary.withAlpha(153)
                      : Colors.white.withAlpha(38),
          width: selected || hint ? 2 : 1.5,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(51),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      );

  // ── Scrambled Box ─────────────────────────────────────────────────────────
  static BoxDecoration scrambledBox() => BoxDecoration(
        color: AppColors.primary.withAlpha(46),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.primary.withAlpha(89)),
      );

  // ── Neon Glow Button ──────────────────────────────────────────────────────
  static BoxDecoration neonButton({
    Color color = AppColors.primary,
    double radius = 14,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(204)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(102),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  // ── Badge ─────────────────────────────────────────────────────────────────
  static BoxDecoration badge({required Color color, double radius = 20}) =>
      BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withAlpha(102)),
      );

  // ── League Badge ──────────────────────────────────────────────────────────
  static Color leagueColor(String league) {
    switch (league.toLowerCase()) {
      case 'diamond':
        return AppColors.leagueDiamond;
      case 'gold':
        return AppColors.leagueGold;
      case 'silver':
        return AppColors.leagueSilver;
      default:
        return AppColors.leagueBronze;
    }
  }

  // ── Difficulty Color ──────────────────────────────────────────────────────
  static Color difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'hard':
        return AppColors.hard;
      case 'medium':
        return AppColors.medium;
      default:
        return AppColors.easy;
    }
  }
}

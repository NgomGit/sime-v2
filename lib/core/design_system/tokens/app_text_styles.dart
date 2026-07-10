import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String _font = 'Gilroy';

  // ── Display ──────────────────────────────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _font, fontSize: 42, fontWeight: FontWeight.w700,
    letterSpacing: -1.2, height: 1.1, color: AppColors.white,
  );

  // ── Heading ──────────────────────────────────────────────────────────────────
  static const TextStyle headingXL = TextStyle(
    fontFamily: _font, fontSize: 28, fontWeight: FontWeight.w700,
    letterSpacing: -0.8, height: 1.15, color: AppColors.neutral800,
  );
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _font, fontSize: 22, fontWeight: FontWeight.w700,
    letterSpacing: -0.6, height: 1.2, color: AppColors.neutral800,
  );
  static const TextStyle headingMedium = TextStyle(
    fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w700,
    letterSpacing: -0.5, height: 1.25, color: AppColors.neutral800,
  );
  static const TextStyle headingSmall = TextStyle(
    fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w700,
    letterSpacing: -0.3, height: 1.3, color: AppColors.neutral800,
  );

  // ── Body ─────────────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w400,
    height: 1.7, color: AppColors.neutral500,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w500,
    height: 1.6, color: AppColors.neutral500,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w400,
    height: 1.5, color: AppColors.neutral400,
  );

  // ── Label ────────────────────────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600,
    letterSpacing: -0.2, color: AppColors.neutral800,
  );
  static const TextStyle labelMedium = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.neutral800,
  );
  static const TextStyle labelSmall = TextStyle(
    fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w600,
    letterSpacing: 0.4, color: AppColors.neutral400,
  );
  static const TextStyle labelXSmall = TextStyle(
    fontFamily: _font, fontSize: 10, fontWeight: FontWeight.w600,
    letterSpacing: 0.3, color: AppColors.neutral300,
  );

  // ── Button ───────────────────────────────────────────────────────────────────
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: _font, fontSize: 14, fontWeight: FontWeight.w600,
    letterSpacing: -0.2, color: AppColors.white,
  );
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // ── Caption ──────────────────────────────────────────────────────────────────
  static const TextStyle caption = TextStyle(
    fontFamily: _font, fontSize: 10, fontWeight: FontWeight.w500,
    color: AppColors.neutral300,
  );

  // ── Eyebrow (section labels) ─────────────────────────────────────────────────
  static const TextStyle eyebrow = TextStyle(
    fontFamily: _font, fontSize: 11, fontWeight: FontWeight.w600,
    letterSpacing: 0.8, color: AppColors.primary400,
  );
}

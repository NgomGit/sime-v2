import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary — Forest green aligned with ANPEJ logo
  static const Color primary900 = Color(0xFF0D1F14);
  static const Color primary800 = Color(0xFF1B5E20);
  static const Color primary700 = Color(0xFF2E7D32);
  static const Color primary500 = Color(0xFF27B060);
  static const Color primary100 = Color(0xFFEAF6EE);
  static const Color primary50  = Color(0xFFF0FDF4);

  // Accent — Gold from ANPEJ logo
  static const Color accent500  = Color(0xFFF9A825);
  static const Color accent100  = Color(0xFFFFF8E1);

  // Neutrals
  static const Color neutral900 = Color(0xFF1C1C1C);
  static const Color neutral700 = Color(0xFF444441);
  static const Color neutral600 = Color(0xFF5F5E5A);
  static const Color neutral400 = Color(0xFF8A8A85);
  static const Color neutral300 = Color(0xFFA8A8A3);
  static const Color neutral200 = Color(0xFFD3D1C7);
  static const Color neutral100 = Color(0xFFEDEDE8);
  static const Color neutral50  = Color(0xFFF7F6F2);
  static const Color white      = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF27B060);
  static const Color error   = Color(0xFFE53935);
  static const Color info    = Color(0xFF1565C0);
  static const Color warning = Color(0xFFF9A825);

  // Surfaces
  static const Color backgroundDark  = Color(0xFF0D1F14);
  static const Color backgroundLight = Color(0xFFF7F6F2);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color border          = Color(0xFFEDEDE8);
}

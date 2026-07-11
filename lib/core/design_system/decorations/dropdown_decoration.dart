 import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';

/// Décoration unifiée calquée sur tes tokens graphiques ANPEJ
InputDecoration buildDropdownDecoration({bool isEnabled = true}) {
    return InputDecoration(
      filled: true,
      isDense: true, // 👈 Force un layout compact et propre
      fillColor: isEnabled ? AppColors.neutral50 : AppColors.neutral100,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sp12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(
            color: AppColors.border, width: AppDimensions.borderThin),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(
            color: AppColors.secondary600, width: AppDimensions.borderMedium),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        borderSide: const BorderSide(
            color: AppColors.border, width: AppDimensions.borderThin),
      ),
    );
  }

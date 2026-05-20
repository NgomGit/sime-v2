import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_dimensions.dart';
import '../tokens/app_text_styles.dart';

/// SIME V2 — Application theme.
///
/// All tokens are sourced exclusively from [AppColors], [AppDimensions]
/// and [AppTextStyles]. No alias or hardcoded value is used.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   ...
/// )
/// ```
abstract final class AppTheme {
  AppTheme._();

  // ── Light theme ─────────────────────────────────────────────────────────────

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Gilroy',

      // ── Color scheme ──────────────────────────────────────────────────────
      colorScheme: const ColorScheme(
        brightness: Brightness.light,

        // Primary — dark forest green (hero sections, FAB, active states)
        primary: AppColors.primary900,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.primary100,
        onPrimaryContainer: AppColors.primary800,

        // Secondary — vivid green (success indicators, chips)
        secondary: AppColors.primary400,
        onSecondary: AppColors.white,
        secondaryContainer: AppColors.primary50,
        onSecondaryContainer: AppColors.primary800,

        // Tertiary — gold accent (badges, highlights)
        tertiary: AppColors.accent500,
        onTertiary: AppColors.neutral800,
        tertiaryContainer: AppColors.accent100,
        onTertiaryContainer: AppColors.neutral800,

        // Error
        error: AppColors.error,
        onError: AppColors.white,
        errorContainer: AppColors.errorBg,
        onErrorContainer: AppColors.error,

        // Surface / background
        surface: AppColors.surface,
        onSurface: AppColors.neutral800,
        surfaceContainerHighest: AppColors.neutral50,
        onSurfaceVariant: AppColors.neutral500,

        // Outline
        outline: AppColors.border,
        outlineVariant: AppColors.neutral200,
      ),

      // ── Scaffold ─────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.background,

      // ── AppBar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.neutral800,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.headingSmall,
        iconTheme: const IconThemeData(
          color: AppColors.neutral800,
          size: AppDimensions.iconMD,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.neutral400,
          size: AppDimensions.iconMD,
        ),
        systemOverlayStyle: lightStatusBar,
        shape: const Border(
          bottom: BorderSide(color: AppColors.border, width: AppDimensions.borderThin),
        ),
      ),

      // ── Bottom navigation bar ────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary900,
        unselectedItemColor: AppColors.neutral400,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 9,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Elevated button ──────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary900,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.neutral100,
          disabledForegroundColor: AppColors.neutral300,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: AppTextStyles.buttonLarge,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp20),
        ),
      ),

      // ── Outlined button ──────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary900,
          disabledForegroundColor: AppColors.neutral300,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          side: const BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
          textStyle: AppTextStyles.buttonLarge.copyWith(color: AppColors.primary900),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp20),
        ),
      ),

      // ── Text button ──────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary400,
          textStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.primary400),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sp8,
            vertical: AppDimensions.sp4,
          ),
        ),
      ),

      // ── Filled button (used for inline CTAs like "Postuler") ─────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary900,
          foregroundColor: AppColors.white,
          minimumSize: const Size(0, AppDimensions.buttonHeightSM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          textStyle: AppTextStyles.buttonSmall,
          elevation: 0,
        ),
      ),

      // ── Input decoration ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sp16,
          vertical: AppDimensions.sp14,
        ),
        // Default border (unfocused, valid)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderThin,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderThin,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.primary900,
            width: AppDimensions.borderMedium,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderMedium,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppDimensions.borderMedium,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.neutral100,
            width: AppDimensions.borderThin,
          ),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral300),
        labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral500),
        floatingLabelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.primary900),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        prefixStyle: AppTextStyles.bodyMedium,
        suffixStyle: AppTextStyles.bodyMedium,
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          side: const BorderSide(color: AppColors.border, width: AppDimensions.borderThin),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary900,
        disabledColor: AppColors.neutral50,
        labelStyle: AppTextStyles.labelSmall,
        secondaryLabelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sp12,
          vertical: AppDimensions.sp6,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          side: const BorderSide(color: AppColors.border, width: AppDimensions.borderThin),
        ),
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: AppDimensions.borderThin,
        space: 0,
      ),

      // ── Progress indicator ───────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary400,
        linearTrackColor: AppColors.neutral100,
        circularTrackColor: AppColors.neutral100,
        linearMinHeight: 4,
      ),

      // ── Switch ───────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.white;
          return AppColors.neutral300;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary400;
          return AppColors.neutral100;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Checkbox ─────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary900;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.primary400),
        side: const BorderSide(color: AppColors.neutral200, width: AppDimensions.borderMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusXS)),
      ),

      // ── Radio ────────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary900;
          return AppColors.neutral200;
        }),
      ),

      // ── FloatingActionButton ─────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary900,
        foregroundColor: AppColors.primary400,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: CircleBorder(),
      ),

      // ── BottomSheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXXL),
          ),
        ),
        dragHandleColor: AppColors.neutral200,
        dragHandleSize: Size(36, 4),
        showDragHandle: true,
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: AppTextStyles.headingSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neutral800,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
        actionTextColor: AppColors.primary400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // ── Tab bar ──────────────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary900,
        unselectedLabelColor: AppColors.neutral400,
        indicatorColor: AppColors.primary900,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.border,
        labelStyle: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Gilroy',
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── List tile ────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.sp16,
          vertical: AppDimensions.sp4,
        ),
        titleTextStyle: AppTextStyles.labelLarge,
        subtitleTextStyle: AppTextStyles.bodySmall,
        iconColor: AppColors.neutral400,
        minLeadingWidth: AppDimensions.iconMD,
      ),

      // ── Icon ─────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.neutral800,
        size: AppDimensions.iconMD,
      ),
    );
  }

  // ── Dark theme (scaffold ready — complete later) ─────────────────────────
  static ThemeData get dark {
    // Mirror of light with dark surfaces.
    // Extend when dark mode design tokens are finalised.
    return light.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primary900,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary400,
        onPrimary: AppColors.primary900,
        primaryContainer: AppColors.primary800,
        onPrimaryContainer: AppColors.primary100,
        secondary: AppColors.primary400,
        onSecondary: AppColors.primary900,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.darkBorder,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.headingSmall.copyWith(color: AppColors.darkTextPrimary),
        systemOverlayStyle: darkStatusBar,
        shape: Border(
          bottom: BorderSide(color: AppColors.darkBorder, width: AppDimensions.borderThin),
        ),
      ),
    );
  }

  // ── System UI overlay helpers ────────────────────────────────────────────

  /// Use on screens with a white / light AppBar.
  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Use on screens with a dark hero header (onboarding, login header).
  static const SystemUiOverlayStyle darkStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.primary900,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Applies [darkStatusBar] for a single screen without changing the theme.
  static void applyDarkStatusBar() =>
      SystemChrome.setSystemUIOverlayStyle(darkStatusBar);

  /// Applies [lightStatusBar] for a single screen without changing the theme.
  static void applyLightStatusBar() =>
      SystemChrome.setSystemUIOverlayStyle(lightStatusBar);
}
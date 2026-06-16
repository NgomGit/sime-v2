// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../tokens/app_colors.dart';
// import '../tokens/app_dimensions.dart';
// import '../tokens/app_text_styles.dart';

// /// SIME V2 — Application theme.
// ///
// /// Couleurs basées sur la charte graphique officielle ANPEJ :
// ///   • Vert   CMJN (50, 2, 100, 0)  → AppColors.primary400   #80C241
// ///   • Marron CMJN (43, 57, 92, 55) → AppColors.secondary600 #735618
// ///   • Jaune  CMJN (1, 35, 85, 0)   → AppColors.accent500    #FAA634
// ///   • Bleu   CMJN (76, 22, 0, 0)   → AppColors.bleuANPEJ    #2195D2
// ///   • Violet CMJN (42, 100, 5, 1)  → AppColors.violetANPEJ  #9C1D76
// ///
// /// Décisions design :
// ///   • Primary   = marron institutionnel (identité ANPEJ, AppBar, FAB, CTA principaux)
// ///   • Secondary = vert ANPEJ           (succès, chips actifs, progression)
// ///   • Tertiary  = jaune ANPEJ          (badges urgents, highlights, notifications)
// ///   • Le bleu et le violet servent les 4 services : Formation, Migration, etc.
// ///
// /// Usage:
// /// ```dart
// /// MaterialApp(
// ///   theme: AppTheme.light,
// ///   ...
// /// )
// /// ```
// abstract final class AppTheme {
//   AppTheme._();

//   // ── Light theme ─────────────────────────────────────────────────────────────

//   static ThemeData get light {
//     return ThemeData(
//       useMaterial3: true,
//       fontFamily: 'Gilroy',

//       // ── Color scheme ──────────────────────────────────────────────────────
//       colorScheme: const ColorScheme(
//         brightness: Brightness.light,

//         // Primary — marron institutionnel ANPEJ
//         // Utilisé pour : AppBar, boutons CTA principaux, FAB, états actifs
//         // Le marron est la couleur de l'institution → ancre toute l'UI
//         primary: AppColors.secondary800,
//         onPrimary: AppColors.white,
//         primaryContainer: AppColors.secondary100,
//         onPrimaryContainer: AppColors.secondary900,

//         // Secondary — vert ANPEJ (50, 2, 100, 0)
//         // Utilisé pour : succès, progression, chips actifs, badges positifs
//         secondary: AppColors.primary400,
//         onSecondary: AppColors.white,
//         secondaryContainer: AppColors.primary100,
//         onSecondaryContainer: AppColors.primary800,

//         // Tertiary — jaune ANPEJ (1, 35, 85, 0)
//         // Utilisé pour : badges urgence/délai, highlights, notifications
//         tertiary: AppColors.accent500,
//         onTertiary: AppColors.neutral800,
//         tertiaryContainer: AppColors.accent100,
//         onTertiaryContainer: AppColors.accent900,

//         // Error
//         error: AppColors.error,
//         onError: AppColors.white,
//         errorContainer: AppColors.errorBg,
//         onErrorContainer: AppColors.error,

//         // Surface / background — fond légèrement chaud (harmonie avec le marron)
//         surface: AppColors.surface,
//         onSurface: AppColors.neutral800,
//         surfaceContainerHighest: AppColors.neutral50,
//         onSurfaceVariant: AppColors.neutral500,

//         // Outline — border chaud
//         outline: AppColors.border,
//         outlineVariant: AppColors.neutral200,
//       ),

//       // ── Scaffold ─────────────────────────────────────────────────────────
//       scaffoldBackgroundColor: AppColors.background,

//       // ── AppBar ───────────────────────────────────────────────────────────
//       // Fond blanc pour les écrans intérieurs (post-connexion)
//       // Les écrans d'onboarding utilisent applyDarkStatusBar() manuellement
//       appBarTheme: const AppBarTheme(
//         backgroundColor: AppColors.surface,
//         foregroundColor: AppColors.neutral800,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         centerTitle: false,
//         surfaceTintColor: Colors.transparent,
//         titleTextStyle: AppTextStyles.headingSmall,
//         iconTheme: IconThemeData(
//           color: AppColors.neutral800,
//           size: AppDimensions.iconMD,
//         ),
//         actionsIconTheme: IconThemeData(
//           color: AppColors.neutral400,
//           size: AppDimensions.iconMD,
//         ),
//         systemOverlayStyle: lightStatusBar,
//         shape: Border(
//           bottom: BorderSide(
//               color: AppColors.border, width: AppDimensions.borderThin),
//         ),
//       ),

//       // ── Bottom navigation bar ────────────────────────────────────────────
//       // Couleur active = marron institutionnel (not vert) :
//       // la nav appartient à l'institution, pas aux états positifs
//       bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//         backgroundColor: AppColors.surface,
//         selectedItemColor: AppColors.secondary800,   // marron ANPEJ
//         unselectedItemColor: AppColors.neutral400,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         type: BottomNavigationBarType.fixed,
//         elevation: 0,
//         selectedLabelStyle: TextStyle(
//           fontFamily: 'Gilroy',
//           fontSize: 9,
//           fontWeight: FontWeight.w700,
//         ),
//         unselectedLabelStyle: TextStyle(
//           fontFamily: 'Gilroy',
//           fontSize: 9,
//           fontWeight: FontWeight.w400,
//         ),
//       ),

//       // ── Elevated button (CTA principal) ──────────────────────────────────
//       // Fond marron institutionnel : "Créer mon compte", "Se connecter",
//       // "Postuler maintenant", "Enregistrer les modifications"
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.secondary800,   // marron institutionnel
//           foregroundColor: AppColors.white,
//           disabledBackgroundColor: AppColors.neutral100,
//           disabledForegroundColor: AppColors.neutral300,
//           minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
//           ),
//           elevation: 0,
//           shadowColor: Colors.transparent,
//           textStyle: AppTextStyles.buttonLarge,
//           padding:
//               const EdgeInsets.symmetric(horizontal: AppDimensions.sp20),
//         ),
//       ),

//       // ── Outlined button (CTA secondaire) ─────────────────────────────────
//       // "Retour", "J'ai déjà un compte" : bordure marron, texte marron
//       outlinedButtonTheme: OutlinedButtonThemeData(
//         style: OutlinedButton.styleFrom(
//           foregroundColor: AppColors.secondary800,
//           disabledForegroundColor: AppColors.neutral300,
//           minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
//           side: const BorderSide(
//             color: AppColors.secondary400,
//             width: AppDimensions.borderMedium,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
//           ),
//           textStyle: AppTextStyles.buttonLarge
//               .copyWith(color: AppColors.secondary800),
//           padding:
//               const EdgeInsets.symmetric(horizontal: AppDimensions.sp20),
//         ),
//       ),

//       // ── Text button (liens inline) ───────────────────────────────────────
//       // "Inscrivez-vous", "Mot de passe oublié ?", "Voir tout"
//       // Vert ANPEJ = action positive, disponible → couleur des liens
//       textButtonTheme: TextButtonThemeData(
//         style: TextButton.styleFrom(
//           foregroundColor: AppColors.primary600,
//           textStyle: AppTextStyles.labelMedium
//               .copyWith(color: AppColors.primary600),
//           padding: const EdgeInsets.symmetric(
//             horizontal: AppDimensions.sp8,
//             vertical: AppDimensions.sp4,
//           ),
//         ),
//       ),

//       // ── Filled button (CTA inline : "Postuler" sur liste) ────────────────
//       // Vert ANPEJ sur les cartes offres : action d'emploi = vert (succès, avenir)
//       filledButtonTheme: FilledButtonThemeData(
//         style: FilledButton.styleFrom(
//           backgroundColor: AppColors.primary400,     // vert ANPEJ
//           foregroundColor: AppColors.white,
//           minimumSize: const Size(0, AppDimensions.buttonHeightSM),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
//           ),
//           textStyle: AppTextStyles.buttonSmall,
//           elevation: 0,
//         ),
//       ),

//       // ── Input decoration ─────────────────────────────────────────────────
//       // Focus ring = marron institutionnel (cohérence avec CTA primary)
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.neutral50,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: AppDimensions.sp16,
//           vertical: AppDimensions.sp14,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//           borderSide: const BorderSide(
//             color: AppColors.border,
//             width: AppDimensions.borderThin,
//           ),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//           borderSide: const BorderSide(
//             color: AppColors.border,
//             width: AppDimensions.borderThin,
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//           borderSide: const BorderSide(
//             color: AppColors.secondary800,            // marron au focus
//             width: AppDimensions.borderMedium,
//           ),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//           borderSide: const BorderSide(
//             color: AppColors.error,
//             width: AppDimensions.borderMedium,
//           ),
//         ),
//         focusedErrorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//           borderSide: const BorderSide(
//             color: AppColors.error,
//             width: AppDimensions.borderMedium,
//           ),
//         ),
//         disabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//           borderSide: const BorderSide(
//             color: AppColors.neutral100,
//             width: AppDimensions.borderThin,
//           ),
//         ),
//         hintStyle:
//             AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral300),
//         labelStyle:
//             AppTextStyles.labelSmall.copyWith(color: AppColors.neutral500),
//         floatingLabelStyle:
//             AppTextStyles.labelSmall.copyWith(color: AppColors.secondary800),
//         errorStyle:
//             AppTextStyles.caption.copyWith(color: AppColors.error),
//         prefixStyle: AppTextStyles.bodyMedium,
//         suffixStyle: AppTextStyles.bodyMedium,
//       ),

//       // ── Card ─────────────────────────────────────────────────────────────
//       cardTheme: CardThemeData(
//         color: AppColors.surface,
//         elevation: 0,
//         shadowColor: Colors.transparent,
//         surfaceTintColor: Colors.transparent,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
//           side: const BorderSide(
//               color: AppColors.border, width: AppDimensions.borderThin),
//         ),
//         margin: EdgeInsets.zero,
//       ),

//       // ── Chip ─────────────────────────────────────────────────────────────
//       // Chip sélectionné = marron institutionnel (filtre actif = état institutionnel)
//       // Chip non sélectionné = fond neutre chaud
//       chipTheme: ChipThemeData(
//         backgroundColor: AppColors.surface,
//         selectedColor: AppColors.secondary800,        // marron quand actif
//         disabledColor: AppColors.neutral50,
//         labelStyle: AppTextStyles.labelSmall,
//         secondaryLabelStyle:
//             AppTextStyles.labelSmall.copyWith(color: AppColors.white),
//         padding: const EdgeInsets.symmetric(
//           horizontal: AppDimensions.sp12,
//           vertical: AppDimensions.sp6,
//         ),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
//           side: const BorderSide(
//               color: AppColors.border, width: AppDimensions.borderThin),
//         ),
//         showCheckmark: false,
//         elevation: 0,
//         pressElevation: 0,
//       ),

//       // ── Divider ──────────────────────────────────────────────────────────
//       dividerTheme: const DividerThemeData(
//         color: AppColors.border,
//         thickness: AppDimensions.borderThin,
//         space: 0,
//       ),

//       // ── Progress indicator ───────────────────────────────────────────────
//       // Track = vert ANPEJ : la progression d'un dossier = avancement positif
//       progressIndicatorTheme: const ProgressIndicatorThemeData(
//         color: AppColors.primary400,                  // vert ANPEJ
//         linearTrackColor: AppColors.neutral100,
//         circularTrackColor: AppColors.neutral100,
//         linearMinHeight: 4,
//       ),

//       // ── Switch ───────────────────────────────────────────────────────────
//       // Actif = vert ANPEJ (état ON = positif, disponible)
//       switchTheme: SwitchThemeData(
//         thumbColor: WidgetStateProperty.resolveWith((states) {
//           if (states.contains(WidgetState.selected)) return AppColors.white;
//           return AppColors.neutral300;
//         }),
//         trackColor: WidgetStateProperty.resolveWith((states) {
//           if (states.contains(WidgetState.selected))
//             return AppColors.primary400; // vert quand ON
//           return AppColors.neutral100;
//         }),
//         trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
//       ),

//       // ── Checkbox ─────────────────────────────────────────────────────────
//       // Fond coché = marron institutionnel (choix affirmé = engagement)
//       // Icône check = vert ANPEJ (validation positive)
//       checkboxTheme: CheckboxThemeData(
//         fillColor: WidgetStateProperty.resolveWith((states) {
//           if (states.contains(WidgetState.selected))
//             return AppColors.secondary800; // marron coché
//           return Colors.transparent;
//         }),
//         checkColor: WidgetStateProperty.all(AppColors.white),
//         side: const BorderSide(
//             color: AppColors.neutral200, width: AppDimensions.borderMedium),
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(AppDimensions.radiusXS)),
//       ),

//       // ── Radio ────────────────────────────────────────────────────────────
//       // Sélectionné = marron institutionnel (cohérence avec checkbox)
//       radioTheme: RadioThemeData(
//         fillColor: WidgetStateProperty.resolveWith((states) {
//           if (states.contains(WidgetState.selected))
//             return AppColors.secondary800;
//           return AppColors.neutral200;
//         }),
//       ),

//       // ── FloatingActionButton ─────────────────────────────────────────────
//       // Fond marron (action principale = identité institutionnelle)
//       // Icône vert ANPEJ (action = avenir, création)
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: AppColors.secondary800,      // marron
//         foregroundColor: AppColors.primary400,        // vert ANPEJ
//         elevation: 0,
//         focusElevation: 0,
//         hoverElevation: 0,
//         highlightElevation: 0,
//         shape: CircleBorder(),
//       ),

//       // ── BottomSheet ──────────────────────────────────────────────────────
//       bottomSheetTheme: const BottomSheetThemeData(
//         backgroundColor: AppColors.surface,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(AppDimensions.radiusXXL),
//           ),
//         ),
//         dragHandleColor: AppColors.neutral200,
//         dragHandleSize: Size(36, 4),
//         showDragHandle: true,
//       ),

//       // ── Dialog ───────────────────────────────────────────────────────────
//       dialogTheme: DialogThemeData(
//         backgroundColor: AppColors.surface,
//         surfaceTintColor: Colors.transparent,
//         elevation: 0,
//         titleTextStyle: AppTextStyles.headingSmall,
//         contentTextStyle: AppTextStyles.bodyMedium,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
//         ),
//       ),

//       // ── SnackBar ─────────────────────────────────────────────────────────
//       // Fond marron sombre (plus institutionnel que le gris neutre précédent)
//       // Texte action = vert ANPEJ (CTA dans le snackbar)
//       snackBarTheme: SnackBarThemeData(
//         backgroundColor: AppColors.secondary900,      // marron sombre
//         contentTextStyle:
//             AppTextStyles.bodySmall.copyWith(color: AppColors.white),
//         actionTextColor: AppColors.primary400,        // vert ANPEJ
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
//         ),
//         behavior: SnackBarBehavior.floating,
//         elevation: 0,
//       ),

//       // ── Tab bar ──────────────────────────────────────────────────────────
//       // Indicateur = marron institutionnel (onglet actif = position institutionnelle)
//       tabBarTheme: const TabBarThemeData(
//         labelColor: AppColors.secondary800,            // marron actif
//         unselectedLabelColor: AppColors.neutral400,
//         indicatorColor: AppColors.secondary800,
//         indicatorSize: TabBarIndicatorSize.label,
//         dividerColor: AppColors.border,
//         labelStyle: TextStyle(
//           fontFamily: 'Gilroy',
//           fontSize: 13,
//           fontWeight: FontWeight.w600,
//         ),
//         unselectedLabelStyle: TextStyle(
//           fontFamily: 'Gilroy',
//           fontSize: 13,
//           fontWeight: FontWeight.w400,
//         ),
//       ),

//       // ── List tile ────────────────────────────────────────────────────────
//       listTileTheme: const ListTileThemeData(
//         tileColor: Colors.transparent,
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: AppDimensions.sp16,
//           vertical: AppDimensions.sp4,
//         ),
//         titleTextStyle: AppTextStyles.labelLarge,
//         subtitleTextStyle: AppTextStyles.bodySmall,
//         iconColor: AppColors.neutral400,
//         minLeadingWidth: AppDimensions.iconMD,
//       ),

//       // ── Icon ─────────────────────────────────────────────────────────────
//       iconTheme: const IconThemeData(
//         color: AppColors.neutral800,
//         size: AppDimensions.iconMD,
//       ),
//     );
//   }

//   // ── Dark theme ───────────────────────────────────────────────────────────
//   // Base "Forêt profonde" : fond très sombre vert-marron, accents lumineux
//   static ThemeData get dark {
//     return light.copyWith(
//       brightness: Brightness.dark,
//       scaffoldBackgroundColor: AppColors.darkSurface,
//       colorScheme: const ColorScheme.dark(
//         // Primary dark = vert ANPEJ lumineux (marron est trop sombre sur fond sombre)
//         primary: AppColors.primary400,
//         onPrimary: AppColors.neutral800,
//         primaryContainer: AppColors.primary800,
//         onPrimaryContainer: AppColors.primary100,
//         // Secondary dark = jaune comme accent chaud
//         secondary: AppColors.accent500,
//         onSecondary: AppColors.neutral800,
//         tertiary: AppColors.bleuANPEJ,
//         onTertiary: AppColors.white,
//         surface: AppColors.darkSurface,
//         onSurface: AppColors.darkTextPrimary,
//         error: AppColors.error,
//         onError: AppColors.white,
//         outline: AppColors.darkBorder,
//       ),
//       appBarTheme: AppBarTheme(
//         backgroundColor: AppColors.darkSurface,
//         foregroundColor: AppColors.darkTextPrimary,
//         elevation: 0,
//         scrolledUnderElevation: 0,
//         centerTitle: false,
//         surfaceTintColor: Colors.transparent,
//         titleTextStyle: AppTextStyles.headingSmall
//             .copyWith(color: AppColors.darkTextPrimary),
//         systemOverlayStyle: darkStatusBar,
//         shape: const Border(
//           bottom: BorderSide(
//               color: AppColors.darkBorder, width: AppDimensions.borderThin),
//         ),
//       ),
//     );
//   }

//   // ── System UI overlay helpers ────────────────────────────────────────────

//   /// Écrans intérieurs (AppBar blanche).
//   static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.dark,
//     systemNavigationBarColor: AppColors.surface,
//     systemNavigationBarIconBrightness: Brightness.dark,
//   );

//   /// Écrans d'onboarding (fond marron/sombre de la charte).
//   static const SystemUiOverlayStyle darkStatusBar = SystemUiOverlayStyle(
//     statusBarColor: Colors.transparent,
//     statusBarIconBrightness: Brightness.light,
//     systemNavigationBarColor: AppColors.secondary900,  // marron sombre charte
//     systemNavigationBarIconBrightness: Brightness.light,
//   );

//   static void applyDarkStatusBar() =>
//       SystemChrome.setSystemUIOverlayStyle(darkStatusBar);

//   static void applyLightStatusBar() =>
//       SystemChrome.setSystemUIOverlayStyle(lightStatusBar);
// }
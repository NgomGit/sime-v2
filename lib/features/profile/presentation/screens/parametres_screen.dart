// features/profile/presentation/screens/parametres_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';

/// Écran « Paramètres » — regroupe les réglages transverses de l'application :
/// notifications, sécurité et langue. Extrait du menu profil pour alléger la
/// page « Mon profil » et centraliser la configuration au même endroit.
class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // (icône, label, sous-titre, fond icône, couleur icône, action)
    final List<(IconData, String, String, Color, Color, VoidCallback)> settings = [
      (
        Icons.notifications_none_outlined,
        'Notifications',
        'Alertes offres & rendez-vous',
        AppColors.bleuANPEJBg,
        AppColors.bleuANPEJ,
        () {},
      ),
      (
        Icons.lock_outline_rounded,
        'Sécurité',
        'Mot de passe · Biométrie',
        AppColors.accent100,
        AppColors.accent800,
        () {},
      ),
      (
        Icons.language_rounded,
        'Langue',
        'Français',
        AppColors.secondary100,
        AppColors.secondary600,
        () {},
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral800),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Paramètres',
          style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: List.generate(settings.length, (index) {
                  final item = settings[index];
                  final isLast = index == settings.length - 1;
                  return Container(
                    decoration: BoxDecoration(
                      border: isLast
                          ? null
                          : const Border(
                              bottom: BorderSide(color: AppColors.border),
                            ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sp14,
                        vertical: AppDimensions.sp4,
                      ),
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: item.$4,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                        ),
                        alignment: Alignment.center,
                        child: Icon(item.$1, color: item.$5, size: 16),
                      ),
                      title: Text(
                        item.$2,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.neutral800,
                        ),
                      ),
                      subtitle: Text(
                        item.$3,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.neutral400,
                          fontSize: 10,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppColors.neutral300,
                        size: 16,
                      ),
                      onTap: item.$6,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

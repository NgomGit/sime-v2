import 'package:flutter/material.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key});
 
  @override
  Widget build(BuildContext context) {
    // (icône, label, sous-titre, fond icône, couleur icône)
    // Tous les tokens viennent de AppColors — zéro hex hardcodé
    final menuItems = [
      (
        Icons.description_outlined,
        'Mon CV',
        'Mis à jour le 10 mai 2026',
        AppColors.primary100,   // vert doux
        AppColors.primary800,   // vert sombre
      ),
      (
        Icons.notifications_none_outlined,
        'Notifications',
        'Alertes offres & rendez-vous',
        AppColors.bleuANPEJBg,  // bleu doux ANPEJ
        AppColors.bleuANPEJ,    // bleu ANPEJ
      ),
      (
        Icons.lock_outline_rounded,
        'Sécurité',
        'Mot de passe · Biométrie',
        AppColors.accent100,    // jaune doux ANPEJ
        AppColors.accent800,    // jaune sombre ANPEJ
      ),
      (
        Icons.language_rounded,
        'Langue',
        'Français',
        AppColors.secondary100, // marron doux institutionnel
        AppColors.secondary600, // marron institutionnel
      ),
    ];
 
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final isLast = index == menuItems.length - 1;
 
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
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: item.$4,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSM),
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
                color: AppColors.neutral300, // un cran plus visible que neutral200
                size: 16,
              ),
              onTap: () {},
            ),
          );
        }),
      ),
    );
  }
}
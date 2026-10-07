import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    // (icône, label, sous-titre, fond icône, couleur icône, action)
    // Tous les tokens viennent de AppColors — zéro hex hardcodé
    final List<(IconData, String, String, Color, Color, VoidCallback)> menuItems = [
      (
        Icons.description_outlined,
        'Mon CV',
        'Mis à jour le 10 mai 2026',
        AppColors.primary100,   // vert doux
        AppColors.primary800,   // vert sombre
        () {},
      ),
      (
        Icons.badge_outlined,
        "Pièce d'identité",
        'CNI ou Passeport · Recto/Verso',
        AppColors.secondary100, // marron doux institutionnel
        AppColors.secondary600, // marron institutionnel
        () => context.push(AppRoutes.editIdentityDocument),
      ),
      (
        Icons.forum_outlined,
        'Réclamation',
        'Échangez avec un conseiller ANPEJ',
        AppColors.secondary100, // marron doux institutionnel
        AppColors.secondary600, // marron institutionnel
        () => context.push(AppRoutes.reclamations),
      ),
      (
        Icons.settings_outlined,
        'Paramètres',
        'Notifications · Sécurité · Langue',
        AppColors.bleuANPEJBg,  // bleu doux ANPEJ
        AppColors.bleuANPEJ,    // bleu ANPEJ
        () => context.push(AppRoutes.parametres),
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
              onTap: item.$6,
            ),
          );
        }),
      ),
    );
  }
}
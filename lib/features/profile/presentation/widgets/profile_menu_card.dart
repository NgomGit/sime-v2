import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      (Icons.description_outlined, 'Mon CV', 'Mis à jour le 10 mai 2026', const Color(0xFFEAF6EE), const Color(0xFF1B5E20)),
      (Icons.notifications_none_outlined, 'Notifications', 'Alertes offres & rendez-vous', const Color(0xFFE3F2FD), const Color(0xFF0C447C)),
      (Icons.lock_outline_rounded, 'Sécurité', 'Mot de passe · Biométrie', const Color(0xFFFFF8E1), const Color(0xFF795B00)),
      (Icons.language_rounded, 'Langue', 'Français', const Color(0xFFF5F4F0), const Color(0xFF5F5E5A)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          final isLast = index == menuItems.length - 1;

          return Container(
            decoration: BoxDecoration(
              border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
              leading: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: item.$4, // Background couleur icône
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.$1, color: item.$5, size: 15),
              ),
              title: Text(item.$2, style: AppTextStyles.labelMedium),
              subtitle: Text(
                item.$3, 
                style: AppTextStyles.caption.copyWith(color: AppColors.neutral400, fontSize: 9),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.neutral200, size: 16),
              onTap: () {
                // Action de navigation vers les sous-modules
              },
            ),
          );
        }),
      ),
    );
  }
}
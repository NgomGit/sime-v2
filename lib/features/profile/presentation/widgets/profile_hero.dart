import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../domain/entities/applicant_entity.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key, required this.applicant});
 
  final ApplicantEntity applicant;
 
  // Couleur sémantique par tag — conforme à la charte ANPEJ
  // Emploi salarié → vert, Formation → bleu, Migration → violet,
  // Numérique → marron secondaire, Bac+3 → neutre chaud
  Color _tagColor(String tag) {
    if (tag.toLowerCase().contains('emploi')) return AppColors.primary400;
    if (tag.toLowerCase().contains('formation')) return AppColors.bleuANPEJ;
    if (tag.toLowerCase().contains('migration') ||
        tag.toLowerCase().contains('mobilit')) {
      return AppColors.violetANPEJ;
    }
    if (tag.toLowerCase().contains('financement') ||
        tag.toLowerCase().contains('auto')) {
      return AppColors.accent500;
    }
    return AppColors.darkTextSecondary; // tag neutre (Bac+3, Numérique, etc.)
  }
 
  Color _tagBg(String tag) => _tagColor(tag).withAlpha(30);
  Color _tagBorder(String tag) => _tagColor(tag).withAlpha(70);
 
  @override
  Widget build(BuildContext context) {
    return Container(
      // Fond vert forêt sombre — identique à tous les headers héro de l'app
      color: AppColors.darkSurface,
      padding: const EdgeInsets.only(
        left: AppDimensions.sp20,
        right: AppDimensions.sp20,
        top: AppDimensions.sp24,
        bottom: AppDimensions.sp28,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar : fond marron institutionnel + bordure verte
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.secondary800,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface.withAlpha(120),
                      width: 2.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    applicant.fullName.substring(0, 2).toUpperCase() ,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Spacer(),
                // Bouton éditer — fond translucide blanc sur fond sombre
                // Pattern identique au bouton retour de l'onboarding
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.darkBorder,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sp14),
 
            // Nom complet — blanc pur, typographie forte
            Text(
              applicant.fullName,
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.darkTextPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: AppDimensions.sp6),
 
            // Téléphone · Localisation — blanc 60%
            Text(
              '${applicant.user?.phone} · ${applicant.address}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.darkTextSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.sp14),
 
            // Tags sémantiques — couleurs ANPEJ par service
            // Wrap(
            //   spacing: AppDimensions.sp6,
            //   runSpacing: AppDimensions.sp6,
            //   children: applicant.tags.map((tag) {
            //     return Container(
            //       padding: const EdgeInsets.symmetric(
            //         horizontal: AppDimensions.sp10,
            //         vertical: AppDimensions.sp4,
            //       ),
            //       decoration: BoxDecoration(
            //         color: _tagBg(tag),
            //         borderRadius:
            //             BorderRadius.circular(AppDimensions.radiusFull),
            //         border: Border.all(color: _tagBorder(tag)),
            //       ),
            //       child: Text(
            //         tag,
            //         style: AppTextStyles.caption.copyWith(
            //           color: _tagColor(tag),
            //           fontSize: 10,
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     );
            //   }).toList(),
            // ),
          ],
        ),
      ),
    );
  }
}
 
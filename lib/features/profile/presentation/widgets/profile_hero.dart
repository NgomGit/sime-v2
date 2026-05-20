import 'package:flutter/material.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../domain/entities/user_profile_entity.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key, required this.profile});
  final UserProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary900, // Correspond à #0D1F14
      padding: const EdgeInsets.only(
        left: AppDimensions.sp8,
        right: AppDimensions.sp18,
        top: AppDimensions.sp24,
        bottom: AppDimensions.sp28,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avatar Rond
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary900, // Vert foncé de l'avatar
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary400.withAlpha(100),
                      width: 2.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    profile.initials,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: AppColors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                // Bouton Éditer Édition 
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sp12),
            Text(
              profile.fullName,
              style: AppTextStyles.headingMedium.copyWith(
                color: AppColors.white,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: AppDimensions.sp10),
            Text(
              '${profile.phone} · ${profile.location}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withAlpha(100),
              ),
            ),
            const SizedBox(height: AppDimensions.sp10),
            // Tags horizontally scrollable or wrapped
            Wrap(
              spacing: AppDimensions.sp6,
              runSpacing: AppDimensions.sp6,
              children: profile.tags.map((tag) {
                final isSpecial = tag == 'Emploi salarié';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSpecial 
                        ? AppColors.primary400.withAlpha(30)
                        : Colors.white.withAlpha(18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isSpecial 
                          ? AppColors.primary400.withAlpha(60)
                          : Colors.white.withAlpha(25),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppTextStyles.caption.copyWith(
                      color: isSpecial ? AppColors.primary400 : Colors.white70,
                      fontSize: 9,
                      fontWeight: isSpecial ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
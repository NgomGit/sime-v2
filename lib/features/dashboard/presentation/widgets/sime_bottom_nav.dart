import 'package:flutter/material.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';

class SimeBottomNav extends StatelessWidget {
  const SimeBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;

  static const _items = [
    (
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Accueil',
      route: '/home'
    ),
    (
      icon: Icons.business_center_outlined,
      activeIcon: Icons.business_center_rounded,
      label: 'Offres',
      route: '/offers'
    ),
    (
      icon: Icons.event_note_outlined,
      activeIcon: Icons.event_note_rounded,
      label: 'Agenda',
      route: '/agenda'
    ),
    (
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'Candidatures',
      route: '/applications'
    ),
    (
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
      route: '/profile'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      // Suppression de height fixe pour éviter de forcer 37px
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          // On donne de l'espace vertical respirable et maîtrisé
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.sp8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isSelected = i == currentIndex;
              final color =
                  isSelected ? AppColors.primary900 : AppColors.neutral400;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap?.call(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // La colonne prend juste la place de ses enfants
                    children: [
                      // Barre indicatrice supérieure
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isSelected ? 20 : 0,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.primary900,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.sp4),
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size:
                            24, // Taille explicite standardisée pour le Mobile
                        color: color,
                      ),
                      const SizedBox(height: AppDimensions.sp4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: color,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w400,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

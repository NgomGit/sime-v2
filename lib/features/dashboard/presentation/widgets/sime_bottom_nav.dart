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
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Accueil'),
    (icon: Icons.business_center_outlined, activeIcon: Icons.business_center_rounded, label: 'Offres'),
    (icon: Icons.event_note_outlined, activeIcon: Icons.event_note_rounded, label: 'Agenda'),
    (icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'Candidatures'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral800.withAlpha(8),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.border,
            width: AppDimensions.borderThin,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.sp10),
          // LayoutBuilder indispensable pour calculer précisément la largeur disponible d'une cellule
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final itemWidth = totalWidth / _items.length;
              
              // Dimensions de la pilule premium
              const pillWidth = 56.0;
              const pillHeight = 32.0;

              // Calcul de la position X exacte pour centrer la pilule sur l'onglet actif
              final pillLeftPosition = (itemWidth * currentIndex) + (itemWidth - pillWidth) / 2;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // ─── L'INDICATEUR UNIQUE QUI GLISSE (The True Smooth Slider) ───
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 350),
                    // Courbe ultra-smooth qui démarre vite et amortit longuement sur la fin
                    curve: Curves.fastLinearToSlowEaseIn,
                    left: pillLeftPosition,
                    top: 0, // Aligné sur la zone des icônes
                    child: Container(
                      width: pillWidth,
                      height: pillHeight,
                      decoration: BoxDecoration(
                        color: AppColors.primary100, // Vert doux institutionnel ANPEJ
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                      ),
                    ),
                  ),

                  // ─── LES ONGLETS ET TEXTES INTERACTIFS ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(_items.length, (i) {
                      final item = _items[i];
                      final isSelected = i == currentIndex;

                      const activeColor = AppColors.secondary800; // Marron institutionnel
                      const inactiveColor = AppColors.neutral400;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTap?.call(i),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Zone fixe pour l'icône (hauteur alignée avec la pilule arrière)
                              SizedBox(
                                height: pillHeight,
                                child: Center(
                                  child: Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    size: 24,
                                    color: isSelected ? activeColor : inactiveColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.sp6),
                              
                              // Texte d'accompagnement stable
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.labelXSmall.copyWith(
                                  color: isSelected ? activeColor : inactiveColor,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
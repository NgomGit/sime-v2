import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_dimensions.dart';
import '../tokens/app_text_styles.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});
  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.offres)) return 1;
    if (location.startsWith(AppRoutes.rendezvous)) return 2;
    if (location.startsWith(AppRoutes.dossier)) return 3;
    if (location.startsWith(AppRoutes.profil)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(AppRoutes.dashboard);
      case 1: context.go(AppRoutes.offres);
      case 2: context.go(AppRoutes.rendezvous);
      case 3: context.go(AppRoutes.dossier);
      case 4: context.go(AppRoutes.profil);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: _SimeBottomNav(
        currentIndex: current,
        onTap: (i) => _onTap(context, i),
      ),
    );
  }
}

class _SimeBottomNav extends StatelessWidget {
  const _SimeBottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final void Function(int) onTap;

  static const _items = [
    (icon: Icons.home_outlined,       activeIcon: Icons.home_rounded,          label: 'Accueil'),
    (icon: Icons.work_outline,         activeIcon: Icons.work_rounded,          label: 'Offres'),
    (icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month,    label: 'Agenda'),
    (icon: Icons.folder_outlined,      activeIcon: Icons.folder_rounded,        label: 'Dossier'),
    (icon: Icons.person_outline,       activeIcon: Icons.person_rounded,        label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: AppDimensions.cardIconSize,
                        color: isActive ? AppColors.primary900 : AppColors.neutral400,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppTextStyles.caption.copyWith(
                          color: isActive ? AppColors.primary900 : AppColors.neutral400,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 3),
                        Container(
                          width: 16,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.primary900,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
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

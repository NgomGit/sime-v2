import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:sime_v2/features/profile/presentation/widgets/info_section_card.dart';
import 'package:sime_v2/features/profile/presentation/widgets/profile_hero.dart';
import 'package:sime_v2/features/profile/presentation/widgets/profile_menu_card.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_card.dart';


class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur de chargement: $err')),
        data: (profile) {
          return CustomScrollView(
            slivers: [
              // Zone Haute Verte du Profil (Hero)
              SliverToBoxAdapter(
                child: ProfileHero(profile: profile),
              ),
              
              // Contenu défilant
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.pagePaddingH,
                  right: AppDimensions.pagePaddingH,
                  top: AppDimensions.sp14,
                  bottom: AppDimensions.sp32,
                ),
                sliver: SliverList.list(
                  children: [
                    // Informations Personnelles
                    InfoSectionCard(
                      title: 'Informations personnelles',
                      onEditTap: () {},
                      rows: [
                        ('Nom complet', profile.fullName),
                        ('Date de naissance', '${profile.birthDate} · 26 ans'),
                        ('CIN', profile.cin),
                        ('Nationalité', profile.nationality),
                        ('Adresse', profile.location),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sp10),

                    // Profil Professionnel
                    InfoSectionCard(
                      title: 'Profil professionnel',
                      onEditTap: () {},
                      rows: [
                        ('Niveau d\'étude', profile.studyLevel),
                        ('Domaine', profile.domain),
                        ('Expérience', profile.experience),
                        ('Dernier diplôme', profile.lastDegree),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sp10),

                    // Menu d'options
                    const ProfileMenuCard(),
                    const SizedBox(height: AppDimensions.sp14),

                    // Bouton de Déconnexion
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.onboarding),
                      child: SCard(
                        padding: const EdgeInsets.all(AppDimensions.sp14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: AppColors.error, size: 16),
                            const SizedBox(width: AppDimensions.sp8),
                            Text(
                              'Se déconnecter',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
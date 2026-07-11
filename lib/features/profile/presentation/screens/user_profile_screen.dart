// features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/features/auth/presentation/providers/login_provider.dart';
import 'package:sime_v2/features/profile/presentation/providers/applicant_notifier.dart';
import 'package:sime_v2/features/profile/presentation/widgets/info_section_card.dart';
import 'package:sime_v2/features/profile/presentation/widgets/profile_hero.dart';
import 'package:sime_v2/features/profile/presentation/widgets/profile_menu_card.dart';
import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Déclenche le chargement initial dès que le premier frame de l'UI est dessiné
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(applicantNotifierProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(applicantNotifierProvider);
    final applicant = profileState.applicant;

    // 1. Écran d'erreur bloquant : Pas de cache + Échec de chargement/parsing
    if (profileState.errorMessage != null &&
        applicant == null &&
        !profileState.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.error,
                  size: 48,
                ),
                const SizedBox(height: AppDimensions.sp14),
                Text(
                  'Connexion impossible',
                  style: AppTextStyles.headingSmall
                      .copyWith(color: AppColors.neutral800),
                ),
                const SizedBox(height: 8),
                Text(
                  profileState.errorMessage ??
                      'Une erreur de chargement est survenue.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.neutral500),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref
                      .read(applicantNotifierProvider.notifier)
                      .loadProfile(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 2. Écran de chargement initial plein écran
    if (profileState.isLoading && applicant == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.secondary800),
        ),
      );
    }

    // Sécurité au cas où l'état initial sans chargement n'a pas encore d'applicant
    if (applicant == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.secondary800,
        onRefresh: () =>
            ref.read(applicantNotifierProvider.notifier).loadProfile(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── PROFILE HERO REPLACÉ EN HAUT ──
            SliverToBoxAdapter(
              child: ProfileHero(
                applicant: applicant,
              ),
            ),

            // Bandeau d'avertissement non bloquant si erreur réseau mais cache présent
            if (profileState.errorMessage != null)
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.error.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: AppDimensions.pagePaddingH,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.signal_wifi_connected_no_internet_4_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mode hors-ligne : Impossible d\'actualiser les données.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            SliverPadding(
              padding: const EdgeInsets.only(
                left: AppDimensions.pagePaddingH,
                right: AppDimensions.pagePaddingH,
                top: AppDimensions.sp14,
                bottom: AppDimensions.sp32,
              ),
              sliver: SliverList.list(
                children: [
                  InfoSectionCard(
                    title: 'Informations personnelles',
                    onEditTap: () =>
                        context.push(AppRoutes.editPersonalProfile),
                    rows: [
                      ('Nom complet', applicant.fullName),
                      (
                        'Date de naissance',
                        '${applicant.dateBirth.isNotEmpty ? applicant.dateBirth : '—'} · ${applicant.age} ans'
                      ),
                      ('CIN / Passeport', applicant.cni),
                      ('Nationalité', applicant.nationality?.name ?? 'Sénégalaise'),
                      (
                        'Adresse',
                        applicant.address.isNotEmpty
                            ? applicant.address
                            : 'Non renseignée'
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sp10),
                  InfoSectionCard(
                    title: 'Profil professionnel',
                    onEditTap: () =>
                        context.push(AppRoutes.editProfessionalProfile),
                    rows: [
                      (
                        "Niveau d'étude",
                        applicant.educationLevel?.name ?? 'Non renseigné'
                      ),
                      (
                        'Domaine d\'études',
                        applicant.fieldStudy?.name ?? 'Non renseigné'
                      ),
                      (
                        'Dernier diplôme',
                        applicant.lastDegreeObtained?.name ?? 'Non renseigné'
                      ),
                      (
                        'Conseiller ANPEJ',
                        applicant.hasAdvisor ? 'Assigné' : 'Non assigné'
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sp10),
                  const ProfileMenuCard(),
                  const SizedBox(height: AppDimensions.sp14),
                  GestureDetector(
                    onTap: () => _onLogoutTap(context, ref),
                    child: SCard(
                      padding: const EdgeInsets.all(AppDimensions.sp14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: AppDimensions.iconSM,
                          ),
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
        ),
      ),
    );
  }

  void _onLogoutTap(BuildContext context, WidgetRef ref) {
    ref.read(loginNotifierProvider.notifier).logout();
  }
}

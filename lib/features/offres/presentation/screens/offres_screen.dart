import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/design_system/widgets/empty_state.dart';
import 'package:sime_v2/features/offres/presentation/widgets/offre_card.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';

import '../../domain/entities/offre_entity.dart';
import '../providers/offres_provider.dart';

class OffresScreen extends ConsumerStatefulWidget {
  const OffresScreen({super.key});

  @override
  ConsumerState<OffresScreen> createState() => _OffresScreenState();
}

class _OffresScreenState extends ConsumerState<OffresScreen> {
  OffreType? _selectedType;

  static const _filters = [
    (label: 'Tous',      type: null),
    (label: 'Emploi',    type: OffreType.emploi),
    (label: 'Stage',     type: OffreType.stage),
    (label: 'Formation', type: OffreType.formation),
    (label: 'Migration', type: OffreType.migration),
  ];

  @override
  Widget build(BuildContext context) {
    final offresValue = ref.watch(offresListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header sombre (même héro que onboarding / connexion) ─────────
            _SearchHeader(
              onFilterChanged: (type) {
                setState(() => _selectedType = type);
                ref.read(offresFilterProvider.notifier).update(
                      (s) => OffresFilter(type: type, query: s.query),
                    );
              },
            ),

            // ── Filter chips (dans la continuité du header sombre) ───────────
            _FilterChips(
              selectedType: _selectedType,
              filters: _filters,
              onSelected: (type) {
                setState(() => _selectedType = type);
                ref.read(offresFilterProvider.notifier).update(
                      (s) => OffresFilter(type: type, query: s.query),
                    );
              },
            ),

            // ── Liste des offres ─────────────────────────────────────────────
            Expanded(
              child: offresValue.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.secondary800,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Erreur: $e',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                ),
                data: (offres) => offres.isEmpty
                    ? const EmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
                        itemCount: offres.length,
                        itemBuilder: (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: AppDimensions.sp10),
                          child: OffreCard(offre: offres[i]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Search header
// ─────────────────────────────────────────────────────────────────────────────
// Fond darkSurface (#0F170A) — cohérence avec l'onboarding et la connexion.
// primary900 (vert très sombre) remplacé : le header n'est pas un état positif,
// c'est un espace institutionnel de recherche → fond forêt sombre.
//
// Bouton filtre (tune) : fond secondary100 + icône secondary800 (marron).
// Sur fond sombre, le marron doux ressort mieux que le vert vif et
// communique "action institutionnelle" plutôt que "action positive".
class _SearchHeader extends StatelessWidget {
  const _SearchHeader({this.onFilterChanged});

  final ValueChanged<OffreType?>? onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurface, // vert forêt sombre — cohérence UI
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20, AppDimensions.sp16,
        AppDimensions.sp20, AppDimensions.sp20,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Offres d'emploi",
                style: AppTextStyles.headingMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
              ),
              // Compteur — jaune ANPEJ : chiffre à mettre en valeur (urgence positive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sp8,
                  vertical: AppDimensions.sp4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent500.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: AppColors.accent500.withAlpha(60)),
                ),
                child: Text(
                  '3 218 disponibles',
                  style: AppTextStyles.labelXSmall.copyWith(
                    color: AppColors.accent500, // jaune ANPEJ
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp14),
          Row(
            children: [
              // Champ de recherche — fond semi-transparent sur fond sombre
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: Colors.white.withAlpha(25)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sp14,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.white.withAlpha(100),
                        size: AppDimensions.iconMD,
                      ),
                      const SizedBox(width: AppDimensions.sp8),
                      Text(
                        'Poste, entreprise...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.darkTextHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sp10),

              // Bouton filtre — marron institutionnel sur fond sombre
              // secondary100 (fond beige doux) visible sur darkSurface
              Container(
                height: 46, width: 46,
                decoration: BoxDecoration(
                  color: AppColors.secondary800.withAlpha(50),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: AppColors.secondary400.withAlpha(80),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.tune,
                  color: AppColors.secondary100, // clair sur fond marron sombre
                  size: AppDimensions.iconMD,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter chips
// ─────────────────────────────────────────────────────────────────────────────
// Toujours sur fond sombre (continuité visuelle avec le header).
//
// Chip actif : fond vert ANPEJ primary400 + texte blanc.
//   → Le filtre actif = contenu positif sélectionné = vert sémantique correct.
//   (Contrairement aux boutons CTA institutionnels qui sont marron)
//
// Chip inactif : fond translucide blanc + texte darkTextSecondary.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedType,
    required this.filters,
    required this.onSelected,
  });

  final OffreType? selectedType;
  final List<({String label, OffreType? type})> filters;
  final ValueChanged<OffreType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Même fond que le header — les chips font partie du bloc de recherche
      color: AppColors.darkSurface,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20, 0,
        AppDimensions.sp20, AppDimensions.sp16,
      ),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, __) =>
              const SizedBox(width: AppDimensions.sp6),
          itemBuilder: (ctx, i) {
            final f = filters[i];
            final isSelected = selectedType == f.type;

            return GestureDetector(
              onTap: () => onSelected(f.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sp14,
                  vertical: AppDimensions.sp6,
                ),
                decoration: BoxDecoration(
                  // Actif : vert ANPEJ (filtre contenu = sémantique positive)
                  // Inactif : translucide blanc sur fond forêt
                  color: isSelected
                      ? AppColors.primary400
                      : Colors.white.withAlpha(15),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary400
                        : Colors.white.withAlpha(30),
                    width: isSelected
                        ? AppDimensions.borderMedium
                        : AppDimensions.borderThin,
                  ),
                ),
                child: Text(
                  f.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected
                        ? AppColors.white
                        : AppColors.darkTextSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
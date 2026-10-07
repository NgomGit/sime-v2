// features/besoin/presentation/screens/nouveau_besoin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/app_status_dialog.dart';
import 'package:sime_v2/core/design_system/widgets/s_app_back_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_app_bar.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_overlay_loader.dart';
import 'package:sime_v2/core/design_system/widgets/s_searchable_dropdown.dart';
import 'package:sime_v2/core/design_system/widgets/s_shimer.dart';

import '../../domain/entities/besoin_entities.dart';
import '../../domain/entities/my_subscription_entity.dart';
import '../providers/besoin_notifier.dart';
import '../providers/my_subscriptions_notifier.dart';

/// Écran « Nouveau besoin » — le candidat choisit, en cascade, la catégorie de
/// service (besoin sollicité), puis la structure partenaire, puis la
/// sous-catégorie (offre de service), avant d'enregistrer sa souscription.
///
/// Parti pris mobile : plutôt que trois menus déroulants inertes empilés (front
/// web), un enchaînement à révélation progressive — chaque étape s'active
/// visuellement dès que la précédente est renseignée, avec un récapitulatif
/// animé en bas de page. La sélection elle-même réutilise le composant maison
/// [SSearchableDropdown] (feuille modale avec recherche), idéal quand une
/// catégorie propose de nombreuses offres.
class NouveauBesoinScreen extends ConsumerStatefulWidget {
  const NouveauBesoinScreen({super.key, this.initial});

  /// Besoin existant à modifier ; `null` pour exprimer un nouveau besoin.
  final MySubscriptionEntity? initial;

  @override
  ConsumerState<NouveauBesoinScreen> createState() =>
      _NouveauBesoinScreenState();
}

class _NouveauBesoinScreenState extends ConsumerState<NouveauBesoinScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(besoinNotifierProvider.notifier);
      final initial = widget.initial;
      if (initial != null) {
        notifier.startEditing(initial);
      } else {
        notifier.loadTypeServices();
      }
    });
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();
    final isEditing = widget.initial != null;
    final (ok, message) = await ref.read(besoinNotifierProvider.notifier).submit();
    if (!mounted) return;

    if (ok) {
      HapticFeedback.mediumImpact();
      // Rafraîchit la liste « Mes besoins » (accueil + onglet Candidatures)
      // pour que la nouvelle souscription apparaisse immédiatement.
      ref.read(mySubscriptionsNotifierProvider.notifier).loadSubscriptions(silent: true);
      AppStatusDialog.show(
        context,
        type: StatusDialogType.success,
        title: isEditing ? 'Besoin modifié' : 'Besoin enregistré',
        message: isEditing
            ? 'Vos modifications ont bien été prises en compte.'
            : 'Votre demande a bien été transmise au Guichet Unique. Vous pouvez suivre son traitement dans « Mon dossier ».',
        onConfirm: () {
          if (isEditing) {
            if (mounted) context.pop();
            return;
          }
          // Ouvre le dashboard directement sur l'onglet « Mon dossier »
          // (index 3 de l'IndexedStack), barre de navigation conservée.
          if (mounted) context.go(AppRoutes.dashboard, extra: 3);
        },
      );
    } else {
      messenger.clearSnackBars();
      AppStatusDialog.show(
        context,
        type: StatusDialogType.error,
        title: isEditing ? 'Échec de la modification' : "Échec de l'enregistrement",
        message: message ?? "Une erreur s'est produite. Veuillez réessayer.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(besoinNotifierProvider);
    final notifier = ref.read(besoinNotifierProvider.notifier);
    // La question « idée de projet » s'insère en étape 2 : on décale la
    // numérotation des étapes suivantes.
    final stepOffset = state.asksProjectIdea ? 1 : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SAppBar(
        leading: AppBackButton(onPressed: () => context.pop()),
      ),
      body: SOverlayLoader(
        isLoading: state.isSubmitting,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.pagePaddingH,
                  AppDimensions.sp8,
                  AppDimensions.pagePaddingH,
                  AppDimensions.sp24,
                ),
                children: [
                  _IntroHeader(isEditing: state.isEditing),
                  const SizedBox(height: AppDimensions.sp16),

                  // Bandeau non bloquant : hors-ligne (données en cache) ou
                  // échec de chargement d'une des listes.
                  if (state.errorMessage != null)
                    _InfoBanner(
                      icon: Icons.error_outline_rounded,
                      color: AppColors.error,
                      background: AppColors.errorBg,
                      message: state.errorMessage!,
                    )
                  else if (state.isOffline)
                    const _InfoBanner(
                      icon: Icons.cloud_off_rounded,
                      color: AppColors.accent800,
                      background: AppColors.accent100,
                      message:
                          'Mode hors-ligne · les options affichées proviennent du cache.',
                    ),
                  if (state.errorMessage != null || state.isOffline)
                    const SizedBox(height: AppDimensions.sp16),

                  // ── Étape 1 : Catégorie de service ─────────────────────────
                  _StepCard(
                    index: 1,
                    title: 'Catégorie de service',
                    subtitle: 'Besoin sollicité',
                    required: true,
                    status: state.selectedTypeService != null
                        ? _StepStatus.done
                        : _StepStatus.active,
                    child: _buildTypeField(state, notifier),
                  ),
                  // ── Étape 1 bis : Idée de projet (Auto-Emploi) ────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: state.asksProjectIdea
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _StepConnector(),
                              _StepCard(
                                index: 2,
                                title: 'Avez-vous une idée de projet ?',
                                subtitle: 'Pour orienter votre demande de financement',
                                required: true,
                                status: state.hasProjectIdea != null
                                    ? _StepStatus.done
                                    : _StepStatus.active,
                                child: _ProjectIdeaChoice(
                                  value: state.hasProjectIdea,
                                  onChanged: notifier.setProjectIdea,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(width: double.infinity),
                  ),

                  // ── Étapes Structure + Sous-catégorie ──────────────────────
                  // Masquées en Auto-Emploi tant que le candidat n'a pas
                  // répondu « Oui » à la question « idée de projet ».
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: state.showsStructureSteps
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _StepConnector(),
                              _StepCard(
                                index: stepOffset + 2,
                                title: 'Structure',
                                subtitle: 'Partenaire du Guichet Unique',
                                required: state.structureRequired,
                                status: _structureStatus(state),
                                child: _buildStructureField(state, notifier),
                              ),
                              const _StepConnector(),
                              _StepCard(
                                index: stepOffset + 3,
                                title: 'Sous-catégorie de service',
                                subtitle: 'Offre de service',
                                required: state.sousServiceRequired,
                                status: _sousServiceStatus(state),
                                child: _buildServiceField(state, notifier),
                              ),
                            ],
                          )
                        : const SizedBox(width: double.infinity),
                  ),

                  // ── Récapitulatif animé ────────────────────────────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: state.canSubmit
                        ? Padding(
                            padding: const EdgeInsets.only(top: AppDimensions.sp20),
                            child: _RecapCard(state: state),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
            _BottomBar(
              canSubmit: state.canSubmit,
              isSubmitting: state.isSubmitting,
              onSubmit: _submit,
              onReset: notifier.reset,
              submitLabel: state.isEditing
                  ? 'Enregistrer les modifications'
                  : 'Enregistrer le besoin',
            ),
          ],
        ),
      ),
    );
  }

  // ── Champs par étape ────────────────────────────────────────────────────────

  Widget _buildTypeField(BesoinState state, BesoinNotifier notifier) {
    if (state.isLoadingTypes && state.typeServices.isEmpty) {
      return const _LoadingField();
    }
    final selected = state.selectedTypeService;
    return SSearchableDropdown<TypeServiceEntity>(
      label: '',
      value: selected?.label ?? '',
      pickerTitle: 'Catégorie de service',
      searchHint: 'Rechercher une catégorie...',
      options: state.typeServices,
      currentValue: selected,
      labelExtractor: (t) => t.label,
      leadingIcon: selected?.visual.icon ?? Icons.grid_view_rounded,
      onSelected: notifier.selectTypeService,
    );
  }

  Widget _buildStructureField(BesoinState state, BesoinNotifier notifier) {
    if (state.selectedTypeService == null) {
      return const _DisabledField(hint: "Sélectionnez d'abord une catégorie");
    }
    if (state.isLoadingPartners) return const _LoadingField();
    if (state.partnerServices.isEmpty) {
      return const _NonRequisField();
    }
    final selected = state.selectedPartnerService;
    return SSearchableDropdown<PartnerServiceEntity>(
      label: '',
      value: selected?.label ?? '',
      pickerTitle: 'Structure partenaire',
      searchHint: 'Rechercher une structure...',
      options: state.partnerServices,
      currentValue: selected,
      labelExtractor: (p) => p.label,
      leadingIcon: Icons.account_balance_rounded,
      onSelected: notifier.selectPartnerService,
    );
  }

  Widget _buildServiceField(BesoinState state, BesoinNotifier notifier) {
    if (state.selectedTypeService == null) {
      return const _DisabledField(hint: "Sélectionnez d'abord une catégorie");
    }
    if (state.structureRequired && state.selectedPartnerService == null) {
      return const _DisabledField(hint: "Sélectionnez d'abord une structure");
    }
    if (state.isLoadingServices) return const _LoadingField();
    if (state.services.isEmpty) {
      return const _NonRequisField();
    }
    final selected = state.selectedService;
    return SSearchableDropdown<ServiceOfferEntity>(
      label: '',
      value: selected?.label ?? '',
      pickerTitle: 'Offre de service',
      searchHint: 'Rechercher une offre...',
      options: state.services,
      currentValue: selected,
      labelExtractor: (s) => s.label,
      leadingIcon: Icons.assignment_outlined,
      onSelected: notifier.selectService,
    );
  }

  // ── Statuts d'étape ─────────────────────────────────────────────────────────

  _StepStatus _structureStatus(BesoinState state) {
    if (state.selectedTypeService == null) return _StepStatus.locked;
    if (state.isLoadingPartners) return _StepStatus.active;
    // Aucune structure requise, ou structure déjà choisie → étape validée.
    if (!state.structureRequired || state.selectedPartnerService != null) {
      return _StepStatus.done;
    }
    return _StepStatus.active;
  }

  _StepStatus _sousServiceStatus(BesoinState state) {
    if (state.selectedTypeService == null) return _StepStatus.locked;
    if (state.structureRequired && state.selectedPartnerService == null) {
      return _StepStatus.locked;
    }
    if (state.isLoadingServices) return _StepStatus.active;
    if (!state.sousServiceRequired || state.selectedService != null) {
      return _StepStatus.done;
    }
    return _StepStatus.active;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// En-tête d'introduction
// ─────────────────────────────────────────────────────────────────────────────
class _IntroHeader extends StatelessWidget {
  const _IntroHeader({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.secondary100,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          alignment: Alignment.center,
          child: Icon(isEditing ? Icons.edit_rounded : Icons.add_rounded,
              color: AppColors.secondary800, size: AppDimensions.iconLG),
        ),
        const SizedBox(width: AppDimensions.sp12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(isEditing ? 'Modifier le besoin' : 'Nouveau besoin',
                  style: AppTextStyles.headingLarge
                      .copyWith(color: AppColors.neutral800)),
              const SizedBox(height: 2),
              Text(
                isEditing
                    ? 'Ajustez votre sélection puis enregistrez vos modifications.'
                    : 'Sélectionnez un service, puis la structure et le sous-service correspondants.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bandeau d'information non bloquant
// ─────────────────────────────────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.message,
    this.background,
  });

  final IconData icon;
  final Color color;
  final Color? background;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppDimensions.sp10, horizontal: AppDimensions.sp12),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppDimensions.iconSM),
          const SizedBox(width: AppDimensions.sp8),
          Expanded(
            child: Text(message,
                style: AppTextStyles.bodySmall.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte d'étape : badge numéroté + titre + champ
// ─────────────────────────────────────────────────────────────────────────────
enum _StepStatus { locked, active, done }

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.required,
    required this.status,
    required this.child,
  });

  final int index;
  final String title;
  final String subtitle;
  final bool required;
  final _StepStatus status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLocked = status == _StepStatus.locked;
    final isDone = status == _StepStatus.done;

    final (badgeBg, badgeFg, borderColor) = switch (status) {
      _StepStatus.done => (AppColors.primary400, AppColors.white, AppColors.primary100),
      _StepStatus.active => (AppColors.secondary800, AppColors.white, AppColors.secondary100),
      _StepStatus.locked => (AppColors.neutral100, AppColors.neutral400, AppColors.border),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(AppDimensions.sp16),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.neutral50 : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: borderColor,
          width: status == _StepStatus.active
              ? AppDimensions.borderMedium
              : AppDimensions.borderThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Badge numéroté / coche
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26,
                height: 26,
                decoration: BoxDecoration(color: badgeBg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
                    : Text('$index',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: badgeFg, letterSpacing: 0)),
              ),
              const SizedBox(width: AppDimensions.sp10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isLocked
                                  ? AppColors.neutral400
                                  : AppColors.neutral800,
                            ),
                          ),
                        ),
                        if (required) ...[
                          const SizedBox(width: 3),
                          Text('*',
                              style: AppTextStyles.labelMedium
                                  .copyWith(color: AppColors.error)),
                        ],
                      ],
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: isLocked ? AppColors.neutral300 : AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            transitionBuilder: (c, a) => FadeTransition(
              opacity: a,
              child: SizeTransition(sizeFactor: a, axisAlignment: -1, child: c),
            ),
            child: KeyedSubtree(
              key: ValueKey('${status.name}_${child.runtimeType}'),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Trait vertical reliant deux cartes d'étape.
class _StepConnector extends StatelessWidget {
  const _StepConnector();

  @override
  Widget build(BuildContext context) {
    // Align → contraintes lâches pour que la largeur fixe de 2px soit
    // respectée (un enfant direct de ListView reçoit sinon une largeur imposée
    // égale à celle du viewport).
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12),
        width: 2,
        height: AppDimensions.sp12,
        color: AppColors.border,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Variantes de champ : désactivé, « non requis », chargement
// ─────────────────────────────────────────────────────────────────────────────
class _DisabledField extends StatelessWidget {
  const _DisabledField({required this.hint});
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp16),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: AppDimensions.iconSM, color: AppColors.neutral300),
          const SizedBox(width: AppDimensions.sp10),
          Expanded(
            child: Text(hint,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral400),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

class _NonRequisField extends StatelessWidget {
  const _NonRequisField();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sp16, vertical: AppDimensions.sp14),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: AppDimensions.iconSM, color: AppColors.primary600),
          const SizedBox(width: AppDimensions.sp10),
          Expanded(
            child: Text(
              'Non requis pour cette catégorie de service.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary800),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingField extends StatelessWidget {
  const _LoadingField();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: SShimmer(
              width: double.infinity,
              height: AppDimensions.inputHeight,
              radius: AppDimensions.radiusMD),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Choix Oui / Non « Avez-vous une idée de projet ? »
// ─────────────────────────────────────────────────────────────────────────────
class _ProjectIdeaChoice extends StatelessWidget {
  const _ProjectIdeaChoice({required this.value, required this.onChanged});

  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _ChoiceTile(
                label: 'Oui',
                icon: Icons.lightbulb_rounded,
                selected: value == true,
                onTap: () => onChanged(true),
              ),
            ),
            const SizedBox(width: AppDimensions.sp12),
            Expanded(
              child: _ChoiceTile(
                label: 'Non',
                icon: Icons.lightbulb_outline_rounded,
                selected: value == false,
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: value == false
              ? Padding(
                  padding: const EdgeInsets.only(top: AppDimensions.sp12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: AppDimensions.iconSM, color: AppColors.neutral400),
                      const SizedBox(width: AppDimensions.sp8),
                      Expanded(
                        child: Text(
                          'Un conseiller vous accompagnera pour définir votre projet. '
                          'Seul votre besoin sera transmis.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.neutral500),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.secondary800 : AppColors.neutral500;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: AppDimensions.inputHeight,
            decoration: BoxDecoration(
              color: selected ? AppColors.secondary50 : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(
                color: selected ? AppColors.secondary800 : AppColors.border,
                width: selected
                    ? AppDimensions.borderMedium
                    : AppDimensions.borderThin,
              ),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (c, a) =>
                      ScaleTransition(scale: a, child: c),
                  child: Icon(
                    selected ? Icons.check_circle_rounded : icon,
                    key: ValueKey(selected),
                    size: AppDimensions.iconSM,
                    color: fg,
                  ),
                ),
                const SizedBox(width: AppDimensions.sp8),
                Text(label, style: AppTextStyles.labelMedium.copyWith(color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Récapitulatif
// ─────────────────────────────────────────────────────────────────────────────
class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.state});
  final BesoinState state;

  @override
  Widget build(BuildContext context) {
    final type = state.selectedTypeService!;
    final visual = type.visual;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.sp16),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.secondary100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize_rounded,
                  size: AppDimensions.iconSM, color: AppColors.secondary800),
              const SizedBox(width: AppDimensions.sp8),
              Text('Récapitulatif',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.secondary800, letterSpacing: 0.4)),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          _RecapRow(
            icon: visual.icon,
            iconColor: visual.color,
            iconBg: visual.background,
            label: 'Besoin sollicité',
            value: type.label,
          ),
          if (state.asksProjectIdea && state.hasProjectIdea != null) ...[
            const SizedBox(height: AppDimensions.sp10),
            _RecapRow(
              icon: state.hasProjectIdea!
                  ? Icons.lightbulb_rounded
                  : Icons.lightbulb_outline_rounded,
              iconColor: AppColors.accent900,
              iconBg: AppColors.accent100,
              label: 'Idée de projet',
              value: state.hasProjectIdea! ? 'Oui' : 'Non, pas encore',
            ),
          ],
          if (state.showsStructureSteps && state.selectedPartnerService != null) ...[
            const SizedBox(height: AppDimensions.sp10),
            _RecapRow(
              icon: Icons.account_balance_rounded,
              iconColor: AppColors.secondary800,
              iconBg: AppColors.secondary100,
              label: 'Structure',
              value: state.selectedPartnerService!.label,
            ),
          ],
          if (state.showsStructureSteps && state.selectedService != null) ...[
            const SizedBox(height: AppDimensions.sp10),
            _RecapRow(
              icon: Icons.assignment_turned_in_outlined,
              iconColor: AppColors.primary800,
              iconBg: AppColors.primary100,
              label: 'Offre de service',
              value: state.selectedService!.label,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: AppDimensions.iconSM, color: iconColor),
        ),
        const SizedBox(width: AppDimensions.sp10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
              const SizedBox(height: 1),
              Text(
                value,
                style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutral800),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Barre d'action inférieure
// ─────────────────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onReset,
    required this.submitLabel,
  });

  final String submitLabel;
  final bool canSubmit;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH,
            AppDimensions.sp12,
            AppDimensions.pagePaddingH,
            AppDimensions.sp12,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SButton(
                  label: 'Réinitialiser',
                  variant: SButtonVariant.outline,
                  onPressed: isSubmitting ? null : onReset,
                  isDisabled: isSubmitting,
                ),
              ),
              const SizedBox(width: AppDimensions.sp12),
              Expanded(
                flex: 3,
                child: SButton(
                  label: submitLabel,
                  variant: SButtonVariant.primary,
                  leadingIcon: Icons.check_circle_outline_rounded,
                  isLoading: isSubmitting,
                  isDisabled: !canSubmit,
                  onPressed: canSubmit ? onSubmit : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

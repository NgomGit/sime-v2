// features/rendezvous/presentation/screens/rendezvous_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../../../core/design_system/tokens/app_dimensions.dart';
import '../../../../core/design_system/tokens/app_text_styles.dart';
import '../../../../core/design_system/widgets/s_card.dart';
import '../../../../core/design_system/widgets/s_shimer.dart';
import '../../../../core/utils/maps_launcher.dart';
import '../../domain/entities/rdv_entity.dart';
import '../providers/rdv_notifier.dart';
import '../widgets/rdv_status_badge.dart';

/// Écran "Mon agenda" — liste des rendez-vous ANPEJ du candidat connecté.
///
/// Offline-first : `RdvNotifier`/`RdvRepositoryImpl` servent le cache Hive
/// quand le réseau est indisponible (voir `OfflineFirstMixin.offlineFirst`).
/// Cet écran se contente de refléter fidèlement l'état exposé par
/// [RdvState] : chargement, erreur bloquante (aucune donnée), bandeau non
/// bloquant (donnée en cache / erreur avec données existantes), et
/// indicateur de synchronisation en arrière-plan au retour de connexion.
class RendezVousScreen extends ConsumerStatefulWidget {
  const RendezVousScreen({super.key});

  @override
  ConsumerState<RendezVousScreen> createState() => _RendezVousScreenState();
}

class _RendezVousScreenState extends ConsumerState<RendezVousScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rdvNotifierProvider.notifier).loadRdvs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rdvNotifierProvider);

    // Écran de chargement initial plein écran (skeleton, pas de spinner nu)
    if (state.isLoading && !state.hasData) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(child: _AgendaSkeleton()),
      );
    }

    // Écran d'erreur bloquant : aucune donnée à montrer, même en cache
    if (state.errorMessage != null && !state.hasData && !state.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _AgendaErrorState(
            message: state.errorMessage!,
            onRetry: () => ref.read(rdvNotifierProvider.notifier).loadRdvs(),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.secondary800,
          onRefresh: () => ref.read(rdvNotifierProvider.notifier).loadRdvs(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _AgendaHeader(state: state)),

              // Bandeau non bloquant : soit une vraie erreur malgré des
              // données existantes, soit simplement "hors-ligne, données en
              // cache" — deux tons distincts pour ne pas alarmer inutilement.
              if (state.errorMessage != null && state.hasData)
                SliverToBoxAdapter(
                  child: _InfoBanner(
                    icon: Icons.signal_wifi_connected_no_internet_4_rounded,
                    color: AppColors.error,
                    message: 'Impossible d\'actualiser : ${state.errorMessage}',
                  ),
                )
              else if (state.isShowingStaleData)
                SliverToBoxAdapter(
                  child: _InfoBanner(
                    icon: Icons.cloud_off_rounded,
                    color: AppColors.accent800,
                    background: AppColors.accent100,
                    message: state.lastUpdated != null
                        ? 'Mode hors-ligne · Dernière mise à jour ${_relativeTime(state.lastUpdated!)}'
                        : 'Mode hors-ligne · Rendez-vous en cache',
                  ),
                ),

              if (!state.hasData)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _AgendaEmptyState(),
                )
              else
                _AgendaTimelineSlivers(state: state),

              const SliverToBoxAdapter(child: SizedBox(height: AppDimensions.sp24)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formate un horodatage en "à l'instant" / "il y a N min" / "il y a N h".
String _relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return "à l'instant";
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  return 'il y a ${diff.inDays} j';
}

String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String _dayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;
  if (diff == 0) return "Aujourd'hui";
  if (diff == 1) return 'Demain';
  if (diff == -1) return 'Hier';
  return _capitalize(DateFormat('EEEE dd MMMM', 'fr').format(date));
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — titre + décompte réel + indicateur de synchronisation discret
// ─────────────────────────────────────────────────────────────────────────────
class _AgendaHeader extends StatelessWidget {
  const _AgendaHeader({required this.state});

  final RdvState state;

  @override
  Widget build(BuildContext context) {
    final upcomingCount = state.upcoming.length;
    final subtitle = upcomingCount == 0
        ? 'Aucun rendez-vous à venir'
        : upcomingCount == 1
            ? '1 rendez-vous à venir'
            : '$upcomingCount rendez-vous à venir';

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20, AppDimensions.sp14,
        AppDimensions.sp20, AppDimensions.sp12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mon agenda', style: AppTextStyles.headingMedium.copyWith(color: AppColors.neutral800)),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500)),
                ],
              ),
              const Spacer(),
            ],
          ),
          // Indicateur de synchronisation en arrière-plan — n'apparaît que
          // pendant le rafraîchissement silencieux déclenché au retour de
          // connexion (voir rdv_notifier.dart), jamais au chargement initial.
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: state.isSyncing
                ? const Padding(
                    padding: EdgeInsets.only(top: AppDimensions.sp10),
                    child: _SyncingPill(),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SyncingPill extends StatelessWidget {
  const _SyncingPill();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12, height: 12,
          child: CircularProgressIndicator(strokeWidth: 1.6, color: AppColors.primary400),
        ),
        const SizedBox(width: AppDimensions.sp8),
        Text(
          'Synchronisation…',
          style: AppTextStyles.caption.copyWith(color: AppColors.primary800, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bandeau d'information non bloquant (erreur avec cache, ou mode hors-ligne)
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
      color: background ?? color.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: AppDimensions.pagePaddingH),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: AppTextStyles.bodySmall.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Timeline — regroupée par jour pour les RDV à venir, liste plate pour l'historique
// ─────────────────────────────────────────────────────────────────────────────
class _AgendaTimelineSlivers extends StatelessWidget {
  const _AgendaTimelineSlivers({required this.state});

  final RdvState state;

  @override
  Widget build(BuildContext context) {
    final upcoming = state.upcoming;
    final past = state.past;

    // Regroupement par jour (ordre déjà croissant depuis RdvState.upcoming)
    final Map<String, List<RdvEntity>> byDay = {};
    for (final r in upcoming) {
      final key = DateFormat('yyyy-MM-dd').format(r.startAt);
      byDay.putIfAbsent(key, () => []).add(r);
    }

    final children = <Widget>[];

    for (final entry in byDay.entries) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH, AppDimensions.sp16,
          AppDimensions.pagePaddingH, AppDimensions.sp10,
        ),
        child: _SectionLabel(label: _dayLabel(entry.value.first.startAt)),
      ));
      for (final rdv in entry.value) {
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH, 0,
            AppDimensions.pagePaddingH, AppDimensions.sp12,
          ),
          child: _RdvTimelineCard(rdv: rdv),
        ));
      }
    }

    if (past.isNotEmpty) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.pagePaddingH, AppDimensions.sp20,
          AppDimensions.pagePaddingH, AppDimensions.sp10,
        ),
        child: const _SectionLabel(label: 'Historique'),
      ));
      for (final rdv in past) {
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.pagePaddingH, 0,
            AppDimensions.pagePaddingH, AppDimensions.sp10,
          ),
          child: _RdvTimelineCard(rdv: rdv, isPast: true),
        ));
      }
    }

    return SliverList(delegate: SliverChildListDelegate(children));
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelSmall.copyWith(color: AppColors.neutral400, letterSpacing: 0.5),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte de rendez-vous
// ─────────────────────────────────────────────────────────────────────────────
class _RdvTimelineCard extends StatelessWidget {
  const _RdvTimelineCard({required this.rdv, this.isPast = false});

  final RdvEntity rdv;
  final bool isPast;

  Future<void> _openDirections(BuildContext context, String? address) async {
    final opened = await openLocationInMaps(
      latitude: rdv.office?.latitude,
      longitude: rdv.office?.longitude,
      address: address,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir une application de cartes")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConfirmed = rdv.statusRdv == RdvStatus.accepted;
    final officeName = rdv.office?.name ?? 'Bureau ANPEJ';
    final address = rdv.office?.address ?? rdv.office?.name;
    final hasLocation = (address != null && address.trim().isNotEmpty) || (rdv.office?.hasCoordinates ?? false);

    return Opacity(
      opacity: isPast ? 0.65 : 1.0,
      child: SCard(
        color: isPast
            ? AppColors.neutral50
            : isConfirmed
                ? AppColors.secondary50
                : AppColors.surface,
        borderColor: isPast
            ? AppColors.border
            : isConfirmed
                ? AppColors.secondary100
                : AppColors.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TimeChip(start: rdv.startAt, end: rdv.endAt, muted: isPast),
                const Spacer(),
                RdvStatusBadge(status: rdv.statusRdv, rawStatus: rdv.rawStatusRdv),
              ],
            ),
            const SizedBox(height: AppDimensions.sp12),
            Text(
              officeName,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (address != null && address.trim().isNotEmpty) ...[
              const SizedBox(height: AppDimensions.sp4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: AppDimensions.iconXS, color: AppColors.neutral400),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      address,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (hasLocation && !isPast) ...[
              const SizedBox(height: AppDimensions.sp8),
              _DirectionsButton(onTap: () => _openDirections(context, address)),
            ],
            if (rdv.wasRescheduled) ...[
              const SizedBox(height: AppDimensions.sp8),
              Row(
                children: [
                  const Icon(Icons.history_toggle_off_rounded, size: AppDimensions.iconXS, color: AppColors.bleuANPEJ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      rdv.rescheduleReason?.isNotEmpty == true
                          ? 'Reprogrammé · ${rdv.rescheduleReason}'
                          : 'Ce rendez-vous a été reprogrammé',
                      style: AppTextStyles.caption.copyWith(color: AppColors.bleuANPEJDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppDimensions.sp12),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: AppDimensions.sp10),
            _AgentRow(agent: rdv.agent),
          ],
        ),
      ),
    );
  }
}

/// Pastille horaire — remplace l'ancienne colonne latérale à largeur fixe
/// qui coupait "08h30" en "08h3" / "0" sur les libellés plus larges (voir
/// capture utilisateur). Une pastille dimensionnée à son contenu, dans une
/// Row avec `Spacer`, ne peut plus se retrouver contrainte de la sorte.
class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.start, required this.end, this.muted = false});

  final DateTime start;
  final DateTime end;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final range = "${DateFormat("HH'h'mm").format(start)} – ${DateFormat("HH'h'mm").format(end)}";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp10, vertical: AppDimensions.sp6),
      decoration: BoxDecoration(
        color: muted ? AppColors.neutral100 : AppColors.secondary100,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: AppDimensions.iconXS, color: muted ? AppColors.neutral400 : AppColors.secondary800),
          const SizedBox(width: 5),
          Text(
            range,
            style: AppTextStyles.labelSmall.copyWith(
              color: muted ? AppColors.neutral500 : AppColors.secondary800,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton "Itinéraire" — ouvre la localisation du bureau dans l'app de
/// cartes par défaut (voir core/utils/maps_launcher.dart). Couleur bleue
/// distincte du marron institutionnel des CTA principaux : signale une
/// action secondaire qui quitte l'app plutôt qu'une action de formulaire.
class _DirectionsButton extends StatelessWidget {
  const _DirectionsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sp12, vertical: AppDimensions.sp6),
        decoration: BoxDecoration(
          color: AppColors.bleuANPEJBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.bleuANPEJ.withAlpha(60)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_rounded, size: AppDimensions.iconXS, color: AppColors.bleuANPEJDark),
            const SizedBox(width: 4),
            Text(
              'Itinéraire',
              style: AppTextStyles.labelXSmall.copyWith(color: AppColors.bleuANPEJDark, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne conseiller — gère explicitement le cas `agent == null` (observé
/// dans le payload réel : un RDV peut être `ACCEPTED` sans conseiller encore
/// assigné) plutôt que de le masquer silencieusement.
class _AgentRow extends StatelessWidget {
  const _AgentRow({required this.agent});
  final RdvAgentEntity? agent;

  @override
  Widget build(BuildContext context) {
    if (agent == null) {
      return Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: AppColors.neutral100, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: const Icon(Icons.person_outline_rounded, size: AppDimensions.iconXS, color: AppColors.neutral400),
          ),
          const SizedBox(width: AppDimensions.sp8),
          Text(
            "En attente d'affectation d'un conseiller",
            style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
          ),
        ],
      );
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.secondary800,
          child: Text(
            agent!.initials,
            style: AppTextStyles.labelXSmall.copyWith(color: AppColors.white),
          ),
        ),
        const SizedBox(width: AppDimensions.sp8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(agent!.fullName, style: AppTextStyles.labelMedium.copyWith(color: AppColors.neutral800)),
              Text('Conseiller emploi', style: AppTextStyles.caption.copyWith(color: AppColors.neutral400)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// États : skeleton / erreur / vide
// ─────────────────────────────────────────────────────────────────────────────
class _AgendaSkeleton extends StatelessWidget {
  const _AgendaSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        const SShimmer(width: 140, height: 22),
        const SizedBox(height: AppDimensions.sp4),
        const SShimmer(width: 180, height: 14),
        const SizedBox(height: AppDimensions.sp24),
        const SShimmer(width: 90, height: 12),
        const SizedBox(height: AppDimensions.sp10),
        ...List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.sp12),
              child: SShimmer(width: double.infinity, height: 128, radius: AppDimensions.radiusLG),
            )),
      ],
    );
  }
}

class _AgendaErrorState extends StatelessWidget {
  const _AgendaErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 48),
            const SizedBox(height: AppDimensions.sp14),
            Text('Connexion impossible', style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class _AgendaEmptyState extends StatelessWidget {
  const _AgendaEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePaddingH * 1.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.secondary100, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const Icon(Icons.event_available_outlined, size: 32, color: AppColors.secondary600),
            ),
            const SizedBox(height: AppDimensions.sp16),
            Text(
              'Aucun rendez-vous',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800),
            ),
            const SizedBox(height: AppDimensions.sp6),
            Text(
              'Vos prochains rendez-vous avec un conseiller ANPEJ apparaîtront ici dès qu\'ils seront planifiés.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

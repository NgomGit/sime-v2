// features/reclamation/presentation/screens/reclamations_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/design_system/widgets/s_button.dart';
import 'package:sime_v2/core/design_system/widgets/s_card.dart';
import 'package:sime_v2/core/design_system/widgets/s_shimer.dart';
import 'package:sime_v2/features/auth/presentation/providers/login_provider.dart';

import '../../domain/entities/reclamation_entity.dart';
import '../../domain/repositories/reclamation_repository.dart';
import '../providers/reclamations_notifier.dart';

/// Écran « Mes réclamations » — liste des réclamations du demandeur connecté.
///
/// Offline-first : la liste est servie depuis le cache Hive hors-ligne
/// (voir `ReclamationRepositoryImpl`). Cet écran reflète fidèlement
/// [ReclamationsState] : skeleton au 1er chargement, erreur bloquante si aucune
/// donnée, bandeau non bloquant (cache hors-ligne), et indicateur de
/// synchronisation discret au retour de connexion.
class ReclamationsScreen extends ConsumerStatefulWidget {
  const ReclamationsScreen({super.key});

  @override
  ConsumerState<ReclamationsScreen> createState() => _ReclamationsScreenState();
}

class _ReclamationsScreenState extends ConsumerState<ReclamationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reclamationsNotifierProvider.notifier).ensureLoaded();
    });
  }

  Future<void> _openNewReclamation() async {
    final applicantId =
        ref.read(loginNotifierProvider).valueOrNull?.authResponse?.user.applicantId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewReclamationSheet(applicantId: applicantId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reclamationsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      floatingActionButton: _NewClaimFab(onTap: _openNewReclamation),
      body: SafeArea(
        top: false,
        child: _buildBody(state),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral800),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Mes réclamations',
        style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.border),
      ),
    );
  }

  Widget _buildBody(ReclamationsState state) {
    if (state.isLoading && !state.hasData) {
      return const _ReclamationsSkeleton();
    }

    if (state.errorMessage != null && !state.hasData && !state.isLoading) {
      return _ReclamationsErrorState(
        message: state.errorMessage!,
        onRetry: () => ref.read(reclamationsNotifierProvider.notifier).loadClaims(),
      );
    }

    final claims = state.sortedClaims;

    return RefreshIndicator(
      color: AppColors.secondary800,
      onRefresh: () => ref.read(reclamationsNotifierProvider.notifier).loadClaims(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _Header(state: state)),

          if (state.errorMessage != null && state.hasData)
            SliverToBoxAdapter(
              child: _InfoBanner(
                icon: Icons.signal_wifi_connected_no_internet_4_rounded,
                color: AppColors.error,
                message: "Impossible d'actualiser : ${state.errorMessage}",
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
                    : 'Mode hors-ligne · Réclamations en cache',
              ),
            ),

          if (!state.hasData)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _ReclamationsEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.pagePaddingH,
                AppDimensions.sp14,
                AppDimensions.pagePaddingH,
                AppDimensions.sp48 * 2,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (final pending in state.pendingClaims)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.sp12),
                      child: _PendingClaimCard(
                        message: pending.content,
                        isOffline: state.isOffline,
                        isSyncing: state.isSyncing,
                        onRetry: () => ref
                            .read(reclamationsNotifierProvider.notifier)
                            .retryPendingSubmissions(),
                      ),
                    ),
                  for (final claim in claims)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.sp12),
                      child: _ClaimCard(
                        claim: claim,
                        onTap: () => context.push(
                          AppRoutes.reclamationChat,
                          extra: claim.id,
                        ),
                      ),
                    ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return "à l'instant";
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  return 'il y a ${diff.inDays} j';
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.state});
  final ReclamationsState state;

  @override
  Widget build(BuildContext context) {
    final total = state.claims.length;
    final open = state.openCount;
    final subtitle = total == 0
        ? 'Posez vos questions à un conseiller ANPEJ'
        : open == 0
            ? '$total réclamation${total > 1 ? 's' : ''} · toutes traitées'
            : '$open en attente de réponse · $total au total';

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sp20,
        AppDimensions.sp8,
        AppDimensions.sp20,
        AppDimensions.sp16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Échanges avec votre conseiller',
            style: AppTextStyles.eyebrow.copyWith(color: AppColors.secondary400),
          ),
          const SizedBox(height: AppDimensions.sp4),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral500),
          ),
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
        const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.6,
            color: AppColors.primary400,
          ),
        ),
        const SizedBox(width: AppDimensions.sp8),
        Text(
          'Synchronisation…',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primary800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

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
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: AppDimensions.pagePaddingH,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Carte réclamation
// ─────────────────────────────────────────────────────────────────────────────
class _ClaimCard extends StatelessWidget {
  const _ClaimCard({required this.claim, required this.onTap});

  final ClaimRequestEntity claim;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasAgent = (claim.agent?.fullName.isNotEmpty ?? false);
    // Un conseiller a répondu dès qu'il existe au moins une réponse serveur,
    // même si l'API ne renvoie pas son identité (champ agent souvent null).
    final hasResponded = claim.responses.isNotEmpty;
    final isActive = hasAgent || hasResponded;
    final agentLabel = hasAgent
        ? claim.agent!.fullName
        : hasResponded
            ? 'Conseiller ANPEJ'
            : "En attente d'un conseiller";

    return SCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ClaimStatusBadge(status: claim.status),
              const Spacer(),
              Text(
                '#${claim.id}',
                style: AppTextStyles.labelXSmall.copyWith(
                  color: AppColors.neutral300,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sp12),
          Text(
            claim.title,
            style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.sp6),
          _LastReplyPreview(claim: claim),
          const SizedBox(height: AppDimensions.sp12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: AppDimensions.sp10),
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.secondary800 : AppColors.neutral100,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: hasAgent
                    ? Text(
                        claim.agent!.initials,
                        style: AppTextStyles.labelXSmall.copyWith(
                          color: AppColors.white,
                        ),
                      )
                    : Icon(
                        Icons.support_agent_rounded,
                        size: AppDimensions.iconXS,
                        color: isActive ? AppColors.white : AppColors.neutral400,
                      ),
              ),
              const SizedBox(width: AppDimensions.sp8),
              Expanded(
                child: Text(
                  agentLabel,
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? AppColors.neutral600 : AppColors.neutral400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: AppDimensions.iconXS,
                color: AppColors.neutral300,
              ),
              const SizedBox(width: 4),
              Text(
                '${claim.exchangeCount}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.neutral400,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(width: AppDimensions.sp6),
              const Icon(
                Icons.chevron_right_rounded,
                size: AppDimensions.iconSM,
                color: AppColors.neutral300,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Aperçu de la dernière réponse (préfixé « Conseiller : » si elle vient du
/// service), pour donner un indice de conversation sans ouvrir le fil.
class _LastReplyPreview extends StatelessWidget {
  const _LastReplyPreview({required this.claim});
  final ClaimRequestEntity claim;

  @override
  Widget build(BuildContext context) {
    final last = claim.lastMessage;
    if (last == null || claim.responses.isEmpty) {
      return Text(
        'Aucune réponse pour le moment',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral400),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    final prefix = last.isAgent ? 'Conseiller : ' : 'Vous : ';
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
        children: [
          TextSpan(
            text: prefix,
            style: AppTextStyles.bodySmall.copyWith(
              color: last.isAgent ? AppColors.primary800 : AppColors.neutral400,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(text: last.content),
        ],
      ),
    );
  }
}

class _ClaimStatusBadge extends StatelessWidget {
  const _ClaimStatusBadge({required this.status});
  final ClaimStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg, dot) = switch (status) {
      ClaimStatus.answered => (
          'Répondu',
          AppColors.successBg,
          AppColors.primary800,
          AppColors.primary400,
        ),
      ClaimStatus.open => (
          'En attente',
          AppColors.accent100,
          AppColors.accent900,
          AppColors.accent500,
        ),
      ClaimStatus.closed => (
          'Clôturée',
          AppColors.neutral100,
          AppColors.neutral500,
          AppColors.neutral400,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sp10,
        vertical: AppDimensions.sp4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.labelXSmall.copyWith(color: fg)),
        ],
      ),
    );
  }
}

/// Carte optimiste d'une réclamation créée hors-ligne, pas encore synchronisée.
class _PendingClaimCard extends StatelessWidget {
  const _PendingClaimCard({
    required this.message,
    required this.isOffline,
    required this.isSyncing,
    required this.onRetry,
  });

  final String message;
  final bool isOffline;
  final bool isSyncing;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.9,
      child: SCard(
        color: AppColors.neutral50,
        borderColor: AppColors.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: AppDimensions.iconXS,
                  color: AppColors.accent800,
                ),
                const SizedBox(width: 6),
                Text(
                  "En attente d'envoi",
                  style: AppTextStyles.labelXSmall.copyWith(
                    color: AppColors.accent900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sp10),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.sp10),
            _buildAction(),
          ],
        ),
      ),
    );
  }

  /// Zone d'action contextuelle :
  ///  • en cours de synchro → indicateur « Envoi en cours… » ;
  ///  • hors-ligne → simple message d'attente ;
  ///  • en ligne → bouton « Réessayer l'envoi » pour forcer l'acheminement.
  Widget _buildAction() {
    if (isSyncing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: AppColors.secondary800,
            ),
          ),
          const SizedBox(width: AppDimensions.sp8),
          Text(
            'Envoi en cours…',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (isOffline) {
      return Text(
        'Sera transmise dès le retour de la connexion',
        style: AppTextStyles.caption.copyWith(color: AppColors.neutral400),
      );
    }

    // Connexion disponible : proposer un envoi manuel immédiat.
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onRetry,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary800,
          backgroundColor: AppColors.secondary100,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sp12,
            vertical: AppDimensions.sp8,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
        ),
        icon: const Icon(Icons.send_rounded, size: AppDimensions.iconXS),
        label: Text(
          "Réessayer l'envoi",
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.secondary800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAB « Nouvelle réclamation »
// ─────────────────────────────────────────────────────────────────────────────
class _NewClaimFab extends StatelessWidget {
  const _NewClaimFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onTap,
      backgroundColor: AppColors.secondary800,
      foregroundColor: AppColors.white,
      elevation: 2,
      tooltip: 'Nouvelle réclamation',
      child: const Icon(Icons.rate_review_rounded, size: AppDimensions.iconLG),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet de création
// ─────────────────────────────────────────────────────────────────────────────
class _NewReclamationSheet extends ConsumerStatefulWidget {
  const _NewReclamationSheet({required this.applicantId});
  final int? applicantId;

  @override
  ConsumerState<_NewReclamationSheet> createState() =>
      _NewReclamationSheetState();
}

class _NewReclamationSheetState extends ConsumerState<_NewReclamationSheet> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final message = _controller.text.trim();
    final applicantId = widget.applicantId;
    if (message.isEmpty || applicantId == null) return;

    setState(() => _submitting = true);
    final outcome = await ref
        .read(reclamationsNotifierProvider.notifier)
        .createClaim(message: message, applicantId: applicantId);

    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();

    final messenger = ScaffoldMessenger.of(context);
    if (outcome == ClaimSendOutcome.sent) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Réclamation envoyée à votre conseiller.')),
      );
    } else if (outcome == ClaimSendOutcome.queued) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Hors-ligne : réclamation enregistrée, envoi au retour du réseau.'),
        ),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text("Échec de l'envoi. Réessayez plus tard.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final noApplicant = widget.applicantId == null;
    final canSend = _controller.text.trim().isNotEmpty && !noApplicant;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXXL),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.sp20,
          AppDimensions.sp12,
          AppDimensions.sp20,
          AppDimensions.sp20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.sp18),
            Text(
              'Nouvelle réclamation',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
            ),
            const SizedBox(height: AppDimensions.sp4),
            Text(
              'Décrivez votre demande. Un conseiller ANPEJ vous répondra ici.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral500),
            ),
            const SizedBox(height: AppDimensions.sp16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.sp14,
                vertical: AppDimensions.sp10,
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                minLines: 3,
                maxLines: 6,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.neutral800,
                  height: 1.5,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: 'Votre message…',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.neutral300,
                  ),
                ),
              ),
            ),
            if (noApplicant) ...[
              const SizedBox(height: AppDimensions.sp10),
              Text(
                'Profil demandeur indisponible : reconnectez-vous pour envoyer une réclamation.',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppDimensions.sp16),
            SButton(
              label: 'Envoyer la réclamation',
              variant: SButtonVariant.primary,
              leadingIcon: Icons.send_rounded,
              isLoading: _submitting,
              isDisabled: !canSend,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// États : skeleton / erreur / vide
// ─────────────────────────────────────────────────────────────────────────────
class _ReclamationsSkeleton extends StatelessWidget {
  const _ReclamationsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        const SShimmer(width: 220, height: 12),
        const SizedBox(height: AppDimensions.sp6),
        const SShimmer(width: 160, height: 12),
        const SizedBox(height: AppDimensions.sp24),
        ...List.generate(
          3,
          (i) => const Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.sp12),
            child: SShimmer(
              width: double.infinity,
              height: 132,
              radius: AppDimensions.radiusLG,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReclamationsErrorState extends StatelessWidget {
  const _ReclamationsErrorState({required this.message, required this.onRetry});
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
            Text(
              'Connexion impossible',
              style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
            ),
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

class _ReclamationsEmptyState extends StatelessWidget {
  const _ReclamationsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePaddingH * 1.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.secondary100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.forum_outlined,
                size: 32,
                color: AppColors.secondary600,
              ),
            ),
            const SizedBox(height: AppDimensions.sp16),
            Text(
              'Aucune réclamation',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800),
            ),
            const SizedBox(height: AppDimensions.sp6),
            Text(
              "Une question, un blocage ? Ouvrez une réclamation et échangez directement avec un conseiller ANPEJ.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
      ),
    );
  }
}

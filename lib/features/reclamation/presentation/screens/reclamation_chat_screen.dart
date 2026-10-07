// features/reclamation/presentation/screens/reclamation_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_dimensions.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/network/network_info.dart';
import 'package:sime_v2/features/auth/presentation/providers/login_provider.dart';

import '../../domain/entities/reclamation_entity.dart';
import '../providers/reclamation_thread_notifier.dart';
import '../providers/reclamations_notifier.dart';

/// Écran de conversation d'une réclamation — messagerie demandeur ↔ conseiller.
///
/// Le fil « serveur » (message d'ouverture + réponses conseiller) est lu depuis
/// `reclamationsNotifierProvider` ; les réponses locales du demandeur (envois
/// optimistes) viennent de `reclamationThreadProvider`. L'écran concatène les
/// deux et affiche un accusé d'acheminement sur chaque message du demandeur.
class ReclamationChatScreen extends ConsumerStatefulWidget {
  const ReclamationChatScreen({super.key, required this.claimId});

  final int claimId;

  @override
  ConsumerState<ReclamationChatScreen> createState() =>
      _ReclamationChatScreenState();
}

class _ReclamationChatScreenState extends ConsumerState<ReclamationChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Garantit des données à afficher même en deep-link direct.
      ref.read(reclamationsNotifierProvider.notifier).ensureLoaded();
      _jumpToBottom();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  void _animateToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  ClaimRequestEntity? _findClaim(ReclamationsState state) {
    for (final c in state.claims) {
      if (c.id == widget.claimId) return c;
    }
    return null;
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    final applicantId =
        ref.read(loginNotifierProvider).valueOrNull?.authResponse?.user.applicantId;
    if (text.isEmpty || applicantId == null) return;

    _controller.clear();
    setState(() {});

    final outcome = await ref
        .read(reclamationThreadProvider(widget.claimId).notifier)
        .send(message: text, applicantId: applicantId);

    // Récupère d'éventuelles nouvelles réponses du conseiller côté serveur.
    ref.read(reclamationsNotifierProvider.notifier).loadClaims(silent: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _animateToBottom());

    if (!mounted) return;
    if (outcome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Le message n'a pas pu être envoyé."),
          action: SnackBarAction(
            label: 'Réessayer',
            onPressed: () {
              _controller.text = text;
              _send();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(reclamationsNotifierProvider);
    final threadState = ref.watch(reclamationThreadProvider(widget.claimId));
    final isConnected =
        ref.watch(connectivityStreamProvider).valueOrNull ?? true;

    final claim = _findClaim(listState);

    final serverThread = claim?.thread ?? const <ClaimMessageEntity>[];
    final messages = <ClaimMessageEntity>[...serverThread, ...threadState.localMessages];

    // Auto-scroll quand le nombre de messages augmente (nouvelle réponse / envoi).
    if (messages.length != _lastMessageCount) {
      _lastMessageCount = messages.length;
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
    }

    final isClosed = claim?.status == ClaimStatus.closed;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _ChatAppBar(claim: claim),
      body: Column(
        children: [
          if (!isConnected)
            _OfflineStrip(),
          Expanded(
            child: listState.isLoading && claim == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.secondary800),
                  )
                : messages.isEmpty
                    ? const _EmptyThread()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.pagePaddingH,
                          AppDimensions.sp16,
                          AppDimensions.pagePaddingH,
                          AppDimensions.sp16,
                        ),
                        itemCount: messages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) return const _ThreadIntro();
                          final message = messages[index - 1];
                          final previous =
                              index - 2 >= 0 ? messages[index - 2] : null;
                          final showAgentAvatar = message.isAgent &&
                              (previous == null || !previous.isAgent);
                          return _MessageBubble(
                            message: message,
                            showAgentAvatar: showAgentAvatar,
                          );
                        },
                      ),
          ),
          _Composer(
            controller: _controller,
            isSending: threadState.isSending,
            isClosed: isClosed,
            onChanged: () => setState(() {}),
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar de conversation
// ─────────────────────────────────────────────────────────────────────────────
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.claim});
  final ClaimRequestEntity? claim;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final hasAgent = claim?.agent?.fullName.isNotEmpty ?? false;
    // Dès qu'une réponse serveur existe, un conseiller traite la réclamation :
    // on ne montre plus « en attente d'affectation ».
    final hasResponded = claim?.responses.isNotEmpty ?? false;
    final isActive = hasAgent || hasResponded;
    final agentName = hasAgent ? claim!.agent!.fullName : 'Conseiller ANPEJ';
    final subtitle =
        isActive ? 'Conseiller emploi' : "En attente d'affectation";

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral800),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: AppDimensions.avatarMD,
              height: AppDimensions.avatarMD,
              decoration: BoxDecoration(
                color: isActive ? AppColors.secondary800 : AppColors.secondary100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: hasAgent
                  ? Text(
                      claim!.agent!.initials,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        letterSpacing: 0,
                      ),
                    )
                  : Icon(
                      Icons.support_agent_rounded,
                      size: AppDimensions.iconMD,
                      color: isActive ? AppColors.white : AppColors.secondary600,
                    ),
            ),
            const SizedBox(width: AppDimensions.sp10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    agentName,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.neutral800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutral400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.accent100,
      padding: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: AppDimensions.pagePaddingH,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 14, color: AppColors.accent800),
          const SizedBox(width: 6),
          Text(
            'Hors-ligne · vos messages seront envoyés à la reconnexion',
            style: AppTextStyles.caption.copyWith(color: AppColors.accent900),
          ),
        ],
      ),
    );
  }
}

/// Bandeau d'introduction en haut du fil (contexte + confidentialité douce).
class _ThreadIntro extends StatelessWidget {
  const _ThreadIntro();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sp16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sp12,
            vertical: AppDimensions.sp6,
          ),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(
            'Échange avec un conseiller ANPEJ',
            style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
          ),
        ),
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.forum_outlined,
              size: 40,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: AppDimensions.sp12),
            Text(
              'Démarrez la conversation',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.neutral800),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bulle de message
// ─────────────────────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.showAgentAvatar});

  final ClaimMessageEntity message;
  final bool showAgentAvatar;

  @override
  Widget build(BuildContext context) {
    final isApplicant = message.isApplicant;
    final align = isApplicant ? Alignment.centerRight : Alignment.centerLeft;

    final bubbleColor = isApplicant ? AppColors.secondary800 : AppColors.surface;
    final textColor = isApplicant ? AppColors.white : AppColors.neutral800;
    final borderColor = isApplicant ? Colors.transparent : AppColors.border;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppDimensions.radiusLG),
      topRight: const Radius.circular(AppDimensions.radiusLG),
      bottomLeft: Radius.circular(
        isApplicant ? AppDimensions.radiusLG : AppDimensions.radiusXS,
      ),
      bottomRight: Radius.circular(
        isApplicant ? AppDimensions.radiusXS : AppDimensions.radiusLG,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sp10),
      child: Align(
        alignment: align,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Column(
            crossAxisAlignment:
                isApplicant ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isApplicant) ...[
                    _AgentGutter(visible: showAgentAvatar),
                    const SizedBox(width: AppDimensions.sp8),
                  ],
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sp14,
                        vertical: AppDimensions.sp10,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: radius,
                        border: Border.all(color: borderColor),
                        boxShadow: isApplicant
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Text(
                        message.content,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: textColor,
                          height: 1.45,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isApplicant && message.localId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3, right: 2),
                  child: _DeliveryReceipt(delivery: message.delivery),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gouttière gauche des bulles conseiller : affiche l'avatar seulement sur le
/// premier message d'une séquence, sinon un espace réservé pour l'alignement.
class _AgentGutter extends StatelessWidget {
  const _AgentGutter({required this.visible});
  final bool visible;

  @override
  Widget build(BuildContext context) {
    const size = 26.0;
    if (!visible) return const SizedBox(width: size);
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.secondary100,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.support_agent_rounded,
        size: AppDimensions.iconXS,
        color: AppColors.secondary600,
      ),
    );
  }
}

/// Accusé d'acheminement des messages du demandeur (envoi optimiste).
class _DeliveryReceipt extends StatelessWidget {
  const _DeliveryReceipt({required this.delivery});
  final ClaimDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (delivery) {
      ClaimDelivery.sent => (
          Icons.check_rounded,
          'Envoyé',
          AppColors.neutral400,
        ),
      ClaimDelivery.pending => (
          Icons.schedule_rounded,
          'En attente',
          AppColors.accent800,
        ),
      ClaimDelivery.failed => (
          Icons.error_outline_rounded,
          'Non envoyé',
          AppColors.error,
        ),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: color, fontSize: 10),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Composer
// ─────────────────────────────────────────────────────────────────────────────
class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.isClosed,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final bool isClosed;
  final VoidCallback onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    if (isClosed) {
      return Container(
        width: double.infinity,
        color: AppColors.surface,
        padding: const EdgeInsets.all(AppDimensions.sp16),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded,
                  size: AppDimensions.iconSM, color: AppColors.neutral400),
              const SizedBox(width: AppDimensions.sp8),
              Text(
                'Cette réclamation est clôturée',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final hasText = controller.text.trim().isNotEmpty;
    final canSend = hasText && !isSending;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.sp12,
            AppDimensions.sp8,
            AppDimensions.sp12,
            AppDimensions.sp8,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: AppColors.neutral50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sp18,
                    vertical: AppDimensions.sp14,
                  ),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => onChanged(),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.neutral800,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Écrire un message…',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.neutral300,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sp8),
              _SendButton(
                enabled: canSend,
                isSending: isSending,
                onTap: onSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.enabled,
    required this.isSending,
    required this.onTap,
  });

  final bool enabled;
  final bool isSending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: enabled ? AppColors.secondary800 : AppColors.neutral100,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Center(
            child: isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    size: AppDimensions.iconMD,
                    color: enabled ? AppColors.white : AppColors.neutral400,
                  ),
          ),
        ),
      ),
    );
  }
}

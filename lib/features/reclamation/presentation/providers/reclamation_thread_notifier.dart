// features/reclamation/presentation/providers/reclamation_thread_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reclamation_entity.dart';
import '../../domain/repositories/reclamation_repository.dart';
import '../../providers/reclamation_providers.dart';

/// État d'un fil de réclamation unique (écran chat).
///
/// Ne détient QUE les messages sortants locaux du demandeur (envois optimistes,
/// éventuellement en attente/échec). Le fil « serveur » (message d'ouverture +
/// réponses du conseiller) est lu depuis `reclamationsNotifierProvider` par
/// l'écran, qui concatène les deux pour l'affichage — source de vérité unique
/// pour les données serveur, pas de duplication.
class ThreadState {
  final List<ClaimMessageEntity> localMessages;
  final bool isSending;

  const ThreadState({
    this.localMessages = const [],
    this.isSending = false,
  });

  bool get hasFailed => localMessages.any((m) => m.isFailed);

  ThreadState copyWith({
    List<ClaimMessageEntity>? localMessages,
    bool? isSending,
  }) {
    return ThreadState(
      localMessages: localMessages ?? this.localMessages,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ReclamationThreadNotifier extends StateNotifier<ThreadState> {
  ReclamationThreadNotifier(this._repository, this.claimId)
      : super(const ThreadState()) {
    _loadLocal();
  }

  final ReclamationRepository _repository;
  final int claimId;

  Future<void> _loadLocal() async {
    final messages = await _repository.localMessagesFor(claimId);
    if (!mounted) return;
    state = state.copyWith(localMessages: messages);
  }

  Future<void> refreshLocal() => _loadLocal();

  /// Envoie une réponse du demandeur (optimiste). Le repository consigne le
  /// message localement AVANT toute tentative réseau ; on recharge donc le
  /// miroir local dans tous les cas pour refléter l'accusé résultant.
  Future<ClaimSendOutcome?> send({
    required String message,
    required int applicantId,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return null;

    state = state.copyWith(isSending: true);
    final result = await _repository.sendReply(
      claimId: claimId,
      message: trimmed,
      applicantId: applicantId,
    );
    await _loadLocal();
    if (mounted) state = state.copyWith(isSending: false);

    return result.fold((_) => null, (outcome) => outcome);
  }
}

final reclamationThreadProvider = StateNotifierProvider.family
    .autoDispose<ReclamationThreadNotifier, ThreadState, int>((ref, claimId) {
  final repository = ref.watch(reclamationRepositoryProvider);
  return ReclamationThreadNotifier(repository, claimId);
});

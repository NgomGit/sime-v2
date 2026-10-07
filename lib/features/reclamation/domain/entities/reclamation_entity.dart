// features/reclamation/domain/entities/reclamation_entity.dart

/// Auteur d'un message dans un fil de réclamation.
///
/// L'API ne marque pas explicitement l'expéditeur de chaque `claimResponse`
/// (le champ `agent` est `null` dans les payloads observés). On applique donc
/// une règle documentée et défensive côté modèle (voir `ClaimResponseModel`) :
///   • le `message` d'ouverture de la réclamation → [ClaimAuthor.applicant] ;
///   • chaque `claimResponse` du serveur → [ClaimAuthor.agent] par défaut,
///     sauf marqueur explicite (`byApplicant`/`applicant`) ;
///   • les réponses saisies localement par le demandeur (envoi optimiste,
///     éventuellement mis en file d'attente hors-ligne) → [ClaimAuthor.applicant].
enum ClaimAuthor { applicant, agent }

/// Statut d'acheminement d'un message émis par le demandeur.
///
/// Sert à l'affichage optimiste : un message apparaît immédiatement dans le fil
/// avec un accusé visuel (horloge « en attente », coche « envoyé », ou échec).
enum ClaimDelivery { sent, pending, failed }

/// Statut métier d'une réclamation, dérivé de l'état de la conversation
/// (l'API n'expose pas de champ statut dédié en dehors du booléen `status`).
enum ClaimStatus { open, answered, closed }

/// Utilisateur impliqué dans une réclamation (le demandeur, ou le conseiller).
class ClaimUserEntity {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? avatarUrl;

  const ClaimUserEntity({
    required this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.avatarUrl,
  });

  String get fullName {
    final parts = [firstName, lastName]
        .where((p) => p != null && p.trim().isNotEmpty)
        .cast<String>()
        .toList();
    return parts.isEmpty ? '' : parts.join(' ');
  }

  String get initials {
    final source = fullName.trim();
    if (source.isEmpty) return '?';
    final words = source.split(RegExp(r'\s+'));
    final letters = words.where((w) => w.isNotEmpty).map((w) => w[0]).take(2);
    return letters.join().toUpperCase();
  }
}

/// Un message unitaire du fil : message d'ouverture du demandeur, réponse du
/// conseiller, ou réponse locale du demandeur.
class ClaimMessageEntity {
  /// Identifiant serveur ; `null` pour un message local pas encore acheminé.
  final int? id;

  /// Identifiant local stable (messages optimistes) ; `null` côté serveur.
  final String? localId;

  final String content;
  final ClaimAuthor author;
  final ClaimDelivery delivery;

  /// Horodatage local d'émission (messages optimistes). L'API n'expose pas de
  /// date sur les messages serveur → `null` dans ce cas.
  final DateTime? sentAt;

  /// Conseiller émetteur, si connu (souvent `null` dans les payloads actuels).
  final ClaimUserEntity? agent;

  const ClaimMessageEntity({
    this.id,
    this.localId,
    required this.content,
    required this.author,
    this.delivery = ClaimDelivery.sent,
    this.sentAt,
    this.agent,
  });

  bool get isApplicant => author == ClaimAuthor.applicant;
  bool get isAgent => author == ClaimAuthor.agent;
  bool get isPending => delivery == ClaimDelivery.pending;
  bool get isFailed => delivery == ClaimDelivery.failed;

  ClaimMessageEntity copyWith({
    int? id,
    ClaimDelivery? delivery,
    DateTime? sentAt,
  }) {
    return ClaimMessageEntity(
      id: id ?? this.id,
      localId: localId,
      content: content,
      author: author,
      delivery: delivery ?? this.delivery,
      sentAt: sentAt ?? this.sentAt,
      agent: agent,
    );
  }
}

/// Une réclamation (« claim-request ») du demandeur connecté.
///
/// GET /applicant/api/claim-request-applicants/me
class ClaimRequestEntity {
  final int id;

  /// Champ booléen `status` de l'API (ligne active/archivée), à ne pas
  /// confondre avec [status] (le statut métier dérivé de la conversation).
  final bool active;

  /// Message d'ouverture rédigé par le demandeur.
  final String message;

  final ClaimUserEntity? applicant;
  final int? applicantId;

  final ClaimUserEntity? agent;
  final int? agentId;

  /// Besoin/souscription éventuellement rattaché (`subscription`, souvent null).
  final int? subscriptionId;

  /// Réponses telles que renvoyées par le serveur (`claimResponse`).
  final List<ClaimMessageEntity> responses;

  const ClaimRequestEntity({
    required this.id,
    this.active = true,
    required this.message,
    this.applicant,
    this.applicantId,
    this.agent,
    this.agentId,
    this.subscriptionId,
    this.responses = const [],
  });

  /// Fil « serveur » : message d'ouverture (demandeur) suivi des réponses. Les
  /// envois locaux optimistes du demandeur sont ajoutés côté présentation.
  List<ClaimMessageEntity> get thread {
    return [
      ClaimMessageEntity(
        id: id,
        content: message,
        author: ClaimAuthor.applicant,
        delivery: ClaimDelivery.sent,
      ),
      ...responses,
    ];
  }

  ClaimMessageEntity? get lastMessage {
    final t = thread;
    return t.isEmpty ? null : t.last;
  }

  /// Nombre d'échanges dans le fil (message d'ouverture inclus).
  int get exchangeCount => 1 + responses.length;

  ClaimStatus get status {
    if (!active) return ClaimStatus.closed;
    return responses.isNotEmpty ? ClaimStatus.answered : ClaimStatus.open;
  }

  /// Aperçu court pour la carte de liste : le dernier message du fil.
  String get preview => (lastMessage?.content ?? message).trim();

  /// Titre synthétique dérivé du message d'ouverture (une ligne).
  String get title {
    final trimmed = message.trim();
    return trimmed.isEmpty ? 'Réclamation #$id' : trimmed;
  }
}

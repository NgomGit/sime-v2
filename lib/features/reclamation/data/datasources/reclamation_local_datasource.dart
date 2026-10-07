// features/reclamation/data/datasources/reclamation_local_datasource.dart
import 'package:hive_flutter/hive_flutter.dart';

/// Persistance locale de la fonctionnalité Réclamations.
///
/// Deux rôles distincts :
///   • une FILE D'ATTENTE d'envois (`_outboxBox`) rejouée au retour du réseau —
///     nouvelles réclamations et réponses créées hors-ligne (ou dont l'envoi a
///     échoué malgré la connexion) ;
///   • un MIROIR des messages sortants du demandeur par réclamation
///     (`_messagesBox`). Le serveur ne renvoie pas les réponses du demandeur
///     comme telles (`claimResponse` = réponses du service), donc ce miroir est
///     la source de vérité pour réafficher les messages que le demandeur a
///     envoyés, avec leur accusé (envoyé / en attente / échec).
///
/// Même esprit que `ApplicantLocalDataSourceImpl` (file d'attente Hive +
/// mise à jour optimiste immédiate).
abstract class ReclamationLocalDataSource {
  Future<String> enqueueNewClaim({
    required String message,
    required int applicantId,
  });

  Future<String> enqueueReply({
    required int claimId,
    required String message,
    required int applicantId,
  });

  Future<List<Map<String, dynamic>>> getOutbox();
  Future<void> removeOutbox(String localId);

  Future<void> saveLocalMessage(int claimId, Map<String, dynamic> message);
  Future<void> updateLocalMessageDelivery(
    int claimId,
    String localId,
    String delivery, {
    int? serverId,
  });
  Future<List<Map<String, dynamic>>> getLocalMessages(int claimId);
}

class ReclamationLocalDataSourceImpl implements ReclamationLocalDataSource {
  static const String _outboxBox = 'reclamation_outbox_box';
  static const String _messagesBox = 'reclamation_local_msgs_box';

  Future<Box> _openOutbox() => Hive.openBox(_outboxBox);
  Future<Box> _openMessages() => Hive.openBox(_messagesBox);

  String _newLocalId() => 'loc_${DateTime.now().microsecondsSinceEpoch}';

  @override
  Future<String> enqueueNewClaim({
    required String message,
    required int applicantId,
  }) async {
    final box = await _openOutbox();
    final localId = _newLocalId();
    await box.put(localId, {
      'type': 'new',
      'localId': localId,
      'message': message,
      'applicantId': applicantId,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return localId;
  }

  @override
  Future<String> enqueueReply({
    required int claimId,
    required String message,
    required int applicantId,
  }) async {
    final box = await _openOutbox();
    final localId = _newLocalId();
    await box.put(localId, {
      'type': 'reply',
      'localId': localId,
      'claimId': claimId,
      'message': message,
      'applicantId': applicantId,
      'createdAt': DateTime.now().toIso8601String(),
    });
    return localId;
  }

  @override
  Future<List<Map<String, dynamic>>> getOutbox() async {
    final box = await _openOutbox();
    final items = box.values
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    items.sort((a, b) => (a['createdAt'] ?? '')
        .toString()
        .compareTo((b['createdAt'] ?? '').toString()));
    return items;
  }

  @override
  Future<void> removeOutbox(String localId) async {
    final box = await _openOutbox();
    await box.delete(localId);
  }

  @override
  Future<void> saveLocalMessage(int claimId, Map<String, dynamic> message) async {
    final box = await _openMessages();
    final key = claimId.toString();
    final existing = (box.get(key) as List<dynamic>?) ?? const [];
    final list = existing
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    list.add(message);
    await box.put(key, list);
  }

  @override
  Future<void> updateLocalMessageDelivery(
    int claimId,
    String localId,
    String delivery, {
    int? serverId,
  }) async {
    final box = await _openMessages();
    final key = claimId.toString();
    final existing = (box.get(key) as List<dynamic>?) ?? const [];
    final list = existing
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    for (final m in list) {
      if (m['localId'] == localId) {
        m['delivery'] = delivery;
        if (serverId != null) m['id'] = serverId;
      }
    }
    await box.put(key, list);
  }

  @override
  Future<List<Map<String, dynamic>>> getLocalMessages(int claimId) async {
    final box = await _openMessages();
    final key = claimId.toString();
    final existing = (box.get(key) as List<dynamic>?) ?? const [];
    final list = existing
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    list.sort((a, b) => (a['createdAt'] ?? '')
        .toString()
        .compareTo((b['createdAt'] ?? '').toString()));
    return list;
  }
}

// features/reclamation/data/datasources/reclamation_remote_datasource.dart
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/features/reclamation/data/models/reclamation_model.dart';

/// Source distante des réclamations.
///
/// ⚠️ Chemins préfixés en dur par le nom du micro-service (`/applicant/...`),
/// et non via `ApiConstants` — même convention que `BesoinRemoteDataSourceImpl`
/// et `RdvRemoteDataSourceImpl` (les chemins `/api/...` de `ApiConstants` sont
/// désynchronisés de la réalité du Gateway).
///
/// Endpoints CONFIRMÉS par l'utilisateur :
///   • GET  {{base}}/applicant/api/claim-request-applicants/me
///            ?page&size&pageable=true   → enveloppe {data:[...], totalItems, totalPages}
///   • POST {{base}}/applicant/api/claim-request-applicants/me
///            body {message, applicantId} → crée une nouvelle réclamation.
///
/// Endpoint PRÉSUMÉ (à confirmer côté backend) :
///   • POST {{base}}/applicant/api/claim-request-applicants/me/{claimId}/responses
///            body {message, applicantId} → réponse du demandeur dans un fil
///            existant. Tant qu'il n'est pas confirmé, l'appel peut échouer :
///            la couche présentation affiche alors un accusé « échec » + réessai,
///            et le message reste conservé localement (voir
///            `ReclamationLocalDataSource`).
abstract interface class ReclamationRemoteDataSource {
  Future<List<ClaimRequestModel>> getMyClaims({int page = 1, int size = 50});

  Future<void> createClaim({required String message, required int applicantId});

  Future<void> sendResponse({
    required int claimId,
    required String message,
    required int applicantId,
  });
}

class ReclamationRemoteDataSourceImpl implements ReclamationRemoteDataSource {
  const ReclamationRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  static const String _base = '/applicant/api/claim-request-applicants/me';

  @override
  Future<List<ClaimRequestModel>> getMyClaims({
    int page = 1,
    int size = 50,
  }) async {
    final response = await _client.dio.get(
      _base,
      queryParameters: {'page': page, 'size': size, 'pageable': true},
    );
    final list = response.data['data'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ClaimRequestModel.fromJson)
        .toList();
  }

  @override
  Future<void> createClaim({
    required String message,
    required int applicantId,
  }) async {
    await _client.dio.post(
      _base,
      data: {'message': message, 'applicantId': applicantId},
    );
  }

  @override
  Future<void> sendResponse({
    required int claimId,
    required String message,
    required int applicantId,
  }) async {
    // Endpoint présumé (voir en-tête de fichier) — à confirmer côté backend.
    await _client.dio.post(
      '$_base/$claimId/responses',
      data: {'message': message, 'applicantId': applicantId},
    );
  }
}

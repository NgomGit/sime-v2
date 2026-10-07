// features/besoin/data/datasources/besoin_remote_datasource.dart
import 'package:sime_v2/core/network/api_client.dart';

import '../models/besoin_models.dart';
import '../models/my_subscription_model.dart';

/// Source distante du parcours « Nouveau besoin ».
///
/// ⚠️ Chemins préfixés en dur par le nom du micro-service (`/applicant/...`),
/// et non via `ApiConstants` (qui expose des chemins `/api/...` sans préfixe,
/// désynchronisés de la réalité du Gateway) — même choix que
/// `ApplicantRemoteDataSourceImpl` (`/applicant/api/applicants/me`) et
/// `RdvRemoteDataSourceImpl` (`/rdv/api/rdvs/me`). On s'aligne sur les URL
/// réelles confirmées par l'utilisateur :
///   • GET  {{base}}/applicant/api/type-services/possible-for-me
///   • GET  {{base}}/applicant/api/partner-services/possible-for-me?typeServiceId=…
///   • GET  {{base}}/applicant/api/services/possible-for-me?partnerServiceId=…&typeServiceId=…
///   • POST {{base}}/applicant/api/subscriptions/me
///   • DELETE {{base}}/applicant/api/subscriptions/me/{id}   (204, confirmé)
///   • PUT {{base}}/applicant/api/subscriptions/me/{id}      (⚠️ PRÉSUMÉ —
///     absent de la collection Postman, à confirmer avec le backend)
abstract interface class BesoinRemoteDataSource {
  Future<List<TypeServiceModel>> getPossibleTypeServices();

  Future<List<PartnerServiceModel>> getPossiblePartnerServices(int typeServiceId);

  Future<List<ServiceOfferModel>> getPossibleServices({
    required int partnerServiceId,
    required int typeServiceId,
  });

  /// Crée la souscription (le « besoin ») pour le candidat connecté.
  /// Retourne la ressource créée telle que renvoyée par le serveur.
  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> payload);

  /// Modifie un besoin existant (même corps que la création + `id`).
  /// ⚠️ Endpoint présumé : PUT /applicant/api/subscriptions/me/{id}.
  Future<void> updateSubscription(int id, Map<String, dynamic> payload);

  /// DELETE /applicant/api/subscriptions/me/{id} → 204 No Content.
  Future<void> deleteSubscription(int id);

  /// GET /applicant/api/subscriptions/me?pageable=false
  /// Liste des besoins déjà sollicités par le candidat connecté.
  Future<List<MySubscriptionModel>> getMySubscriptions();
}

class BesoinRemoteDataSourceImpl implements BesoinRemoteDataSource {
  const BesoinRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<TypeServiceModel>> getPossibleTypeServices() async {
    final response =
        await _client.dio.get('/applicant/api/type-services/possible-for-me');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => TypeServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PartnerServiceModel>> getPossiblePartnerServices(
      int typeServiceId) async {
    final response = await _client.dio.get(
      '/applicant/api/partner-services/possible-for-me',
      queryParameters: {'typeServiceId': typeServiceId},
    );
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => PartnerServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ServiceOfferModel>> getPossibleServices({
    required int partnerServiceId,
    required int typeServiceId,
  }) async {
    final response = await _client.dio.get(
      '/applicant/api/services/possible-for-me',
      queryParameters: {
        'partnerServiceId': partnerServiceId,
        'typeServiceId': typeServiceId,
      },
    );
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => ServiceOfferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> createSubscription(
      Map<String, dynamic> payload) async {
    final response = await _client.dio
        .post('/applicant/api/subscriptions/me', data: payload);
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return {'data': data};
  }

  @override
  Future<void> updateSubscription(int id, Map<String, dynamic> payload) async {
    await _client.dio.put(
      '/applicant/api/subscriptions/me/$id',
      data: {'id': id, ...payload},
    );
  }

  @override
  Future<void> deleteSubscription(int id) async {
    await _client.dio.delete('/applicant/api/subscriptions/me/$id');
  }

  @override
  Future<List<MySubscriptionModel>> getMySubscriptions() async {
    final response = await _client.dio.get(
      '/applicant/api/subscriptions/me',
      queryParameters: {'pageable': false},
    );
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => MySubscriptionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

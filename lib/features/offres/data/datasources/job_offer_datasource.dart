// features/offres/data/datasources/job_offer_datasource.dart
import 'package:sime_v2/core/network/api_client.dart';

import '../models/job_application_model.dart';
import '../models/job_offer_model.dart';

/// Source distante des offres d'emploi.
///
/// ⚠️ Chemins préfixés en dur par le nom du micro-service (`/applicant/...`),
/// et non via `ApiConstants` (dont les chemins `/api/...` sont désynchronisés
/// du Gateway réel) — même choix que `BesoinRemoteDataSourceImpl` et
/// `ApplicantRemoteDataSourceImpl`. URL réelles :
///   • GET {{base}}/applicant/api/job-offers/available?page=&size=&pageable=true
///   • GET {{base}}/applicant/api/job-offers/{id}/available
abstract interface class JobOfferRemoteDataSource {
  Future<List<JobOfferModel>> getAvailableOffers({int page, int size});

  Future<JobOfferModel> getOfferDetail(int id);

  /// POST {{base}}/applicant/api/job-offer-applicants/me — postuler à une offre.
  /// Corps : `{"applicant":{"id":..},"jobOffer":{"id":..}}`.
  Future<JobApplicationModel> applyToOffer({
    required int applicantId,
    required int jobOfferId,
  });
}

class JobOfferRemoteDataSourceImpl implements JobOfferRemoteDataSource {
  const JobOfferRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<JobOfferModel>> getAvailableOffers({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _client.dio.get(
      '/applicant/api/job-offers/available',
      queryParameters: {'page': page, 'size': size, 'pageable': true},
    );
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => JobOfferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<JobOfferModel> getOfferDetail(int id) async {
    final response =
        await _client.dio.get('/applicant/api/job-offers/$id/available');
    final data = response.data;
    // Le détail renvoie l'objet directement ; certains environnements
    // l'enveloppent tout de même dans `{ data: {...} }` — on gère les deux.
    final map = data is Map<String, dynamic> && data['data'] is Map
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return JobOfferModel.fromJson(map);
  }

  @override
  Future<JobApplicationModel> applyToOffer({
    required int applicantId,
    required int jobOfferId,
  }) async {
    final response = await _client.dio.post(
      '/applicant/api/job-offer-applicants/me',
      data: {
        'applicant': {'id': applicantId},
        'jobOffer': {'id': jobOfferId},
      },
    );
    final data = response.data;
    final map = data is Map<String, dynamic> && data['data'] is Map
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return JobApplicationModel.fromJson(map);
  }
}

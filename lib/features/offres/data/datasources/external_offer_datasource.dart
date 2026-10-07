// features/offres/data/datasources/external_offer_datasource.dart
import 'package:sime_v2/core/network/api_client.dart';

import '../models/job_offer_model.dart';

/// Source distante des offres d'emploi EXTERNES (mise en relation).
///
/// GET {{base}}/applicant/api/job-linking-offer-applicants/me?page=&size=&pageable=true
///
/// ⚠️ Forme exacte des items NON confirmée : endpoint « -applicants/me », donc
/// chaque item est vraisemblablement un enregistrement de candidature qui
/// ENVELOPPE l'offre externe. On extrait l'offre de façon défensive
/// (`jobLinkingOffer` / `jobOffer` / `offer` / item lui-même) puis on la parse
/// avec [JobOfferModel] (structure d'offre compatible). `rawJson` est conservé
/// pour un cache fidèle en attendant confirmation du payload réel.
abstract interface class ExternalOfferRemoteDataSource {
  Future<List<JobOfferModel>> getAvailableOffers({int page, int size});
}

class ExternalOfferRemoteDataSourceImpl
    implements ExternalOfferRemoteDataSource {
  const ExternalOfferRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<JobOfferModel>> getAvailableOffers({
    int page = 1,
    int size = 10,
  }) async {
    final response = await _client.dio.get(
      '/applicant/api/job-linking-offer-applicants/me',
      queryParameters: {'page': page, 'size': size, 'pageable': true},
    );
    final data = response.data;
    final list = (data is Map<String, dynamic>
            ? data['data'] as List<dynamic>?
            : data as List<dynamic>?) ??
        const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(_extractOffer)
        .map(JobOfferModel.fromJson)
        .toList();
  }

  /// Extrait l'offre externe imbriquée dans l'enregistrement de candidature.
  Map<String, dynamic> _extractOffer(Map<String, dynamic> item) {
    for (final key in const ['jobLinkingOffer', 'jobOffer', 'offer']) {
      final nested = item[key];
      if (nested is Map<String, dynamic>) return nested;
    }
    return item; // repli : l'item est déjà l'offre.
  }
}

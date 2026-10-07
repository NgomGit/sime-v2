// features/offres/data/datasources/training_offer_datasource.dart
import 'package:sime_v2/core/network/api_client.dart';

import '../models/training_offer_model.dart';

/// Source distante des offres de formation.
///   • GET {{base}}/applicant/api/training-offers/available?page=&size=&pageable=true
///   • GET {{base}}/applicant/api/training-offers/{id}/available
abstract interface class TrainingOfferRemoteDataSource {
  Future<List<TrainingOfferModel>> getAvailableOffers({int page, int size});

  Future<TrainingOfferModel> getOfferDetail(int id);
}

class TrainingOfferRemoteDataSourceImpl
    implements TrainingOfferRemoteDataSource {
  const TrainingOfferRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<TrainingOfferModel>> getAvailableOffers({
    int page = 1,
    int size = 20,
  }) async {
    final response = await _client.dio.get(
      '/applicant/api/training-offers/available',
      queryParameters: {'page': page, 'size': size, 'pageable': true},
    );
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => TrainingOfferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TrainingOfferModel> getOfferDetail(int id) async {
    final response =
        await _client.dio.get('/applicant/api/training-offers/$id/available');
    final data = response.data;
    final map = data is Map<String, dynamic> && data['data'] is Map
        ? data['data'] as Map<String, dynamic>
        : data as Map<String, dynamic>;
    return TrainingOfferModel.fromJson(map);
  }
}

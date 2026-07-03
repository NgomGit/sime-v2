import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/api_constants.dart';
import 'package:sime_v2/features/offres/data/models/job_offer_model.dart';

abstract interface class JobOfferRemoteDataSource {
  Future<List<JobOfferModel>> getAvailableOffers();
}
 
class JobOfferRemoteDataSourceImpl implements JobOfferRemoteDataSource {
  const JobOfferRemoteDataSourceImpl(this._client);
  final ApiClient _client;
 
  @override
  Future<List<JobOfferModel>> getAvailableOffers() async {
    final r = await _client.dio.get(ApiConstants.jobOffersAvailable);
    return (r.data as List<dynamic>)
        .map((e) => JobOfferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/api_constants.dart';
import 'package:sime_v2/features/offres/data/models/anpej_service_model.dart';

abstract interface class AnpejServiceRemoteDataSource {
  Future<List<AnpejServiceModel>> getAllServices();
  Future<List<AnpejServiceModel>> getServicesForMe();
}
 
class AnpejServiceRemoteDataSourceImpl
    implements AnpejServiceRemoteDataSource {
  const AnpejServiceRemoteDataSourceImpl(this._client);
  final ApiClient _client;
 
  @override
  Future<List<AnpejServiceModel>> getAllServices() async {
    final r = await _client.dio.get(ApiConstants.services);
    return (r.data as List<dynamic>)
        .map((e) => AnpejServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
 
  @override
  Future<List<AnpejServiceModel>> getServicesForMe() async {
    final r = await _client.dio.get(ApiConstants.servicesForMe);
    return (r.data as List<dynamic>)
        .map((e) => AnpejServiceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
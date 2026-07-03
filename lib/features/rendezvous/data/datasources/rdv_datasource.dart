import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/api_constants.dart';
import 'package:sime_v2/features/rendezvous/data/models/rdv_model.dart';

abstract interface class RdvRemoteDataSource {
  Future<List<RdvModel>> getMyRdvs();
  Future<RdvModel> createRdv(Map<String, dynamic> body);
  Future<RdvModel> autoBookRdv();
  Future<RdvModel> updateRdvStatus(int id, Map<String, dynamic> body);
}
 
class RdvRemoteDataSourceImpl implements RdvRemoteDataSource {
  const RdvRemoteDataSourceImpl(this._client);
  final ApiClient _client;
 
  @override
  Future<List<RdvModel>> getMyRdvs() async {
    final r = await _client.dio.get(ApiConstants.rdvsMe);
    return (r.data as List<dynamic>)
        .map((e) => RdvModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
 
  @override
  Future<RdvModel> createRdv(Map<String, dynamic> body) async {
    final r = await _client.dio.post(ApiConstants.rdvs, data: body);
    return RdvModel.fromJson(r.data as Map<String, dynamic>);
  }
 
  @override
  Future<RdvModel> autoBookRdv() async {
    final r = await _client.dio.get(ApiConstants.rdvAutoBook);
    return RdvModel.fromJson(r.data as Map<String, dynamic>);
  }
 
  @override
  Future<RdvModel> updateRdvStatus(int id, Map<String, dynamic> body) async {
    final r = await _client.dio.patch(ApiConstants.rdvById(id), data: body);
    return RdvModel.fromJson(r.data as Map<String, dynamic>);
  }
}
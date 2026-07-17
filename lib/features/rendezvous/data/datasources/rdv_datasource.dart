// features/rendezvous/data/datasources/rdv_datasource.dart
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/features/rendezvous/data/models/rdv_model.dart';

abstract interface class RdvRemoteDataSource {
  /// GET /rdv/api/rdvs/me
  Future<List<RdvModel>> getMyRdvs();
}

class RdvRemoteDataSourceImpl implements RdvRemoteDataSource {
  const RdvRemoteDataSourceImpl(this._client);
  final ApiClient _client;

  @override
  Future<List<RdvModel>> getMyRdvs() async {
    // ⚠️ Chemin en dur (préfixé par le nom du micro-service, `/rdv/...`) et
    // non `ApiConstants.rdvsMe` (`/api/rdvs/me`, sans préfixe) : ce dernier
    // s'est révélé désynchronisé de la réalité du Gateway sur les autres
    // features (voir `applicant_remote_datasource.dart` qui appelle
    // `/applicant/api/applicants/me` en dur pour la même raison). On
    // s'aligne ici sur le payload réel confirmé par l'utilisateur :
    // GET {{base_url}}/rdv/api/rdvs/me.
    final response = await _client.dio.get('/rdv/api/rdvs/me');
    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => RdvModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

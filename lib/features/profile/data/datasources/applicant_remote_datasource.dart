// features/profile/data/datasources/applicant_remote_datasource.dart
import 'package:flutter/material.dart';
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/utils/json_sanitizer.dart';
import 'package:sime_v2/features/profile/data/models/applicant_model.dart';

abstract class ApplicantRemoteDataSource {
  Future<Map<String, dynamic>> getApplicantProfile();
  Future<ApplicantModel> updateApplicantProfile(
      int id, Map<String, dynamic> fieldsToUpdate);
}

class ApplicantRemoteDataSourceImpl implements ApplicantRemoteDataSource {
  ApplicantRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<Map<String, dynamic>> getApplicantProfile() async {
    final response = await _apiClient.dio.get('/applicant/api/applicants/me');
    final list = response.data['data'] as List<dynamic>;
    if (list.isNotEmpty) {
      return list.first as Map<String, dynamic>;
    }
    throw Exception("Aucun profil trouvé");
  }

  @override
  Future<ApplicantModel> updateApplicantProfile(
      int id, Map<String, dynamic> fieldsToUpdate) async {
    // 🛡️ Nettoyage défensif : garantit que seuls des types JSON-safe
    // (int, String, bool, double, null, List/Map de ceux-ci) quittent cette
    // fonction — jamais d'objet Dart brut, qui casserait à la fois la
    // sérialisation JSON de Dio et le cache Hive de la queue offline.
    // Voir core/utils/json_sanitizer.dart — la même fonction est réutilisée
    // par ApplicantRepositoryImpl avant l'écriture en cache hors-ligne, pour
    // que les deux chemins (réseau et Hive) restent protégés de façon
    // identique.
    final sanitizedFields = sanitizeForTransport(
      fieldsToUpdate,
      onUnsupported: (message) => debugPrint('⚠️ $message'),
    );

    debugPrint('!!!!! Updating applicant profile with ID: $id and fields: $sanitizedFields');

    final response = await _apiClient.dio
        .patch('/applicant/api/applicants/me/$id', data: sanitizedFields);

    return ApplicantModel.fromJson(response.data);
  }
}

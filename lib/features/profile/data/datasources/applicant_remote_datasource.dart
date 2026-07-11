// features/profile/data/datasources/applicant_remote_datasource.dart
import 'package:flutter/material.dart';
import 'package:sime_v2/core/network/api_client.dart';
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
    final sanitizedFields = _sanitizeForTransport(fieldsToUpdate);

    debugPrint('!!!!! Updating applicant profile with ID: $id and fields: $sanitizedFields');

    final response = await _apiClient.dio
        .patch('/applicant/api/applicants/me/$id', data: sanitizedFields);

    return ApplicantModel.fromJson(response.data);
  }

  /// Convertit récursivement une map en une version strictement JSON-safe.
  /// - Les objets exposant un champ `id` (ex: ReferenceEntity) sont réduits à leur id.
  /// - Les objets exposant `toJson()` sont convertis via cette méthode.
  /// - Tout le reste (int, String, bool, double, null) passe tel quel.
  /// - Toute entrée qui ne peut pas être rendue safe est retirée avec un warning,
  ///   plutôt que de faire planter silencieusement le cache ou l'appel réseau.
  Map<String, dynamic> _sanitizeForTransport(Map<String, dynamic> input) {
    final result = <String, dynamic>{};

    input.forEach((key, value) {
      final sanitized = _sanitizeValue(value);
      if (sanitized is _Unsupported) {
        debugPrint(
          '⚠️ Champ "$key" retiré du payload : type non sérialisable (${value.runtimeType}). '
          'Vérifie où ce champ est construit — il ne devrait contenir qu\'un id, pas l\'entité complète.',
        );
        return;
      }
      result[key] = sanitized;
    });

    return result;
  }

  dynamic _sanitizeValue(dynamic value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is List) {
      return value.map(_sanitizeValue).toList();
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _sanitizeValue(v)));
    }

    // Tente dynamiquement les cas les plus courants dans ce projet :
    // objets avec toJson(), ou objets de référence exposant un `id`.
    try {
      final dynamic dyn = value;
      // ReferenceEntity et objets similaires exposent généralement .id
      final id = dyn.id;
      if (id is int || id is String) return id;
    } catch (_) {
      // pas de getter `id` disponible, on continue
    }

    try {
      final dynamic dyn = value;
      final json = dyn.toJson();
      if (json is Map) return _sanitizeValue(json);
    } catch (_) {
      // pas de toJson() disponible non plus
    }

    return const _Unsupported();
  }
}

class _Unsupported {
  const _Unsupported();
}
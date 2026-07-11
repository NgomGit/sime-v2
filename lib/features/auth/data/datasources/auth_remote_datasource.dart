// features/auth/data/datasources/auth_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/utils/file_utils.dart';
import 'package:sime_v2/features/auth/data/models/auth_response_model.dart';
import 'package:sime_v2/features/auth/data/models/register_user_model.dart';
import 'package:sime_v2/features/auth/domain/entities/registration_entity.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<void> registerUserAccount(RegistrationEntity entity) async {
    await _apiClient.dio.post(
      '/auth/api/auth/register',
      data: RegisterUserDto.toJson(entity),
    );
  }

  Future<void> registerApplicantProfile(RegistrationEntity entity) async {
    String base64StringRecto = "";
    String base64StringVerso = "";
    List<String> files = [];

    if (entity.documentPathRecto != null) {
      base64StringRecto = await fileToBase64(entity.documentPathRecto!);
      files.add(base64StringRecto);
    }

    if (entity.documentType == 'CNI' && entity.documentPathVerso != null) {
      base64StringVerso = await fileToBase64(entity.documentPathVerso!);
      files.add(base64StringVerso);
    }

    await _apiClient.dio.post(
      '/applicant/api/applicants/register',
      data: RegisterApplicantDto.toJson(entity: entity, files: files),
    );
  }

  Future<AuthResponseModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/api/auth/login', // Ajuste la route si nécessaire
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Échec de la connexion');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Erreur réseau ou serveur';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> updateAuthUser(Map<String, dynamic> payload) async {
    final response = await _apiClient.dio.put('/auth/api/auth/me', data: payload);
    return response.data as Map<String, dynamic>;
  }
}
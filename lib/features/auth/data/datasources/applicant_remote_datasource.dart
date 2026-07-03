
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/api_constants.dart';
import 'package:sime_v2/features/auth/data/models/applicant_model.dart';

abstract interface class ApplicantRemoteDataSource {
  Future<ApplicantModel> getMyProfile();
  Future<ApplicantModel> registerApplicant(Map<String, dynamic> body);
  Future<ApplicantModel> updateMyProfile(Map<String, dynamic> body);
}
 
class ApplicantRemoteDataSourceImpl implements ApplicantRemoteDataSource {
  const ApplicantRemoteDataSourceImpl(this._client);
  final ApiClient _client;
 
  @override
  Future<ApplicantModel> getMyProfile() async {
    final r = await _client.dio.get(ApiConstants.applicantMe);
    return ApplicantModel.fromJson(r.data as Map<String, dynamic>);
  }
 
  @override
  Future<ApplicantModel> registerApplicant(Map<String, dynamic> body) async {
    final r = await _client.dio.post(ApiConstants.applicantRegister, data: body);
    return ApplicantModel.fromJson(r.data as Map<String, dynamic>);
  }
 
  @override
  Future<ApplicantModel> updateMyProfile(Map<String, dynamic> body) async {
    final r = await _client.dio.put(ApiConstants.applicantMe, data: body);
    return ApplicantModel.fromJson(r.data as Map<String, dynamic>);
  }
}
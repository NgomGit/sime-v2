
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/api_constants.dart';
import 'package:sime_v2/features/offres/data/models/referential_model.dart';

abstract interface class ReferentielRemoteDataSource {
  Future<List<CountryModel>> getCountries();
  Future<List<RegionModel>> getRegions();
  Future<List<DepartmentModel>> getDepartments(int regionId);
  Future<List<MunicipalityModel>> getMunicipalities(int departmentId);
  Future<List<EducationLevelModel>> getEducationLevels();
  Future<List<DegreeModel>> getDegrees();
}
 
class ReferentielRemoteDataSourceImpl implements ReferentielRemoteDataSource {
  const ReferentielRemoteDataSourceImpl(this._client);
  final ApiClient _client;
 
  List<T> _mapList<T>(dynamic data, T Function(Map<String, dynamic>) f) =>
      (data as List<dynamic>)
          .map((e) => f(e as Map<String, dynamic>))
          .toList();
 
  @override
  Future<List<CountryModel>> getCountries() async {
    final r = await _client.dio.get(ApiConstants.countries);
    return _mapList(r.data, CountryModel.fromJson);
  }
 
  @override
  Future<List<RegionModel>> getRegions() async {
    final r = await _client.dio.get(ApiConstants.regions);
    return _mapList(r.data, RegionModel.fromJson);
  }
 
  @override
  Future<List<DepartmentModel>> getDepartments(int regionId) async {
    final r = await _client.dio.get(
      ApiConstants.departments,
      queryParameters: {'regionId': regionId},
    );
    return _mapList(r.data, DepartmentModel.fromJson);
  }
 
  @override
  Future<List<MunicipalityModel>> getMunicipalities(int departmentId) async {
    final r = await _client.dio.get(
      ApiConstants.municipalities,
      queryParameters: {'departmentId': departmentId},
    );
    return _mapList(r.data, MunicipalityModel.fromJson);
  }
 
  @override
  Future<List<EducationLevelModel>> getEducationLevels() async {
    final r = await _client.dio.get(ApiConstants.educationLevels);
    return _mapList(r.data, EducationLevelModel.fromJson);
  }
 
  @override
  Future<List<DegreeModel>> getDegrees() async {
    final r = await _client.dio.get(ApiConstants.degrees);
    return _mapList(r.data, DegreeModel.fromJson);
  }
}
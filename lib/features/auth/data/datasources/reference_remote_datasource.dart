import '../../../../core/network/api_client.dart';
import '../models/reference_model.dart';

class ReferenceRemoteDataSource {
  final ApiClient _apiClient;

  ReferenceRemoteDataSource(this._apiClient);

  /// Récupère la liste globale des pays
  Future<List<ReferenceModel>> getReferenceList(String name) async {
    final response = await _apiClient.dio.get('/param/api/$name');
    // Extraction via ['data']
    return _parseList(response.data['data']);
  }

  /// Récupère la liste globale des pays
  Future<List<CountryModel>> getCountries() async {
    final response = await _apiClient.dio.get('/param/api/countries');
    // Extraction via ['data']
    return _parseCountryList(response.data['data']);
  }

  /// Récupère la liste des régions
  Future<List<RegionModel>> getRegions() async {
    final response = await _apiClient.dio.get('/param/api/regions');
    // Extraction via ['data']
    return _parseRegionList(response.data['data']);
  }

  /// Récupère la liste des nationalités éligibles
  Future<List<CountryModel>> getNationalities() async {
    final response = await _apiClient.dio.get('/param/api/nationalities');
    // Extraction via ['data']
    return _parseCountryList(response.data['data']);
  }

  /// Récupère les départements filtrés par l'ID de la région
  Future<List<DepartmentModel>> getDepartments(int regionId) async {
    final response = await _apiClient.dio.get(
      '/param/api/departments',
      queryParameters: {'regionId': regionId},
    );
    // Extraction via ['data']
    return _parseDepartmentList(response.data['data']);
  }

  /// Récupère les communes filtrées par l'ID du département
  Future<List<MunicipalityModel>> getMunicipalities(int departmentId) async {
    final response = await _apiClient.dio.get(
      '/param/api/municipalities',
      queryParameters: {'departmentId': departmentId},
    );
    // Extraction via ['data']
    return _parseMunicipalityList(response.data['data']);
  }

  Future<List<ReferenceModel>> getEducationLevels() async {
    final response = await _apiClient.dio.get('/param/api/education-levels'); // Ajuste l'URL du backend
    return _parseList(response.data['data']);
  }

  Future<List<ReferenceModel>> getFieldsOfStudy() async {
    final response = await _apiClient.dio.get('/param/api/field-activities'); // Ajuste l'URL du backend
    return _parseList(response.data['data']);
  }

  /// Helper générique pour parser les listes de données retournées par le Gateway
  List<ReferenceModel> _parseList(dynamic dataList) {
    if (dataList is List) {
      return dataList.map((json) => ReferenceModel.fromJson(json)).toList();
    }
    return [];
  }

  List<CountryModel> _parseCountryList(dynamic dataList) {
    if (dataList is List) {
      return dataList.map((json) => CountryModel.fromJson(json)).toList();
    }
    return [];
  }

  List<RegionModel> _parseRegionList(dynamic dataList) {
    if (dataList is List) {
      return dataList.map((json) => RegionModel.fromJson(json)).toList();
    }
    return [];
  }

  List<DepartmentModel> _parseDepartmentList(dynamic dataList) {
    if (dataList is List) {
      return dataList.map((json) => DepartmentModel.fromJson(json)).toList();
    }
    return [];
  }

List<MunicipalityModel> _parseMunicipalityList(dynamic dataList) {
    if (dataList is List) {
      return dataList.map((json) => MunicipalityModel.fromJson(json)).toList();
    }
    return [];
  }

  
}
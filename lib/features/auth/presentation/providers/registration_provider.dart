import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/error/api_exception.dart';
import 'package:sime_v2/features/auth/data/datasources/reference_remote_datasource.dart';
import 'package:sime_v2/features/auth/domain/entities/registration_entity.dart';
import 'package:sime_v2/features/auth/domain/usecases/register_demandeur.dart';
import 'package:sime_v2/features/auth/providers/auth_providers.dart';


final registrationNotifierProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationEntity>((ref) {
  return RegistrationNotifier(
    ref.read(registerDemandeurUseCaseProvider),
    ref.read(referenceDataSourceProvider), // Injection du DataSource
  );
});

class RegistrationNotifier extends StateNotifier<RegistrationEntity> {
  final RegisterDemandeurUseCase _registerUseCase;
  final ReferenceRemoteDataSource _referenceDataSource;

  RegistrationNotifier(this._registerUseCase, this._referenceDataSource)
      : super(const RegistrationEntity()) {
    // Amorcer automatiquement le chargement des référentiels à l'initialisation du formulaire
    _loadInitialReferences();
  }

  /// Charge les données initiales de référentiels (Pays, Régions et Nationalités)
  Future<void> _loadInitialReferences() async {
    try {
      final countries = await _referenceDataSource.getCountries();
      final nationalities = await _referenceDataSource.getNationalities();
      final regions = await _referenceDataSource.getRegions();

      state = state.copyWith(
        countries: countries,
        nationalities: nationalities,
        regions: regions,
      );
      
      // Si une région par défaut est configurée à l'initialisation, on charge ses départements
      if (state.residRegionId != 0) {
        onRegionChanged(state.residRegionId);
      }
    } catch (_) {
      // Les erreurs silencieuses évitent de bloquer l'UI lors du chargement des paramètres
    }
  }

  /// Gestion de la cascade lors du changement de Région
  Future<void> onRegionChanged(int regionId) async {
    state = state.copyWith(
      residRegionId: regionId,
      residDepartmentId: 0,   // Réinitialise la sélection précédente
      residMunicipalityId: 0, // Réinitialise la sélection précédente
      departments: [],        // Vide la liste UI
      municipalities: [],     // Vide la liste UI
    );

    try {
      final departments = await _referenceDataSource.getDepartments(regionId);
      state = state.copyWith(departments: departments);
      
      // Optionnel : Si un département par défaut est disponible ou si la liste contient un seul élément
      if (departments.isNotEmpty && state.residDepartmentId != 0) {
        onDepartmentChanged(state.residDepartmentId);
      }
    } catch (_) {}
  }

  /// Gestion de la cascade lors du changement de Département
  Future<void> onDepartmentChanged(int departmentId) async {
    state = state.copyWith(
      residDepartmentId: departmentId,
      residMunicipalityId: 0, // Réinitialise la commune précédente
      municipalities: [],     // Vide la liste UI
    );

    try {
      final municipalities = await _referenceDataSource.getMunicipalities(departmentId);
      state = state.copyWith(municipalities: municipalities);
    } catch (_) {}
  }

  void updateRecto(String? path) => state = state.copyWith(documentPathRecto: path);
void updateVerso(String? path) => state = state.copyWith(documentPathVerso: path);

// Callback quand le type de document change pour nettoyer les fichiers précédents
void changeDocumentType(String type) {
  state = state.copyWith(
    documentType: type,
    documentPathRecto: null,
    documentPathVerso: null,
  );
}

  /// Mise à jour classique des autres champs du formulaire
  void updateField({
    String? cni,
    String? sex,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? username,
    String? documentType,
    String? documentPath,
    String? password,
    String? placeBirth,
    String? dateBirth,
    int? residCountryId,
    int? residRegionId,
    int? residDepartmentId,
    int? residMunicipalityId,
    String? residAddress,
    int? nationalityId,
  }) {
    state = state.copyWith(
      cni: cni ?? state.cni,
      sex: sex ?? state.sex,
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      phone: phone ?? state.phone,
      email: email ?? state.email,
      username: username ?? state.username,
      password: password ?? state.password,
      placeBirth: placeBirth ?? state.placeBirth,
      dateBirth: dateBirth ?? state.dateBirth,
      residCountryId: residCountryId ?? state.residCountryId,
      residRegionId: residRegionId ?? state.residRegionId,
      residDepartmentId: residDepartmentId ?? state.residDepartmentId,
      residMunicipalityId: residMunicipalityId ?? state.residMunicipalityId,
      residAddress: residAddress ?? state.residAddress,
      nationalityId: nationalityId ?? state.nationalityId,
      documentType: documentType ?? state.documentType,
      documentPath: documentPath ?? state.documentPath,
    );
  }

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void prevStep() => state = state.copyWith(currentStep: state.currentStep - 1);
  void resetSteps() => state = state.copyWith(currentStep: 1, isSuccess: false, errorMessage: null);
  /// Soumission finale de l'inscription (Étape 3 / Étape finale)
  Future<void> submit() async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _registerUseCase(state);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } on DioException catch (e) {
      final apiException = ApiException.fromDioException(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: apiException.message, 
      );
    }
  }
}
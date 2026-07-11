// features/profile/presentation/states/profile_references_state.dart

import 'package:sime_v2/features/auth/data/models/reference_model.dart';
import 'package:sime_v2/features/auth/domain/entities/reference_entity.dart';
// features/profile/presentation/providers/profile_references_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/auth/data/datasources/reference_remote_datasource.dart';
import 'package:sime_v2/features/auth/providers/auth_providers.dart'; // Où se trouve ton referenceDataSourceProvider

class ProfileReferencesState {
  final List<CountryEntity> countries;
  final List<ReferenceEntity> nationalities;
  final List<RegionEntity> regions;
  final List<DepartmentEntity> departments;
  final List<MunicipalityEntity> municipalities;

  // Référentiels professionnels
  final List<ReferenceEntity> educationLevels;
  final List<ReferenceEntity> fieldsOfStudy;

  final bool isLoading;
  final String? errorMessage;

  const ProfileReferencesState({
    this.countries = const [],
    this.nationalities = const [],
    this.regions = const [],
    this.departments = const [],
    this.municipalities = const [],
    this.educationLevels = const [],
    this.fieldsOfStudy = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ProfileReferencesState copyWith({
    List<CountryEntity>? countries,
    List<ReferenceEntity>? nationalities,
    List<RegionEntity>? regions,
    List<DepartmentEntity>? departments,
    List<MunicipalityEntity>? municipalities,
    List<ReferenceEntity>? educationLevels,
    List<ReferenceEntity>? fieldsOfStudy,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileReferencesState(
      countries: countries ?? this.countries,
      nationalities: nationalities ?? this.nationalities,
      regions: regions ?? this.regions,
      departments: departments ?? this.departments,
      municipalities: municipalities ?? this.municipalities,
      educationLevels: educationLevels ?? this.educationLevels,
      fieldsOfStudy: fieldsOfStudy ?? this.fieldsOfStudy,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final profileReferencesNotifierProvider =
    StateNotifierProvider<ProfileReferencesNotifier, ProfileReferencesState>(
        (ref) {
  return ProfileReferencesNotifier(
    ref.read(referenceDataSourceProvider),
  );
});

class ProfileReferencesNotifier extends StateNotifier<ProfileReferencesState> {
  final ReferenceRemoteDataSource _referenceDataSource;

  ProfileReferencesNotifier(this._referenceDataSource)
      : super(const ProfileReferencesState()) {
    // Charge automatiquement l'ensemble des catalogues à l'instanciation
    loadAllReferences();
  }

  /// Chargement global initial en parallèle de tous les référentiels fondamentaux
  Future<void> loadAllReferences() async {
  state = state.copyWith(isLoading: true, errorMessage: null);
  try {
    // 1. On lance les requêtes en parallèle
    final results = await Future.wait([
      _referenceDataSource.getCountries().catchError((e) {
        print("🚨 Erreur getCountries: $e");
        return <CountryModel>[];
      }),
      _referenceDataSource.getNationalities().catchError((e) {
        print("🚨 Erreur getNationalities: $e");
        return <CountryModel>[];
      }),
      _referenceDataSource.getRegions().catchError((e) {
        print("🚨 Erreur getRegions: $e");
        return <RegionModel>[];
      }),
      _referenceDataSource.getEducationLevels().catchError((e) {
        print("🚨 Erreur getEducationLevels: $e");
        return <ReferenceModel>[];
      }),
      _referenceDataSource.getFieldsOfStudy().catchError((e) {
        print("🚨 Erreur getFieldsOfStudy: $e");
        return <ReferenceModel>[];
      }),
    ]);

    // 2. Mappings et conversions sécurisés pour le Domain Layer
    
    // Conversion de List<CountryModel> en List<CountryEntity>
    final List<CountryEntity> mappedCountries = (results[0] as List<CountryModel>)
        .map((model) => CountryEntity(id: model.id, name: model.name, code: model.code, alpha2: model.alpha2))
        .toList();

    // 💥 C'est ici que ça plantait : on convertit le CountryModel en ReferenceEntity
    final List<ReferenceEntity> mappedNationalities = (results[1] as List<CountryModel>)
        .map((model) => ReferenceEntity(id: model.id, name: model.name))
        .toList();

    // Conversion de List<RegionModel> en List<RegionEntity>
    final List<RegionEntity> mappedRegions = (results[2] as List<RegionModel>)
        .map((model) => RegionEntity(id: model.id, name: model.name, code: model.code, status: model.status))
        .toList();

    // Conversion de List<ReferenceModel> en List<ReferenceEntity>
    final List<ReferenceEntity> mappedLevels = (results[3] as List<ReferenceModel>)
        .map((model) => ReferenceEntity(id: model.id, name: model.name))
        .toList();

    // Conversion de List<ReferenceModel> en List<ReferenceEntity>
    final List<ReferenceEntity> mappedFields = (results[4] as List<ReferenceModel>)
        .map((model) => ReferenceEntity(id: model.id, name: model.name))
        .toList();

    // 3. Mise à jour de l'état avec les types parfaits
    state = state.copyWith(
      isLoading: false,
      countries: mappedCountries,
      nationalities: mappedNationalities,
      regions: mappedRegions,
      educationLevels: mappedLevels,
      fieldsOfStudy: mappedFields,
    );
    
    print("✅ Tous les référentiels ont été chargés et convertis avec succès !");
  } catch (e, stackTrace) {
    print("🚨 Crash lors de l'assignement des états: $e");
    print(stackTrace);
    state = state.copyWith(
      isLoading: false,
      errorMessage: "Échec du traitement des référentiels.",
    );
  }
}

  /// Déclenche la cascade lors du choix de la Région
  Future<void> loadCascadeDepartments(int regionId) async {
    state = state.copyWith(
      departments: [],
      municipalities: [],
    );

    try {
      final departments = await _referenceDataSource.getDepartments(regionId);
      state = state.copyWith(departments: departments);
    } catch (_) {}
  }

  /// Déclenche la cascade lors du choix du Département
  Future<void> loadCascadeMunicipalities(int departmentId) async {
    state = state.copyWith(municipalities: []);

    try {
      final municipalities =
          await _referenceDataSource.getMunicipalities(departmentId);
      state = state.copyWith(municipalities: municipalities);
    } catch (_) {}
  }
}

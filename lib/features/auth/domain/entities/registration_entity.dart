// features/auth/domain/entities/registration_entity.dart

import 'package:sime_v2/features/auth/data/models/reference_model.dart';

class RegistrationEntity {
  final int currentStep;
  final String cni;
  final String sex;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String username;
  final String password;
  final String placeBirth;
  final String? dateBirth;
  final int residCountryId;
  final int residRegionId;
  final int residDepartmentId;
  final int residMunicipalityId;
  final String residAddress;
  final int nationalityId;
  // Nouveaux champs pour le document
  final String documentType; // ex: 'CNI', 'PASSPORT'
  final String? documentPath; // Chemin local du fichier ou base64
  final String? documentPathRecto;
  final String? documentPathVerso;

  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  // Stockage des données de référentiels chargées depuis l'API
  final List<CountryModel> countries;
  final List<RegionModel> regions;
  final List<DepartmentModel> departments;
  final List<ReferenceModel> municipalities;
  final List<CountryModel> nationalities;

  const RegistrationEntity({
    this.currentStep = 1,
    this.cni = '',
    this.sex = 'HOMME',
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.username = '',
    this.password = '',
    this.placeBirth = '',
    this.dateBirth,
    this.residCountryId = 1,
    this.residRegionId = 14,
    this.residDepartmentId = 32,
    this.residMunicipalityId = 338,
    this.residAddress = '',
    this.nationalityId = 8,
    this.documentType = 'CNI',
     this.documentPath,
    this.documentPathRecto,
    this.documentPathVerso,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.countries = const [],
    this.regions = const [],
    this.departments = const [],
    this.municipalities = const [],
    this.nationalities = const [],
  });

  RegistrationEntity copyWith({
    int? currentStep,
    String? cni,
    String? sex,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? username,
    String? password,
    String? placeBirth,
    String? dateBirth,
    int? residCountryId,
    int? residRegionId,
    int? residDepartmentId,
    int? residMunicipalityId,
    String? residAddress,
    int? nationalityId,
    String? documentType,
    String? documentPath,
    String? documentPathRecto,
    String? documentPathVerso,
    List<CountryModel>? countries,
    List<RegionModel>? regions,
    List<DepartmentModel>? departments,
    List<ReferenceModel>? municipalities,
    List<CountryModel>? nationalities,
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return RegistrationEntity(
      currentStep: currentStep ?? this.currentStep,
      cni: cni ?? this.cni,
      sex: sex ?? this.sex,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      placeBirth: placeBirth ?? this.placeBirth,
      dateBirth: dateBirth ?? this.dateBirth,
      residCountryId: residCountryId ?? this.residCountryId,
      residRegionId: residRegionId ?? this.residRegionId,
      residDepartmentId: residDepartmentId ?? this.residDepartmentId,
      residMunicipalityId: residMunicipalityId ?? this.residMunicipalityId,
      residAddress: residAddress ?? this.residAddress,
      nationalityId: nationalityId ?? this.nationalityId,
      documentType: documentType ?? this.documentType,
      documentPath: documentPath ?? this.documentPath,
      documentPathRecto: documentPathRecto ?? this.documentPathRecto,
      documentPathVerso: documentPathVerso ?? this.documentPathVerso,
      countries: countries ?? this.countries,
      regions: regions ?? this.regions,
      departments: departments ?? this.departments,
      municipalities: municipalities ?? this.municipalities,
      nationalities: nationalities ?? this.nationalities,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

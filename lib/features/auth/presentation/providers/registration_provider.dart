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

  /// Recharge les référentiels de base (pays, nationalités, régions). Utile
  /// lorsque le chargement initial a échoué (hors-ligne) : l'utilisateur peut
  /// réessayer une fois la connexion revenue, sans quitter l'inscription.
  Future<void> reloadReferences() => _loadInitialReferences();

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
      // Filtrage défensif : si le backend ignore le paramètre departmentId
      // et renvoie toutes les communes du pays, on ne garde que celles
      // rattachées au département sélectionné (même logique que côté
      // édition de profil, voir ProfileReferencesNotifier._filterByDepartment).
      final hasDepartmentInfo = municipalities.any((m) => m.department != null);
      final filtered = hasDepartmentInfo
          ? municipalities.where((m) => m.department?.id == departmentId).toList()
          : municipalities;
      state = state.copyWith(municipalities: filtered);
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

  void nextStep() =>
      state = state.copyWith(currentStep: state.currentStep + 1, showErrors: false);
  void prevStep() =>
      state = state.copyWith(currentStep: state.currentStep - 1, showErrors: false);
  void resetSteps() => state = state.copyWith(
      currentStep: 1, isSuccess: false, errorMessage: null, showErrors: false);

  /// Active l'affichage des messages d'erreur de validation pour l'étape
  /// courante (déclenché quand l'utilisateur tente de passer à l'étape suivante
  /// avec des champs obligatoires manquants ou invalides).
  void showValidationErrors() => state = state.copyWith(showErrors: true);

  // ── Validation des champs obligatoires ─────────────────────────────────────
  // Les getters d'erreur ne renvoient un message QUE lorsque `showErrors` est
  // actif (après une tentative de passage d'étape) : pas d'erreur "au repos".
  // L'upload de pièce justificative (étape 2) est volontairement facultatif.

  bool get _showErr => state.showErrors;

  String? _requiredText(String value, String message) =>
      value.trim().isEmpty ? message : null;

  static final RegExp _emailRe = RegExp(r'^[\w.\-+]+@[\w\-]+\.[\w.\-]+$');

  /// Âge calculé depuis la date de naissance, ou `null` si absente/invalide.
  int? get _ageFromDob {
    final dob = state.dateBirth;
    if (dob == null || dob.isEmpty) return null;
    final d = DateTime.tryParse(dob);
    if (d == null) return null;
    final now = DateTime.now();
    var age = now.year - d.year;
    if (now.month < d.month || (now.month == d.month && now.day < d.day)) {
      age--;
    }
    return age;
  }

  bool get _cniFormatOk =>
      state.documentType != 'CNI' ||
      state.cni.replaceAll(RegExp(r'\s'), '').length == 13;

  // Étape 1 — informations personnelles
  String? get firstNameError =>
      _showErr ? _requiredText(state.firstName, 'Le prénom est obligatoire') : null;
  String? get lastNameError =>
      _showErr ? _requiredText(state.lastName, 'Le nom est obligatoire') : null;
  String? get placeBirthError => _showErr
      ? _requiredText(state.placeBirth, 'Le lieu de naissance est obligatoire')
      : null;
  String? get addressError =>
      _showErr ? _requiredText(state.residAddress, "L'adresse est obligatoire") : null;

  String? get dateBirthError {
    if (!_showErr) return null;
    if (state.dateBirth == null || state.dateBirth!.isEmpty) {
      return 'La date de naissance est obligatoire';
    }
    final age = _ageFromDob;
    if (age == null) return 'Date de naissance invalide';
    if (age < 15) return 'Vous devez avoir au moins 15 ans';
    return null;
  }

  String? get cniError {
    if (!_showErr) return null;
    if (state.cni.trim().isEmpty) return 'Le numéro CIN est obligatoire';
    if (!_cniFormatOk) return 'Le CIN doit contenir 13 chiffres';
    return null;
  }

  String? get regionError =>
      _showErr && state.residRegionId == 0 ? 'Sélectionnez une région' : null;
  String? get departmentError =>
      _showErr && state.residDepartmentId == 0 ? 'Sélectionnez un département' : null;
  String? get nationalityError =>
      _showErr && state.nationalityId == 0 ? 'Sélectionnez une nationalité' : null;

  // Étape 3 — création de compte
  String? get phoneError {
    if (!_showErr) return null;
    final digits = state.phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Le numéro de téléphone est obligatoire';
    if (digits.length < 11) return 'Numéro de téléphone invalide';
    return null;
  }

  String? get emailError {
    if (!_showErr) return null;
    final v = state.email.trim();
    if (v.isEmpty) return "L'adresse email est obligatoire";
    if (!_emailRe.hasMatch(v)) return 'Adresse email invalide';
    return null;
  }

  String? get usernameError {
    if (!_showErr) return null;
    final v = state.username.trim();
    if (v.isEmpty) return "Le nom d'utilisateur est obligatoire";
    if (v.length < 3) return 'Au moins 3 caractères';
    return null;
  }

  String? get passwordError {
    if (!_showErr) return null;
    if (state.password.isEmpty) return 'Le mot de passe est obligatoire';
    if (state.password.length < 6) return 'Au moins 6 caractères';
    return null;
  }

  /// Indique si l'étape [step] est valide (évaluation "pure", indépendante de
  /// `showErrors`). Sert à décider si l'on autorise le passage à l'étape
  /// suivante. L'étape 2 (pièce justificative) est toujours valide : l'upload
  /// est facultatif.
  bool isStepValid(int step) {
    switch (step) {
      case 1:
        return state.firstName.trim().isNotEmpty &&
            state.lastName.trim().isNotEmpty &&
            state.placeBirth.trim().isNotEmpty &&
            state.residAddress.trim().isNotEmpty &&
            (state.dateBirth?.isNotEmpty ?? false) &&
            (_ageFromDob ?? -1) >= 15 &&
            state.cni.trim().isNotEmpty &&
            _cniFormatOk &&
            state.residRegionId != 0 &&
            state.residDepartmentId != 0 &&
            state.nationalityId != 0;
      case 2:
        return true;
      case 3:
        final digits = state.phone.replaceAll(RegExp(r'\D'), '');
        final email = state.email.trim();
        return digits.length >= 11 &&
            email.isNotEmpty &&
            _emailRe.hasMatch(email) &&
            state.username.trim().length >= 3 &&
            state.password.length >= 6;
      default:
        return true;
    }
  }

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
// features/profile/presentation/providers/applicant_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/auth/domain/entities/reference_entity.dart';
import 'package:sime_v2/features/auth/domain/repositories/auth_repository.dart';
import 'package:sime_v2/features/profile/domain/entities/applicant_entity.dart';
import 'package:sime_v2/features/profile/domain/repositories/applicant_repository.dart';
import 'package:sime_v2/features/profile/providers/profile_providers.dart';
import 'package:sime_v2/features/auth/providers/auth_providers.dart'; // ⚠️ adapte le chemin réel

class ApplicantState {
  final ApplicantEntity? applicant;
  final bool isLoading;
  final String? errorMessage;

  ApplicantState({
    this.applicant,
    this.isLoading = false,
    this.errorMessage,
  });

  ApplicantState copyWith({
    ApplicantEntity? applicant,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ApplicantState(
      applicant: applicant ?? this.applicant,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ApplicantNotifier extends StateNotifier<ApplicantState> {
  final ApplicantRepository _repository;
  final AuthRepository _authRepository;

  ApplicantNotifier(this._repository, this._authRepository) : super(ApplicantState());

  Future<bool> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getApplicantProfile();

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (profile) {
        state = state.copyWith(isLoading: false, applicant: profile);
        return true;
      },
    );
  }

  /// Met à jour les champs "compte utilisateur" (nom, prénom, genre, téléphone, email)
  /// via PUT /auth/api/auth/me — remplacement complet de la ressource.
  ///
  /// [editedFields] ne doit contenir QUE les champs réellement modifiables dans le
  /// formulaire (firstName, lastName, sex, phone, email). Les champs obligatoires
  /// pour le PUT mais non éditables ici (username, active, avatarUrl, changePassword)
  /// sont automatiquement complétés depuis l'utilisateur actuellement en mémoire,
  /// pour éviter de les écraser avec des valeurs nulles côté serveur.
  Future<bool> updateUserAccountFields(Map<String, dynamic> editedFields) async {
    final currentUser = state.applicant?.user;
    if (currentUser == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    // Reconstruction du payload complet requis par le PUT
    final Map<String, dynamic> fullPayload = {
      'id': currentUser.id,
      'firstName': editedFields['firstName'] ?? currentUser.firstName,
      'lastName': editedFields['lastName'] ?? currentUser.lastName,
      'sex': editedFields['sex'] ?? currentUser.sex,
      'username': currentUser.username,
      'email': editedFields['email'] ?? currentUser.email,
      'phone': editedFields['phone'] ?? currentUser.phone,
      'active': currentUser.active,
      'changePassword': false,
    };

    final result = await _authRepository.updateUserAccount(fullPayload);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (updatedUser) {
        final updatedApplicant = state.applicant?.copyWith(user: updatedUser);
        state = state.copyWith(isLoading: false, applicant: updatedApplicant);
        return true;
      },
    );
  }

  /// Met à jour partiellement le profil candidat (adresse, région, nationalité,
  /// dernier diplôme, etc.) via PATCH /applicant/api/applicants/me/{id}.
  ///
  /// [fieldsToUpdate] DOIT rester strictement JSON-safe : cette map part telle
  /// quelle dans le corps de la requête PATCH et peut aussi être mise en cache
  /// par la couche offline (Hive). N'y mets jamais d'entité Dart brute.
  ///
  /// Les paramètres optionnels optimistic* servent UNIQUEMENT à peupler
  /// immédiatement l'état local — jamais envoyés au réseau.
  Future<bool> updateProfileFields(
    Map<String, dynamic> fieldsToUpdate, {
    CountryEntity? optimisticNationality,
    ReferenceEntity? optimisticEducationLevel,
    ReferenceEntity? optimisticFieldStudy,
  }) async {
    final currentApplicant = state.applicant;
    if (currentApplicant == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.updateApplicantProfile(currentApplicant.id, fieldsToUpdate);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        final updatedApplicant = currentApplicant.copyWith(
          dateBirth: fieldsToUpdate['dateBirth'] as String? ?? currentApplicant.dateBirth,
          // placeBirth: fieldsToUpdate['placeBirth'] as String? ?? currentApplicant.placeBirth,
          address: fieldsToUpdate['residAddress'] as String? ?? currentApplicant.address,
          lastDegreeObtained:
              fieldsToUpdate['lastDegreeObtained'] as ReferenceEntity? ?? currentApplicant.lastDegreeObtained,
          nationality: optimisticNationality ?? currentApplicant.nationality,
          educationLevel: optimisticEducationLevel ?? currentApplicant.educationLevel,
          fieldStudy: optimisticFieldStudy ?? currentApplicant.fieldStudy,
        );

        state = state.copyWith(isLoading: false, applicant: updatedApplicant);
        return true;
      },
    );
  }
}

final applicantNotifierProvider = StateNotifierProvider<ApplicantNotifier, ApplicantState>((ref) {
  final repository = ref.watch(applicantRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider); // ⚠️ adapte au nom réel de ton provider
  return ApplicantNotifier(repository, authRepository);
});
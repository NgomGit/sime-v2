// features/profile/presentation/providers/applicant_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/auth/domain/entities/reference_entity.dart';
import 'package:sime_v2/features/profile/domain/entities/applicant_entity.dart';
import 'package:sime_v2/features/profile/domain/repositories/applicant_repository.dart';
import 'package:sime_v2/features/profile/providers/profile_providers.dart';

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

  ApplicantNotifier(this._repository) : super(ApplicantState());

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

  /// Met à jour partiellement le profil de l'applicant.
  ///
  /// [fieldsToUpdate] DOIT rester strictement JSON-safe (int, String, bool,
  /// double, null, ou List/Map de ceux-ci) : cette map part telle quelle dans
  /// le corps de la requête PATCH, et peut aussi être mise en cache par la
  /// couche offline (Hive). N'y mets jamais d'entité Dart brute
  /// (ReferenceEntity, CountryEntity, etc.) — ça fait planter la sérialisation
  /// Hive avec "Cannot write, unknown type".
  ///
  /// Les paramètres optionnels [optimisticNationality],
  /// [optimisticEducationLevel] et [optimisticFieldStudy] servent UNIQUEMENT
  /// à peupler immédiatement l'état local via copyWith (mise à jour
  /// optimiste de l'UI) — ils ne sont jamais envoyés au réseau.
  Future<bool> updateProfileFields(
    Map<String, dynamic> fieldsToUpdate, {
    CountryEntity? optimisticNationality,
    ReferenceEntity? optimisticEducationLevel,
    ReferenceEntity? optimisticFieldStudy,
  }) async {
    final currentApplicant = state.applicant;
    if (currentApplicant == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    // Appel réseau : uniquement le payload JSON-safe fourni par l'appelant
    final result = await _repository.updateApplicantProfile(currentApplicant.id, fieldsToUpdate);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (_) {
        // 🚀 MISE À JOUR OPTIMISTE LOCALE :
        // On fusionne dynamiquement les champs modifiés dans l'entité courante.
        // Les champs "primitifs" (String) viennent directement de fieldsToUpdate.
        // Les champs "entités" viennent des paramètres optimistic* dédiés,
        // JAMAIS de fieldsToUpdate (qui ne contient que des ids/primitifs).
        UserProfileEntity? updatedUser = currentApplicant.user;

        if (fieldsToUpdate.containsKey('firstName') || fieldsToUpdate.containsKey('lastName')) {
          updatedUser = currentApplicant.user?.copyWith(
            firstName: fieldsToUpdate['firstName'] as String?,
            lastName: fieldsToUpdate['lastName'] as String?,
          );
        }

        final updatedApplicant = currentApplicant.copyWith(
          dateBirth: fieldsToUpdate['dateBirth'] as String? ?? currentApplicant.dateBirth,
          address: fieldsToUpdate['residAddress'] as String? ?? currentApplicant.address,
          lastDegreeObtained:
              fieldsToUpdate['lastDegreeObtained'] as ReferenceEntity? ?? currentApplicant.lastDegreeObtained,
          nationality: optimisticNationality ?? currentApplicant.nationality,
          educationLevel: optimisticEducationLevel ?? currentApplicant.educationLevel,
          fieldStudy: optimisticFieldStudy ?? currentApplicant.fieldStudy,
          user: updatedUser,
        );

        state = state.copyWith(isLoading: false, applicant: updatedApplicant);
        return true;
      },
    );
  }
}

final applicantNotifierProvider = StateNotifierProvider<ApplicantNotifier, ApplicantState>((ref) {
  final repository = ref.watch(applicantRepositoryProvider);
  return ApplicantNotifier(repository);
});
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/profile/data/repositories/user_profile_repository_impl.dart';
import 'package:sime_v2/features/profile/domain/repositories/user_profile_repository.dart';


import '../../domain/entities/user_profile_entity.dart';


final profileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return  UserProfileRepositoryImpl();
});

final profileNotifierProvider = AsyncNotifierProvider<ProfileNotifier, UserProfileEntity>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends AsyncNotifier<UserProfileEntity> {
  @override
  Future<UserProfileEntity> build() async {
    return ref.watch(profileRepositoryProvider).getUserProfile();
  }

  /// Met à jour les informations personnelles de l'utilisateur.
  Future<void> updatePersonalProfile({
    required String fullName,
    required String birthDate,
    required String cin,
    required String nationality,
    required String location,
  }) async {
    // Permet de passer l'état actuel en mode chargement tout en préservant les données précédentes à l'écran
    state = const AsyncLoading();

    // On encapsule l'exécution dans un bloc try/catch pour propager correctement les erreurs
    state = await AsyncValue.guard(() async {
      // Simulation d'une requête HTTP PUT / POST vers un serveur d'API
      await Future.delayed(const Duration(seconds: 2));

      // Optionnel : Vous pouvez lever une exception pour tester la gestion des erreurs
      // throw Exception('Connexion réseau perdue');

      // On récupère la valeur actuelle de l'état (ou on lève une erreur si absente)
      final currentProfile = state.value;
      if (currentProfile == null) {
        throw Exception('Le profil actuel n\'est pas encore chargé.');
      }

      // Retourne le profil modifié
      return currentProfile.copyWith(
        fullName: fullName,
        birthDate: birthDate,
        cin: cin,
        nationality: nationality,
        location: location,
      );
    });
  }

  /// Met à jour le profil professionnel de l'utilisateur.
  Future<void> updateProfessionalProfile({
    required String studyLevel,
    required String domain,
    required String experience,
    required String lastDegree,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      // Simulation d'un délai de réseau réseau de 2 secondes
      await Future.delayed(const Duration(seconds: 2));

      final currentProfile = state.value;
      if (currentProfile == null) {
        throw Exception('Le profil actuel n\'est pas encore chargé.');
      }

      // Retourne le profil modifié avec les informations professionnelles mises à jour
      return currentProfile.copyWith(
        studyLevel: studyLevel,
        domain: domain,
        experience: experience,
        lastDegree: lastDegree,
      );
    });
  }

  Future<void> signout() async {
    // state = const AsyncValue.loading();
    try {
      await ref.read(profileRepositoryProvider).logout();
      // Mettre à jour l'auth state ou naviguer vers le login screen via GoRouter

    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
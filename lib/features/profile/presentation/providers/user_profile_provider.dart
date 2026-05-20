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
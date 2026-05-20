import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';

// Fake stub – replace with real repository implementation
class AuthNotifier extends AsyncNotifier<UserEntity?> {
  @override
  Future<UserEntity?> build() async {
    // Check persisted session from flutter_secure_storage
    await Future.delayed(const Duration(milliseconds: 600));
    return null; // no session on cold start
  }

  Future<void> login(String phone, String password) async {
    state = const AsyncLoading();
    await Future.delayed(const Duration(seconds: 1));
    state = AsyncData(
      UserEntity(
        id: 'usr_001',
        firstName: 'Mamadou',
        lastName: 'Aidara',
        phone: phone,
        role: UserRole.demandeur,
        dossierNumber: 'SN-2026-04821',
      ),
    );
  }

  Future<void> logout() async {
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserEntity?>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).valueOrNull != null;
});

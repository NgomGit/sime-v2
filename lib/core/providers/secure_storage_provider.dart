import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    // Configuration requise sous Android pour chiffrer correctement les préférences partagées
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    // Configuration requise sous iOS pour synchroniser optionnellement avec iCloud (désactivé ici)
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  final nativeStorage = ref.watch(flutterSecureStorageProvider);
  return SecureStorageService(nativeStorage);
});
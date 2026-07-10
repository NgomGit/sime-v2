// main.dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import requis pour l'instance
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sime_v2/core/services/secure_storage_service.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';


import 'core/design_system/tokens/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/login_provider.dart';

Future<void> main() async {
  // 1. Assurer la liaison avec les services natifs de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialiser Hive de base avant toute création de container Riverpod
  await Hive.initFlutter();

  // 3. Initialiser la localisation pour les dates (français)
  await initializeDateFormatting('fr', null);

  // ── Instanciation manuelle de la dépendance pour le boot ───────────────────
  const flutterSecureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  
  // On passe l'instance requise au constructeur de ton service
  final secureStorageService = SecureStorageService(flutterSecureStorage);
  // ───────────────────────────────────────────────────────────────────────────
  
  // 4. Récupérer la clé sécurisée depuis le Keystore/Keychain matériel
  final encryptionKey = await secureStorageService.getOrCreateHiveEncryptionKey();
  
  // 5. Ouvrir la box d'application de manière entièrement chiffrée en AES-256
  final openBox = await Hive.openBox<String>(
    'sime_cache',
    encryptionCipher: HiveAesCipher(encryptionKey),
  ); // Cast explicite pour la box de chaînes JSON

  // Envelopper la box dans ton gestionnaire d'infrastructure HiveCache
  final hiveCacheInstance = HiveCache(openBox);

  // 6. Créer le Container Riverpod global en y injectant notre boîte chiffrée prête
  final container = ProviderContainer(
    overrides: [
      hiveCacheProvider.overrideWithValue(hiveCacheInstance),
    ],
  );

  try {
    // 7. Déclenche explicitement l'initialisation du LoginNotifier au démarrage.
    await container.read(loginNotifierProvider.future);
  } catch (e) {
    debugPrint("Erreur lors de la récupération de la session : $e");
  }

  runApp(
    ProviderScope(
      parent: container,
      child: const SimeApp(),
    ),
  );
}

class SimeApp extends ConsumerWidget {
  const SimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SIME V2 — ANPEJ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      supportedLocales: const [Locale('fr'), Locale('en')],
      locale: const Locale('fr'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
// main.dart
import 'dart:async';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import requis pour l'instance
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sime_v2/core/design_system/tokens/app_colors.dart';
import 'package:sime_v2/core/design_system/tokens/app_text_styles.dart';
import 'package:sime_v2/core/services/secure_storage_service.dart';
import 'package:sime_v2/core/network/api_client.dart';
import 'package:sime_v2/core/network/ssl/trusted_certificates.dart';
import 'package:sime_v2/core/storage/hive_cache.dart';

import 'core/design_system/tokens/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/login_provider.dart';

const _kCacheBoxName = 'sime_cache';

void main() {
  // On rend la main à Flutter IMMÉDIATEMENT : `runApp` est appelé sans aucun
  // `await` préalable, pour qu'une UI de marque s'affiche dès la première frame.
  // Toute l'initialisation lourde (Hive, clé de chiffrement matérielle,
  // ouverture de la box chiffrée) se fait ENSUITE, sous un écran de démarrage
  // animé — plutôt que pendant l'écran natif blanc, qui provoquait le « flash
  // blanc » au lancement.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _AppBootstrap());
}

/// Amorce l'application : exécute l'initialisation asynchrone tout en affichant
/// un écran de démarrage, puis monte l'app réelle une fois le container prêt.
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  late Future<ProviderContainer> _bootstrap = _initialize();

  Future<ProviderContainer> _initialize() async {
    // 1. Hive + localisation des dates (français).
    await Hive.initFlutter();
    await initializeDateFormatting('fr', null);

    // 2. Clé de chiffrement depuis le Keystore/Keychain matériel.
    const flutterSecureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
    final secureStorageService = SecureStorageService(flutterSecureStorage);
    final encryptionKey =
        await secureStorageService.getOrCreateHiveEncryptionKey();

    // 3. Ouverture de la box chiffrée AES-256, avec récupération défensive :
    //    si la box est illisible (corrompue, ou héritée d'une version non
    //    chiffrée), on la supprime et on la recrée plutôt que de laisser
    //    l'exception remonter et bloquer le démarrage sur un écran blanc.
    Box<String> box;
    try {
      box = await Hive.openBox<String>(
        _kCacheBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
    } catch (e) {
      debugPrint('⚠️ Ouverture du cache chiffré impossible ($e) — réinitialisation.');
      await Hive.deleteBoxFromDisk(_kCacheBoxName);
      box = await Hive.openBox<String>(
        _kCacheBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
    }

    // 4. Certificat(s) intermédiaire(s) TLS additionnel(s) éventuels (chaîne
    //    incomplète côté serveur, cf. assets/certs/). `null` si aucun n'est
    //    embarqué → validation TLS système standard.
    final extraCerts = await loadExtraTrustedCertificates();

    // 5. Container Riverpod global avec la box (et les certificats) injectés.
    final container = ProviderContainer(
      overrides: [
        hiveCacheProvider.overrideWithValue(HiveCache(box)),
        if (extraCerts != null)
          extraTrustedCertificatesProvider.overrideWithValue(extraCerts),
      ],
    );

    // 6. Pré-initialise le LoginNotifier (lecture session/cache) sans bloquer :
    //    l'écran Splash attend de toute façon `authCheckProvider`.
    unawaited(
      container.read(loginNotifierProvider.future).catchError(
        (Object e) {
          debugPrint('Erreur lors de la récupération de la session : $e');
          return const LoginState();
        },
      ),
    );

    return container;
  }

  void _retry() {
    // Corps en bloc (et non fléché) : le callback de setState doit retourner
    // `void`. En arrow, `_bootstrap = _initialize()` renverrait le Future assigné,
    // ce que setState rejette.
    final next = _initialize();
    setState(() {
      _bootstrap = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProviderContainer>(
      future: _bootstrap,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _BootShell(child: _BootError(onRetry: _retry));
        }
        if (!snapshot.hasData) {
          return const _BootShell(child: _BootLoading());
        }
        return ProviderScope(
          parent: snapshot.data!,
          child: const SimeApp(),
        );
      },
    );
  }
}

/// Enveloppe minimale (MaterialApp + fond dégradé de marque) pour les états de
/// démarrage — garantit une première frame « ANPEJ », jamais blanche.
class _BootShell extends StatelessWidget {
  const _BootShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary50, AppColors.background],
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _BootLoading extends StatelessWidget {
  const _BootLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'SIME',
          style: AppTextStyles.headingMedium.copyWith(
            color: AppColors.secondary800,
            letterSpacing: 4,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary400),
          ),
        ),
      ],
    );
  }
}

class _BootError extends StatelessWidget {
  const _BootError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 44),
          const SizedBox(height: 16),
          Text(
            "Impossible de démarrer l'application",
            textAlign: TextAlign.center,
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.neutral800),
          ),
          const SizedBox(height: 8),
          Text(
            'Veuillez réessayer. Si le problème persiste, redémarrez l\'application.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
        ],
      ),
    );
  }
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

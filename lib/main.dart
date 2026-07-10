// main.dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/design_system/tokens/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/login_provider.dart';

Future<void> main() async {
  // 1. Assurer la liaison avec les services natifs de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Initialiser la localisation pour les dates (français)
  await initializeDateFormatting('fr', null);
  
  // 3. Créer un Container Riverpod en amont pour pré-charger les états asynchrones
  final container = ProviderContainer();
  
  try {
    // Déclenche explicitement l'initialisation du LoginNotifier au démarrage.
    // Sa méthode build() va aller lire le token dans le secure storage.
    await container.read(loginNotifierProvider.future);
  } catch (e) {
    // Optionnel : Gérer une erreur de lecture du secure storage
    debugPrint("Erreur lors de la récupération de la session : $e");
  }

  runApp(
    ProviderScope(
      parent: container, // On passe le container déjà initialisé à notre ProviderScope
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
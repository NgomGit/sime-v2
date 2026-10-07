// core/router/app_router.dart
import 'package:sime_v2/features/besoin/domain/entities/my_subscription_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/core/router/router_notifier.dart';
import 'package:sime_v2/features/auth/presentation/providers/login_provider.dart';
import 'package:sime_v2/features/auth/presentation/screens/login_screen.dart';
import 'package:sime_v2/features/auth/presentation/screens/splash_screen.dart';
import 'package:sime_v2/features/notification/presentation/screens/notification_screen.dart';
import 'package:sime_v2/features/offres/presentation/screens/offres_details_screen.dart';
import 'package:sime_v2/features/profile/presentation/screens/edit_account_fields.dart';
import 'package:sime_v2/features/profile/presentation/screens/edit_identity_document.dart';
import 'package:sime_v2/features/profile/presentation/screens/edit_identity_informations.dart';
import 'package:sime_v2/features/profile/presentation/screens/edit_personal_situation.dart';
import 'package:sime_v2/features/profile/presentation/screens/edit_professional_profile.dart';
import 'package:sime_v2/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:sime_v2/features/profile/presentation/screens/parametres_screen.dart';

import '../../features/auth/presentation/screens/inscription_screen.dart';
// import '../../features/auth/presentation/screens/identity_scanner_screen.dart';

import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/besoin/presentation/screens/nouveau_besoin_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/dossier/presentation/screens/mon_dossier_screen.dart';
import '../../features/offres/presentation/screens/offres_screen.dart';
import '../../features/rendezvous/presentation/screens/rendezvous_screen.dart';
import '../../features/reclamation/presentation/screens/reclamations_screen.dart';
import '../../features/reclamation/presentation/screens/reclamation_chat_screen.dart';

// keepAlive: on ne veut surtout PAS que ce provider soit recréé, il ne doit
// être construit qu'UNE SEULE FOIS pendant toute la durée de vie de l'app.
final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    refreshListenable: routerNotifier, // ← déclenche redirect() sans recréer GoRouter
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (ctx, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (ctx, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (ctx, state) => const InscriptionScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        // `extra` optionnel = index d'onglet initial (ex. 3 → « Mon dossier »).
        builder: (ctx, state) =>
            DashboardScreen(initialIndex: state.extra is int ? state.extra as int : 0),
      ),
      GoRoute(
        path: AppRoutes.offres,
        name: 'offres',
        builder: (ctx, state) => const OffresScreen(),
      ),
      GoRoute(
        path: AppRoutes.agenda,
        name: 'agenda',
        builder: (ctx, state) => const RendezVousScreen(),
      ),
      GoRoute(
        path: AppRoutes.dossier,
        name: 'dossier',
        builder: (ctx, state) => const MonDossierScreen(),
      ),
      GoRoute(
        path: AppRoutes.reclamations,
        name: 'reclamations',
        builder: (ctx, state) => const ReclamationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.reclamationChat,
        name: 'reclamationChat',
        builder: (ctx, state) =>
            ReclamationChatScreen(claimId: state.extra as int),
      ),
      GoRoute(
        path: AppRoutes.nouveauBesoin,
        name: 'nouveauBesoin',
        // `extra` optionnel : un MySubscriptionEntity → mode modification.
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: NouveauBesoinScreen(
            initial: state.extra is MySubscriptionEntity
                ? state.extra as MySubscriptionEntity
                : null,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.offreDetails,
        name: 'offreDetails',
        builder: (ctx, state) => OffreDetailScreen(offreId: state.extra as String),
      ),
      GoRoute(
        path: AppRoutes.profil,
        name: 'profil',
        builder: (ctx, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.parametres,
        name: 'parametres',
        builder: (ctx, state) => const ParametresScreen(),
      ),
      GoRoute(
        path: AppRoutes.editPersonalProfile,
        name: 'editPersonalProfile',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: EditAccountFieldsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editIdentityInformations,
        name: 'editIdentityInformations',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: EditIdentityInformationsScreen(),
        ),
      ),

      //  
      GoRoute(
        path: AppRoutes.editPersonalSituation,
        name: 'editPersonalSituation',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: EditPersonalSituationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editIdentityDocument,
        name: 'editIdentityDocument',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: EditIdentityDocumentScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfessionalProfile,
        name: 'editProfessionalProfile',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: EditProfessionalProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notification,
        name: 'notification',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true,
          child: NotificationsScreen(),
        ),
      ),
    ],
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final location = state.matchedLocation;

      final isLoggingIn = location == AppRoutes.login;
      final isRegistering = location == AppRoutes.register;
      final isSplashing = location == '/';
      final isOnboarding = location == '/onboarding';

      final isPublicRoute = isLoggingIn || isRegistering || isSplashing || isOnboarding;

      if (!isAuthenticated && !isPublicRoute) {
        return AppRoutes.login;
      }

      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return AppRoutes.dashboard;
      }

      return null;
    },
  );
});
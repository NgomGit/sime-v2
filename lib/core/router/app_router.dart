import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/features/auth/presentation/screens/login_screen.dart';
import 'package:sime_v2/features/notification/presentation/screens/notification_screen.dart';
import 'package:sime_v2/features/offres/presentation/screens/offres_details_screen.dart';
import 'package:sime_v2/features/profile/presentation/screens/edit_personal_profile_screen.dart';
import 'package:sime_v2/features/profile/presentation/screens/edit_professional_profile.dart';
import 'package:sime_v2/features/profile/presentation/screens/user_profile_screen.dart';

import '../../features/auth/presentation/screens/inscription_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/offres/presentation/screens/offres_screen.dart';
import '../../features/rendezvous/presentation/screens/rendezvous_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // GoRoute(
      //   path: '/home',
      //   name: 'home',
      //   builder: (ctx, state) => const OnboardingScreen(),
      // ),
      GoRoute(
        path: '/',
        name: 'onboarding',
        builder: (ctx, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (ctx, state) => const InscriptionScreen(),
      ),
      // GoRoute(
      //   path: AppRoutes.identityScanner,
      //   name: 'identityScanner',
      //   builder: (ctx, state) => const IdentityScannerScreen(),
      // ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (ctx, state) => const DashboardScreen(),
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
        path: AppRoutes.offreDetails,
        name: 'offreDetails',
        builder: (ctx, state) =>
            OffreDetailScreen(offreId: state.extra as String),
      ),

      GoRoute(
        path: AppRoutes.profil,
        name: 'profil',
        builder: (ctx, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.editPersonalProfile,
        name: 'editPersonalProfile',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true, // Donne un effet de slide du bas
          child: EditPersonalProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editProfessionalProfile,
        name: 'editProfessionalProfile',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true, // Donne un effet de slide du bas
          child: EditProfessionalProfileScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.notification,
        name: 'notification',
        pageBuilder: (context, state) => const MaterialPage(
          fullscreenDialog: true, // Donne un effet de slide du bas
          child: NotificationsScreen(),
        ),
      ),
    ],
  );
});

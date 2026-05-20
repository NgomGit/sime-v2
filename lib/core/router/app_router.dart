import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sime_v2/core/const/app_routes.dart';
import 'package:sime_v2/features/auth/presentation/screens/connection_screen.dart';

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
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (ctx, state) => const ConnexionScreen(),
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
    ],
  );
});



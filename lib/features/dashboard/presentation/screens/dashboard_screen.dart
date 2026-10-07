import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/core/design_system/widgets/s_app_bar.dart';
import 'package:sime_v2/features/dashboard/presentation/screens/dashboard_home_screen.dart';
import 'package:sime_v2/features/dossier/presentation/screens/mon_dossier_screen.dart';
import 'package:sime_v2/features/offres/presentation/screens/offres_screen.dart';
import 'package:sime_v2/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:sime_v2/features/rendezvous/presentation/screens/rendezvous_screen.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../presentation/widgets/sime_bottom_nav.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, this.initialIndex = 0});

  /// Onglet affiché à l'ouverture (0 = Accueil, 2 = Agenda, 3 = Mon dossier…).
  /// Permet à d'autres écrans de router directement vers un onglet précis —
  /// ex. après l'enregistrement d'un besoin, on ouvre le dashboard sur
  /// « Mon dossier » (index 3) tout en conservant la barre de navigation.
  final int initialIndex;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late int currentIndex = widget.initialIndex;

  List<Widget> get _screens => [
    DashboardHomeScreen(
      navigationToProfile: navigateToProfile,
      navigationToAgenda: navigateToAgenda,
      navigationToDossier: navigateToDossier,
    ),
    const OffresScreen(),
    const RendezVousScreen(),
    const MonDossierScreen(),
    const ProfileScreen(),
  ];

  void navigateToProfile() {
    setState(() {
      currentIndex = 4; // Index du profil dans la liste des écrans
    });
  }

  void navigateToAgenda() {
    setState(() {
      currentIndex = 2; // Index de l'agenda dans la liste des écrans
    });
  }

  void navigateToDossier() {
    setState(() {
      currentIndex = 3; // Index de « Mon dossier » dans la liste des écrans
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SAppBar(
        title: Text('Sime Platform'),
        ),
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SimeBottomNav(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
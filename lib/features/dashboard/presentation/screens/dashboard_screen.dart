import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/dashboard/presentation/screens/dashboard_home_screen.dart';
import 'package:sime_v2/features/dossier/presentation/screens/mon_dossier_screen.dart';
import 'package:sime_v2/features/offres/presentation/screens/offres_screen.dart';
import 'package:sime_v2/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:sime_v2/features/rendezvous/presentation/screens/rendezvous_screen.dart';

import '../../../../core/design_system/tokens/app_colors.dart';
import '../../presentation/widgets/sime_bottom_nav.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int currentIndex = 0;

  static const List<Widget> _screens = [
    DashboardHomeScreen(),
    OffresScreen(),
    RendezVousScreen(),
    MonDossierScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
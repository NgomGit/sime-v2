// core/providers/first_launch_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final isFirstLaunchProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  // Renvoie true si la clé 'is_first_launch' n'existe pas encore
  final isFirst = prefs.getBool('is_first_launch') ?? true;
  return isFirst;
});

final onboardingServiceNotifierProvider = Provider((ref) => OnboardingService());

class OnboardingService {
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);
  }
}
// core/router/router_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sime_v2/features/auth/presentation/providers/login_provider.dart';

/// Pont entre Riverpod et GoRouter : notifie GoRouter des changements
/// d'état d'authentification SANS jamais recréer l'instance de GoRouter.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<bool>(
      isAuthenticatedProvider,
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
      fireImmediately: false,
    );
  }

  final Ref _ref;

  bool get isAuthenticated => _ref.read(isAuthenticatedProvider);
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
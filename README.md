# SIME V2 — Flutter App · ANPEJ

**Système d'Information sur le Marché de l'Emploi**, Version 2  
Agence Nationale pour la Promotion de l'Emploi des Jeunes · Sénégal

---

## Architecture

Ce projet suit une **Clean Architecture Feature-First** avec Riverpod 2.0+ comme solution de state management.

```
lib/
├── core/
│   ├── design_system/
│   │   ├── tokens/         # AppColors, AppTextStyles, AppDimensions, AppTheme
│   │   └── widgets/        # SButton, SCard, SStatusBadge, STag
│   ├── error/              # Failure, AppException
│   ├── router/             # GoRouter + guards (app_router.dart)
│   └── security/           # JWT, biometrics, cert pinning (à compléter)
│
└── features/
    ├── auth/
    │   ├── domain/entities/user_entity.dart
    │   ├── domain/repositories/i_auth_repository.dart
    │   └── presentation/
    │       ├── screens/onboarding_screen.dart   ← Écran 1
    │       ├── screens/inscription_screen.dart  ← Écran 3
    │       └── providers/auth_provider.dart
    ├── dashboard/
    │   └── presentation/screens/dashboard_screen.dart  ← Écran 2
    ├── offres/
    │   └── presentation/screens/offres_screen.dart     ← Écran 4
    └── rendezvous/
        └── presentation/screens/rendezvous_screen.dart ← Écran 5
```

## Écrans implémentés

| # | Écran | Route | Description |
|---|-------|-------|-------------|
| 1 | Onboarding | `/` | Hero dark, stats panel, CTA bottom sheet |
| 2 | Dashboard | `/dashboard` | Statut dossier, prochain RDV, offres recommandées |
| 3 | Inscription | `/register` | Formulaire 3 étapes avec stepper animé |
| 4 | Offres | `/offres` | Recherche + filtres + liste paginée |
| 5 | Agenda | `/agenda` | Strip calendrier + timeline rendez-vous |

## Design system

**Palette** : vert nuit `#0D1F14` (primary), vert ANPEJ `#27B060` (accent), or `#F9A825` (accent secondaire)  
**Typographie** : Gilroy (Regular 400 → ExtraBold 800)  
**Tokens** : `AppColors`, `AppTextStyles`, `AppDimensions` — source de vérité unique

## Offline-first (à compléter)

- **Isar DB** pour la persistance locale (dossiers, RDV, offres)
- **SyncEngine** : file de mutations offline, sync auto au retour de la connectivité
- **WorkManager** : background sync (RDV, statuts dossier)

## Démarrage

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter test test/unit/          # Domain logic
flutter test test/widget/        # Composants UI
flutter test test/integration/   # Flows complets
```

## Prochaines étapes

- [ ] Implémenter `IAuthRepository` avec Dio + flutter_secure_storage
- [ ] Configurer Isar pour le cache offline
- [ ] Ajouter SyncEngine + ConnectivityChecker
- [ ] Screen Conseiller (dashboard backoffice)
- [ ] Screen Dossier détail
- [ ] Notifications push (FCM)
- [ ] Biométrie locale (local_auth)
- [ ] Certificate pinning (Dio interceptor)
- [ ] Golden tests UI

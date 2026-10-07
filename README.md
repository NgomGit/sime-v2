# SIME v2 — Application mobile demandeur · ANPEJ

**Système d'Information sur le Marché de l'Emploi**, version 2 — Agence Nationale pour la Promotion de l'Emploi des Jeunes (Sénégal).

Application Flutter destinée aux **demandeurs d'emploi** : inscription, consultation et candidature aux offres (emploi, formation, offres externes), souscription aux services ANPEJ (« besoins »), agenda des rendez-vous, réclamations avec un conseiller et gestion du profil.

Principes directeurs : **Clean Architecture feature-first**, **offline-first** (l'app reste utilisable sans réseau, avec synchronisation automatique au retour de la connexion) et **UX soignée** (états de connectivité et de synchronisation visibles et animés).

> 📘 La documentation technique détaillée (architecture, offline-first, endpoints, cache, conventions, points ouverts) est dans **[doc.md](doc.md)**.
> Elle doit être mise à jour à chaque évolution du projet — voir la section *Règle de documentation* ci-dessous.

---

## Stack

| Domaine | Choix |
|---|---|
| Framework | Flutter (Dart `>=3.3.0 <4.0.0`) |
| State management | Riverpod 2 (`flutter_riverpod`, `AsyncNotifier` / `Notifier`) |
| Navigation | GoRouter 14 + `RouterNotifier` (redirections selon l'authentification) |
| Réseau | Dio 5 (intercepteurs token / 401 / logs, certificat TLS intermédiaire embarqué) |
| Cache & offline | Hive (box `sime_cache` chiffrée AES-256 + boxes dédiées aux files d'attente) |
| Secrets | `flutter_secure_storage` (JWT, session, clé de chiffrement Hive) |
| Connectivité | `connectivity_plus` + vérification DNS réelle |
| Erreurs | `dartz` → `Either<Failure, T>` |

## Fonctionnalités

| Module | État | Offline |
|---|---|---|
| Splash / Onboarding / Connexion (« se souvenir de moi ») | ✅ API réelle | Session restaurée depuis le stockage local |
| Inscription en 3 étapes (Informations · Documents · Compte) | ✅ API réelle | En ligne uniquement |
| Offres — emploi, formation, externes + détail + candidature | ✅ API réelle | Listes et détails consultés en cache ; candidature en ligne |
| Nouveau besoin / Mes souscriptions (services ANPEJ) | ✅ API réelle | Référentiels en cache ; création/modification en ligne |
| Agenda des rendez-vous | ✅ API réelle (lecture) | Cache |
| Réclamations (chat demandeur ↔ conseiller) | ✅ API réelle (+ 1 endpoint présumé) | File d'attente + renvoi automatique |
| Profil demandeur (consultation, édition, complétion) | ✅ API réelle | Modifications mises en file et synchronisées |
| Accueil (dashboard) · Mon dossier · Notifications | 🟡 Données simulées (mocks) | — |

## Démarrage

```bash
flutter pub get
flutter run            # ou : make run
```

L'URL du Gateway est définie dans `lib/core/network/api_client.dart` (`_baseUrl`). Voir [doc.md › Configuration](doc.md#3-configuration--environnements) pour les environnements.

### Build (Makefile)

```bash
make help        # liste des cibles
make apk         # APK release (toutes ABIs)
make apk-split   # un APK par ABI
make aab         # App Bundle Play Store
make release     # clean + get + apk
```

Options : `make apk FLUTTER="fvm flutter"` · `make apk DEFINES="--dart-define=ENV=prod"`.

### Tests

```bash
flutter test               # tests unitaires dans test/unit/
flutter analyze
```

## Structure (résumé)

```
lib/
├── main.dart                 # Bootstrap : Hive chiffré, certificats TLS, ProviderContainer
├── core/                     # Transverse : réseau, cache, offline-first, routeur, design system
└── features/                 # auth · offres · besoin · rendezvous · reclamation · profile
                              # dashboard · dossier · notification
    └── <feature>/
        ├── data/             # datasources (remote/local), models, repositories impl
        ├── domain/           # entities, repositories (contrats), usecases
        ├── presentation/     # providers (notifiers), screens, widgets
        └── providers/        # câblage Riverpod (injection des dépendances)
```

Détail complet : [doc.md › Architecture](doc.md#2-architecture).

## Règle de documentation

**Toute modification du projet (nouvelle feature, endpoint, clé de cache, route, changement d'architecture, correctif notable) doit mettre à jour `doc.md` dans le même commit**, et ce README si la vue d'ensemble change (tableau des fonctionnalités, stack, démarrage). La procédure est décrite dans [doc.md › Maintenir cette documentation](doc.md#12-maintenir-cette-documentation) et rappelée aux agents IA dans `AGENTS.md` / `CLAUDE.md`.

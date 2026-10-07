# SIME v2 — Documentation technique

> **Dernière mise à jour : 2026-09-30** · branche `profile-completion`
> Ce document décrit l'état **réel** du code. Il doit être mis à jour à chaque évolution du projet (voir [§12](#12-maintenir-cette-documentation)).
> Vue d'ensemble et démarrage rapide : [README.md](README.md).

## Sommaire

1. [Contexte & objectifs](#1-contexte--objectifs)
2. [Architecture](#2-architecture)
3. [Configuration & environnements](#3-configuration--environnements)
4. [Démarrage de l'application (bootstrap)](#4-démarrage-de-lapplication-bootstrap)
5. [Réseau](#5-réseau)
6. [Stockage local & sécurité](#6-stockage-local--sécurité)
7. [Stratégie offline-first & synchronisation](#7-stratégie-offline-first--synchronisation)
8. [Navigation & authentification](#8-navigation--authentification)
9. [Design system & UX de connectivité](#9-design-system--ux-de-connectivité)
10. [Features](#10-features)
11. [Référence des endpoints](#11-référence-des-endpoints)
12. [Maintenir cette documentation](#12-maintenir-cette-documentation)
13. [Points ouverts & dette technique](#13-points-ouverts--dette-technique)
14. [Journal des modifications](#14-journal-des-modifications)

---

## 1. Contexte & objectifs

SIME v2 (Système d'Information sur le Marché de l'Emploi) est l'application mobile **demandeur** de l'ANPEJ (Sénégal). Le cahier des charges est à la racine du dépôt (`B&G --- CAHIER DE CHARGE SIME 2 .pdf`) et une collection Postman de l'API (`SIME_v2_API.postman_collection (1).json`).

Exigences structurantes :

- **Clean Architecture** feature-first, couches `data / domain / presentation` isolées.
- **Offline-first** : l'app reste utilisable sans réseau ; les données sont servies depuis le cache local et les actions faites hors ligne sont rejouées automatiquement au retour de la connexion.
- **Connectivité et synchronisation visibles** : l'utilisateur sait toujours s'il est en ligne, hors ligne, ou en cours de synchronisation (AppBar animée, bandeaux, accusés d'envoi).
- **UX premium** : animations discrètes, skeletons, pas d'écran blanc au démarrage.

---

## 2. Architecture

### 2.1 Arborescence

```
lib/
├── main.dart                      # Bootstrap (Hive chiffré, TLS, ProviderContainer)
├── core/
│   ├── const/app_routes.dart      # Constantes de routes
│   ├── design_system/
│   │   ├── tokens/                # AppColors, AppTextStyles, AppDimensions, AppTheme
│   │   ├── theme/ decorations/
│   │   └── widgets/               # SAppBar, SButton, SCard, STag, SStatusBadge,
│   │                              # SSearchableDropdown, SShimmer, MainScaffold, …
│   ├── error/                     # failures.dart (utilisé), failure.dart (legacy), api_exception.dart
│   ├── network/                   # ApiClient, ApiConstants (legacy), NetworkInfo,
│   │                              # interceptors/, ssl/trusted_certificates.dart
│   ├── providers/                 # auth_check, first_launch, secure_storage, scan_result
│   ├── router/                    # app_router.dart, router_notifier.dart
│   ├── services/                  # SecureStorageService, parseurs MRZ / pièces d'identité, ML Kit
│   ├── storage/                   # hive_cache.dart (HiveCache + HiveCacheKeys), secure_storage.dart (legacy)
│   └── utils/                     # offline_first_mixin.dart, caching.dart, json_sanitizer.dart, …
└── features/
    ├── auth/          # splash, onboarding, login, inscription, scanner d'identité
    ├── offres/        # offres d'emploi, formation, externes, détail, candidature
    ├── besoin/        # nouveau besoin (souscription à un service) + mes souscriptions
    ├── rendezvous/    # agenda des RDV
    ├── reclamation/   # chat demandeur ↔ conseiller
    ├── profile/       # profil demandeur, édition, complétion, paramètres
    ├── dashboard/     # shell à onglets + accueil
    ├── dossier/       # « Mon dossier » / candidatures (mock)
    └── notification/  # notifications (mock)
```

### 2.2 Découpage d'une feature

```
features/<feature>/
├── data/
│   ├── datasources/   # *_remote_datasource.dart (Dio), *_local_datasource.dart (Hive)
│   ├── models/        # fromJson / toJson, mapping vers les entités
│   └── repositories/  # *_repository_impl.dart  ← `with OfflineFirstMixin`
├── domain/
│   ├── entities/      # objets métier purs (Equatable)
│   ├── repositories/  # contrats abstraits
│   └── usecases/      # (auth uniquement pour l'instant)
├── presentation/
│   ├── providers/     # Notifiers d'état (isLoading, isSyncing, isOffline, errorMessage…)
│   ├── screens/
│   ├── widgets/
│   └── mappers/       # (offres) entités domaine → modèles d'affichage
└── providers/<feature>_providers.dart   # câblage DI : datasource → repository
```

**Règles de dépendance** : `presentation → domain ← data`. Les repositories exposent `Future<Either<Failure, T>>` (dartz). Les dépendances sont injectées par Riverpod dans `providers/<feature>_providers.dart`.

### 2.3 Gestion d'état

- Riverpod 2 : `AsyncNotifier` (login, dashboard, dossier), `StateNotifier` (listes offres, RDV, besoins, souscriptions, profil), `Notifier` (état « déjà postulé »).
- Convention d'état des listes : `items`, `isLoading` (premier chargement), `isSyncing` (rafraîchissement silencieux en arrière-plan), `isOffline`, `errorMessage`.

---

## 3. Configuration & environnements

| Élément | Emplacement | Valeur actuelle |
|---|---|---|
| URL du Gateway | `lib/core/network/api_client.dart` → `_baseUrl` | `http://10.7.200.53:9010` (réseau interne). Préprod commentée : `https://simeanpej.ansd.sn` |
| Timeouts Dio | `ApiClient._timeout` | 15 s (connexion et réception) |
| Certificat TLS intermédiaire | `assets/certs/simeanpej-intermediate.pem` | Embarqué (voir [§5.3](#53-tls)) |
| Locale | `main.dart` | `fr` (supportées : `fr`, `en`) |
| Police | `app_theme.dart` | Gilroy **commentée** → police système ; `assets/fonts/` vide |

> ⚠️ Il n'y a pas encore de mécanisme d'environnement (`--dart-define`, flavors). Changer d'environnement = modifier `_baseUrl`. `ApiConstants.baseUrl` (`localhost`) n'est **pas** utilisé.

Build : voir le `Makefile` (`make apk`, `apk-split`, `aab`, `release`, `install`, `run`, `run-release`, `size`). Surcharges : `FLUTTER="fvm flutter"`, `DEFINES="--dart-define=…"`.

Dépendances notables retirées/commentées dans `pubspec.yaml` : `local_auth` (crash iOS simulateur via `objective_c.framework`, à réintroduire avec la biométrie), `google_mlkit_*` (OCR du scanner d'identité). `isar` / `retrofit` / `freezed` sont déclarés mais **non utilisés** dans le code actuel.

---

## 4. Démarrage de l'application (bootstrap)

`main.dart` appelle `runApp` **immédiatement** puis initialise sous un écran de marque (`_BootShell` : dégradé + « SIME » + loader) pour éviter le flash blanc :

1. `Hive.initFlutter()` + `initializeDateFormatting('fr')`.
2. Récupération/création de la **clé AES-256** Hive dans le Keychain/Keystore (`SecureStorageService.getOrCreateHiveEncryptionKey`).
3. Ouverture de la box chiffrée `sime_cache`. Si illisible (corrompue ou clé changée) → suppression et recréation (récupération défensive).
4. Chargement du certificat TLS intermédiaire éventuel.
5. Création d'un `ProviderContainer` avec overrides `hiveCacheProvider` et `extraTrustedCertificatesProvider`.
6. Pré-chargement non bloquant de `loginNotifierProvider` (restauration de session).

En cas d'échec, `_BootError` propose « Réessayer ».

---

## 5. Réseau

### 5.1 ApiClient

`apiClientProvider` → `ApiClient` (Dio) avec en-têtes JSON et intercepteurs, dans l'ordre :

| Intercepteur | Rôle |
|---|---|
| `LoggingInterceptor` (debug uniquement) | Logs requête/réponse/erreur, avec indices pour `SocketException` et `HandshakeException` |
| `TokenInterceptor` | Ajoute `Authorization: Bearer <token>` lu dans le stockage sécurisé |
| `AuthInterceptor` | Sur **401** → `loginNotifier.logout()` ; GoRouter redirige alors vers `/login` |

### 5.2 Convention des chemins

Tous les appels passent par le **Gateway** et sont **préfixés par le micro-service** : `/auth/…`, `/applicant/…`, `/param/…`, `/admin/…`, `/rdv/…`. Ces chemins sont écrits **en dur dans les datasources**.

> ⚠️ `ApiConstants` (`/api/...` sans préfixe) est **désynchronisé** du Gateway. Il n'est plus utilisé que par des datasources legacy (`anpej_service_datasource.dart`, `referential_datasource.dart`) dont les repositories ne sont branchés nulle part. Ne pas l'utiliser pour du nouveau code.

### 5.3 TLS

Le serveur `simeanpej.ansd.sn` ne renvoie pas son certificat intermédiaire : Android échoue (`CERTIFICATE_VERIFY_FAILED`), iOS complète seul la chaîne. Le certificat est embarqué dans `assets/certs/` et **ajouté** au magasin de confiance (`SecurityContext(withTrustedRoots: true)`), sans désactiver la validation TLS. Sans fichier, comportement système standard. Voir `assets/certs/README.md`.

### 5.4 Connectivité

`NetworkInfo` (`core/network/network_info.dart`) :

- `hasNetworkInterface` — Wi-Fi/mobile actif (`connectivity_plus`).
- `hasInternetAccess` — résolution DNS de `one.one.one.one` (timeout 3 s).
- `isConnected` — les deux.

`connectivityStreamProvider` (`StreamProvider<bool>`) émet l'état **immédiatement** puis à chaque changement d'interface (avec re-vérification DNS). C'est la source unique de l'état en ligne/hors ligne pour l'UI et les déclencheurs de synchronisation.

### 5.5 Erreurs

`OfflineFirstMixin._mapDioError` convertit les `DioException` en `Failure` (`core/error/failures.dart`) :

| Cas | Failure |
|---|---|
| 400 | `ValidationFailure` (message métier extrait) |
| 401 / 403 | `AuthFailure` |
| 404 | `NotFoundFailure` |
| ≥ 500 | `ServerFailure` |
| timeouts / connexion | `NetworkFailure` |
| autre | `UnknownFailure` |

Le Gateway enveloppe les erreurs des micro-services : le vrai message est souvent dans `debugMessage` sous la forme `400 : "{...json...}"`. `_extractServerMessage` le décode récursivement et ignore les messages génériques (« Error occurred », `BAD_REQUEST`…).

---

## 6. Stockage local & sécurité

| Stockage | Contenu | Chiffré |
|---|---|---|
| `flutter_secure_storage` (`SecureStorageService`) | JWT (`auth_token`), `auth_response`, « se souvenir de moi » + identifiant, **clé Hive** (`hive_crypto_secret_key`) | ✅ Keychain/Keystore |
| Box Hive `sime_cache` (`HiveCache`) | Cache JSON de toutes les lectures offline-first + session (`secure_auth_user_session`) + offres postulées (`applied_offers`) | ✅ AES-256 |
| Box `applicant_box` / `applicant_sync_box` | Profil demandeur / file des modifications de profil hors ligne | ❌ |
| Box `reclamation_outbox_box` / `reclamation_local_msgs_box` | File d'envoi des réclamations / messages sortants du demandeur | ❌ |
| `SharedPreferences` | `is_first_launch` (onboarding) | ❌ |

### Clés de cache (`HiveCacheKeys`, `core/storage/hive_cache.dart`)

| Clé | Ressource |
|---|---|
| `applicant_me` (+ `applicant_me_profile` utilisée par le profil) | Profil demandeur |
| `subscriptions_me` | Mes souscriptions |
| `rdvs_me` | Rendez-vous |
| `claim_requests_me` | Réclamations |
| `job_offers`, `job_offer_<id>` | Offres d'emploi (liste / détail) |
| `training_offers`, `training_offer_<id>` | Offres de formation |
| `external_offers` | Offres externes |
| `type_services_possible`, `partner_services_possible_<typeId>`, `services_possible_<partnerId>_<typeId>` | Parcours « Nouveau besoin » |
| `services`, `services_for_me`, `countries`, `regions`, `departments_<id>`, `municipalities_<id>`, `education_levels`, `degrees` | Référentiels (legacy) |

> Toute nouvelle ressource mise en cache doit avoir sa constante dans `HiveCacheKeys` **et** une ligne dans ce tableau.

`core/storage/secure_storage.dart` (SharedPreferences) est **legacy** et non branché.

---

## 7. Stratégie offline-first & synchronisation

### 7.1 `OfflineFirstMixin` (`core/utils/offline_first_mixin.dart`)

Tout repository concret fait `with OfflineFirstMixin` et expose `networkInfo` + `cache`.

- **`offlineFirst<T>(cacheKey, remoteCall, fromCache, toJson?)`** — lectures :
  1. En ligne → API → écrit le JSON en cache → `Right(data)`.
  2. En ligne mais erreur Dio → **repli sur le cache** s'il existe, sinon `Left(failure)`.
  3. Hors ligne → cache → `Right(data)` ; cache absent → `Left(CacheFailure)`.
- **`remoteOnly<T>(remoteCall)`** — mutations : hors ligne → `Left(NetworkFailure('Vous êtes hors ligne'))` immédiat.
- **`invalidate(key)` / `invalidateAll(keys)`** — après une mutation réussie.

### 7.2 Mutations hors ligne (files d'attente)

| Feature | Stratégie | Rejeu |
|---|---|---|
| Profil | `saveOfflineUpdate` fusionne les champs dans `applicant_sync_box` **et** met à jour le profil local immédiatement (UI optimiste). Aussi utilisé si l'appel échoue en ligne. Les payloads sont passés par `sanitizeForTransport` (types JSON-safe pour Hive). | `ApplicantNotifier.synchronizeOfflineData()` à chaque émission « en ligne » de `connectivityStreamProvider` ; expose `isSyncing` |
| Réclamations | Nouvelle réclamation / réponse → `reclamation_outbox_box`, affichée en tête avec l'accusé « en attente » (`pendingClaims`) | `ReclamationsNotifier` → `repository.synchronizeOfflineData()` au retour réseau |
| Offres — candidature emploi | `remoteOnly` (en ligne requis) | — |
| Offres — formation / externes | Candidature **optimiste locale** uniquement (pas d'endpoint) | — |
| Besoins (création / modification / suppression) | `remoteOnly` (en ligne requis) | — |

### 7.3 Rafraîchissement au retour du réseau

Les notifiers de liste écoutent `connectivityStreamProvider` et, **uniquement sur une vraie transition hors ligne → en ligne** (`wasConnected == false && isConnected == true`, pas à l'émission initiale), relancent un chargement silencieux (`silent: true` → `isSyncing`) : offres emploi/formation/externes, RDV, souscriptions, catégories du parcours besoin.

### 7.4 Ajouter une ressource offline-first (checklist)

1. Constante dans `HiveCacheKeys`.
2. Datasource distante (chemin Gateway préfixé, en dur).
3. Repository `with OfflineFirstMixin` : `offlineFirst` pour les lectures, `remoteOnly` ou file Hive pour les écritures.
4. Notifier avec `isLoading` / `isSyncing` / `isOffline` + `ref.listen(connectivityStreamProvider)` (transition réelle uniquement).
5. UI : skeleton au premier chargement, bandeau hors ligne / synchronisation, état vide.
6. Mettre à jour ce document ([§6](#6-stockage-local--sécurité), [§10](#10-features), [§11](#11-référence-des-endpoints), [§14](#14-journal-des-modifications)).

---

## 8. Navigation & authentification

### 8.1 Routes (`core/const/app_routes.dart`, `core/router/app_router.dart`)

| Route | Écran | Notes |
|---|---|---|
| `/` | `SplashScreen` | Attend `authCheckProvider` puis oriente |
| `/onboarding` | `OnboardingScreen` | Public (non déclaré dans `AppRoutes`) |
| `/login` | `LoginScreen` | Public |
| `/register` | `InscriptionScreen` | Public, 3 étapes |
| `/dashboard` | `DashboardScreen` | `extra: int` = onglet initial |
| `/offres`, `/offres/details` | `OffresScreen`, `OffreDetailScreen` | Détail : `extra: String` (id composite `job:4`, `training:2`, `external:7`) |
| `/agenda` | `RendezVousScreen` | (`AppRoutes.rendezvous` déclaré mais non routé) |
| `/dossier` | `MonDossierScreen` | |
| `/reclamations`, `/reclamations/chat` | `ReclamationsScreen`, `ReclamationChatScreen` | Chat : `extra: int` = claimId |
| `/besoin/nouveau` | `NouveauBesoinScreen` (plein écran) | `extra: MySubscriptionEntity` → mode modification |
| `/profil`, `/profil/parametres` | `ProfileScreen`, `ParametresScreen` | |
| `/profil/edit-personal`, `edit-identity`, `edit-situation`, `edit-identity-document`, `edit-professional` | Écrans d'édition (plein écran) | |
| `/notification` | `NotificationsScreen` (plein écran) | |

### 8.2 Garde d'authentification

- `routerProvider` crée **une seule** instance de `GoRouter` ; `RouterNotifier` (ChangeNotifier) écoute `isAuthenticatedProvider` et sert de `refreshListenable` → `redirect()` est réévalué sans recréer le routeur.
- Non authentifié sur une route non publique → `/login`. Authentifié sur `/login` ou `/register` → `/dashboard`.

### 8.3 Session

- **Login** (`LoginNotifier.login`) : `POST /auth/api/auth/login` → token dans le stockage sécurisé, préférence « se souvenir de moi », session JSON dans `sime_cache`, puis pré-chargement du profil demandeur (pour disponibilité hors ligne).
- **Restauration** au démarrage : token + session en cache → session restaurée **sans réseau**, profil rafraîchi en tâche de fond.
- **Logout** : `secureStorage.clearAll()` (conserve uniquement « se souvenir de moi »), suppression de la session Hive. ⚠️ voir [§13](#13-points-ouverts--dette-technique).

---

## 9. Design system & UX de connectivité

### 9.1 Tokens (`core/design_system/tokens/`)

Charte ANPEJ dans `AppColors` : vert `primary400 #80C241`, marron `secondary600 #735618`, jaune `accent500 #FAA634`, bleu `bleuANPEJ #2195D2`, violet `violetANPEJ #9C1D76`, neutres `neutral50…800`. Typographie `AppTextStyles`, espacements `AppDimensions`, thème `AppTheme.light`.

### 9.2 Composants principaux (`core/design_system/widgets/`)

`SAppBar`, `MainScaffold`, `SButton`, `SLinkButton`, `SCard`, `SSection`, `STag`, `SStatusBadge`, `SSearchableDropdown` (liste déroulante avec recherche), `SShimmer` (skeletons), `SOverlayLoader`, `AppStatusDialog`, `EmptyState`, `SExpandableText`, `SGenreTile`, `ScanOverlay`, `app_form_fields.dart`.

### 9.3 Indicateurs de connectivité et de synchronisation

| Où | Comportement |
|---|---|
| `SAppBar` (shell du dashboard — donc les 5 onglets — et Nouveau besoin) | Fond et bordure basse qui virent au jaune hors ligne (`AnimatedContainer` 350 ms) ; pastille « En ligne » (point fixe vert) / « Hors ligne » (point pulsé jaune) avec transition en fondu |
| Offres | Bandeau animé : hors ligne ou « synchronisation » quand un des trois flux est `isSyncing` |
| Agenda | `_SyncingPill` pendant le rafraîchissement silencieux |
| Nouveau besoin | Bandeau non bloquant hors ligne / erreur |
| Profil | État hors ligne + `isSyncing` pendant le rejeu des modifications |
| Chat réclamation | Accusés par message : envoyé / en attente / échec (+ réessayer) |

> Objectif produit (instructions projet) : généraliser un indicateur de **synchronisation** dans l'AppBar (aujourd'hui l'AppBar n'affiche que en ligne/hors ligne ; l'état « synchronisation » est géré écran par écran).

---

## 10. Features

### 10.1 Auth (`features/auth`)

- **Splash** → `authCheckProvider` → onboarding, login ou dashboard (`firstLaunchProvider` mémorise le premier lancement).
- **Inscription** en 3 étapes : *Informations*, *Documents*, *Compte* (`registration_provider.dart`, `step_*_form.dart`). Envoi : `POST /applicant/api/applicants/register` (la création séparée du compte `POST /auth/api/auth/register` est commentée dans `AuthRepositoryImpl`).
- Référentiels des formulaires (`reference_remote_datasource.dart`) : bureaux, pays, régions, départements, communes, nationalités, niveaux d'études, filières, secteurs d'activité, types de handicap, situations matrimoniales.
- **Scanner d'identité** (`identity_scanner_screen.dart`, parseurs MRZ/pièces africaines) : ML Kit désactivé et route non enregistrée (voir [§13](#13-points-ouverts--dette-technique)).

### 10.2 Offres (`features/offres`)

- Trois flux : **emploi**, **formation**, **externes** (chip « Externes », `OffreType.externe`), chacun avec son datasource/repository/notifier, fusionnés via `offre_presentation_mapper.dart` en `OffreEntity`.
- Ids composites `job:<id>`, `training:<id>`, `external:<id>`.
- **Candidature emploi** : `POST /applicant/api/job-offer-applicants/me` avec `{"applicant":{"id":…},"jobOffer":{"id":…}}` ; `applicantId` lu dans `loginNotifierProvider → authResponse.user.applicantId`. SnackBar en cas d'erreur.
- **État « déjà postulé »** : `appliedOffersProvider` (Set d'ids composites persisté sous `applied_offers`). Le serveur ne fournit pas ce drapeau : ce miroir local fait foi. La carte affiche le tag « Déjà postulé » ; toute la carte ouvre le détail.
- Offres **externes** : forme du payload non confirmée — `_extractOffer` lit défensivement `jobLinkingOffer` → `jobOffer` → `offer` → l'objet lui-même. Pas d'endpoint de détail : le détail vient de la liste en mémoire (échoue sur un deep-link à froid).
- Favoris (`toggleSave`) : placeholder local, pas d'endpoint.

### 10.3 Besoin (`features/besoin`)

- Parcours en cascade : **catégorie** (`type-services`) → **structure partenaire** (`partner-services`) → **sous-service** (`services`), + « idée de projet ». Chaque niveau est en cache par identifiant.
- **Mes souscriptions** : liste, création, modification (`PUT`), suppression (`DELETE`) ; carte de progression du dossier, feuille d'actions, badge de statut.
- Écritures en ligne uniquement.

### 10.4 Rendez-vous (`features/rendezvous`)

Lecture seule : `GET /rdv/api/rdvs/me` (enveloppe `{data:[…]}`), cache `rdvs_me`, statuts via `RdvStatusBadge`. Le prochain RDV de l'accueil vient du même `rdvNotifierProvider`.

### 10.5 Réclamations (`features/reclamation`)

- Entrée : carte « Réclamations » de l'accueil → liste → chat.
- Modèle : chaque réclamation a un `message` d'ouverture (demandeur) + `claimResponse[]`. Une réponse est attribuée au **conseiller** par défaut, sauf marqueur explicite `byApplicant == true` / `applicant != null`.
- Le serveur ne renvoie pas les réponses du demandeur : elles sont conservées dans `reclamation_local_msgs_box`, qui fait foi pour leur affichage et leur accusé.
- Pas de date dans l'API : tri par `id` décroissant, pas d'horodatage sur les bulles.
- Statut dérivé : `active == false` → Clôturée ; sans réponse → En attente ; sinon → Répondu.

### 10.6 Profil (`features/profile`)

- Consultation (`GET /applicant/api/applicants/me`), édition par sections (`PATCH /applicant/api/applicants/me/{id}`) : compte, identité, situation personnelle, pièce d'identité, profil professionnel. Mise à jour du compte : `PUT /auth/api/auth/me`.
- **Complétion du profil** (`profile_completion.dart`) : sections pondérées (le bureau affilié pèse plus lourd), pourcentage et feuille « champs manquants ».
- Paramètres (`parametres_screen.dart`).

### 10.7 Dashboard, Dossier, Notifications

- `DashboardScreen` : 5 onglets (Accueil, Offres, Agenda, Candidatures, Profil) via `SimeBottomNav`.
- **Accueil** : dossier et offres recommandées **mockés** (`dashboard_provider.dart`) ; prochain RDV réel.
- **Mon dossier** (onglets statut / candidatures / historique) : **mock** (`dossier_detail_provider.dart`).
- **Notifications** : modèle temporaire local, pas d'API.

---

## 11. Référence des endpoints

Base : `_baseUrl` du Gateway. ✅ confirmé · ❓ présumé · 🗄️ legacy non branché.

| Méthode | Chemin | Usage | Datasource | |
|---|---|---|---|---|
| POST | `/auth/api/auth/login` | Connexion | `auth_remote_datasource` | ✅ |
| POST | `/auth/api/auth/register` | Création du compte (appel commenté) | `auth_remote_datasource` | ✅ |
| PUT | `/auth/api/auth/me` | Mise à jour du compte | `auth_remote_datasource` | ✅ |
| POST | `/applicant/api/applicants/register` | Inscription demandeur | `auth_remote_datasource` | ✅ |
| GET | `/applicant/api/applicants/me` | Profil demandeur | `applicant_remote_datasource` | ✅ |
| PATCH | `/applicant/api/applicants/me/{id}` | Édition du profil | `applicant_remote_datasource` | ✅ |
| GET | `/applicant/api/job-offers/available?page&size&pageable=true` | Offres d'emploi | `job_offer_datasource` | ✅ |
| GET | `/applicant/api/job-offers/{id}/available` | Détail offre d'emploi | `job_offer_datasource` | ✅ |
| POST | `/applicant/api/job-offer-applicants/me` | Candidater | `job_offer_datasource` | ✅ |
| GET | `/applicant/api/training-offers/available` | Offres de formation | `training_offer_datasource` | ❓ forme calquée sur l'emploi |
| GET | `/applicant/api/training-offers/{id}/available` | Détail formation | `training_offer_datasource` | ❓ |
| GET | `/applicant/api/job-linking-offer-applicants/me?page&size&pageable=true` | Offres externes | `external_offer_datasource` | ✅ chemin / ❓ payload |
| GET | `/applicant/api/type-services/possible-for-me` | Catégories de service | `besoin_remote_datasource` | ✅ |
| GET | `/applicant/api/partner-services/possible-for-me` | Structures partenaires | `besoin_remote_datasource` | ✅ |
| GET | `/applicant/api/services/possible-for-me` | Sous-services | `besoin_remote_datasource` | ✅ |
| GET / POST | `/applicant/api/subscriptions/me` | Lister / créer une souscription | `besoin_remote_datasource` | ✅ |
| PUT / DELETE | `/applicant/api/subscriptions/me/{id}` | Modifier / supprimer | `besoin_remote_datasource` | ✅ |
| GET / POST | `/applicant/api/claim-request-applicants/me` | Lister / créer une réclamation (`{message, applicantId}`) | `reclamation_remote_datasource` | ✅ |
| POST | `/applicant/api/claim-request-applicants/me/{claimId}/responses` | Répondre dans un fil | `reclamation_remote_datasource` | ❓ |
| GET | `/rdv/api/rdvs/me` | Mes rendez-vous | `rdv_datasource` | ✅ |
| GET | `/admin/api/offices` | Bureaux ANPEJ | `reference_remote_datasource` | ✅ |
| GET | `/param/api/{countries, regions, departments, municipalities, nationalities, education-levels, field-studies, field-activities, disability-types, marital-statuses}` | Référentiels | `reference_remote_datasource` | ✅ |
| GET | `ApiConstants.*` (`/api/services`, `/api/countries`, …) | Référentiels / services | `anpej_service_datasource`, `referential_datasource` | 🗄️ |

---

## 12. Maintenir cette documentation

**Règle : toute modification du projet met à jour `doc.md` dans le même commit.** Le README n'est modifié que si la vue d'ensemble change (stack, tableau des fonctionnalités, démarrage, structure).

| Si la modification… | Mettre à jour |
|---|---|
| ajoute/modifie une feature ou un écran | §10, tableau du README |
| ajoute/modifie un endpoint | §11 (+ statut ✅/❓) |
| ajoute une clé de cache ou une box Hive | §6 |
| change la stratégie offline / sync | §7, §9.3 |
| ajoute/modifie une route | §8.1 |
| change la config, l'URL, les dépendances, le build | §3, README › Stack/Démarrage |
| résout ou crée un point ouvert | §13 |
| **toujours** | §14 (une ligne datée) + date en tête de fichier |

Les agents IA (Claude, Codex, Cursor…) reçoivent cette consigne via `AGENTS.md` et `CLAUDE.md` à la racine.

---

## 13. Points ouverts & dette technique

**Sécurité / données**
- Au logout, `secureStorage.clearAll()` supprime aussi la **clé de chiffrement Hive** : au lancement suivant, `sime_cache` est illisible et recréée (cache purgé de fait). Comportement à confirmer comme voulu, ou à rendre explicite (`HiveCache.clearAll()` + conserver la clé).
- Les boxes `applicant_box`, `applicant_sync_box`, `reclamation_outbox_box`, `reclamation_local_msgs_box` ne sont **ni chiffrées ni purgées au logout** : données et file d'attente d'un utilisateur peuvent survivre à un changement de compte (et être rejouées avec le token du suivant).
- URL de base en `http://` sur une IP interne ; prévoir environnements (`--dart-define` / flavors) et HTTPS.
- Biométrie et certificate pinning non implémentés.

**Fonctionnel**
- Dashboard (dossier, offres recommandées), Mon dossier et Notifications sont **mockés**.
- Endpoint de réponse aux réclamations présumé ; pas de date dans l'API (pas d'horodatage) ; possibles doublons de messages « échec » lors des réessais.
- Offres externes : payload à confirmer, pas de détail ni de candidature serveur ; offres de formation : forme présumée, candidature locale uniquement ; favoris sans endpoint.
- Création/modification de besoins impossible hors ligne (pas de file d'attente).
- `AppRoutes.identityScanner` est utilisé par `step_one_form.dart` mais **la route n'est pas enregistrée** dans `app_router.dart` → navigation en échec ; ML Kit désactivé.
- Indicateur global de synchronisation dans l'AppBar à généraliser (§9.3).

**Code**
- `ApiConstants`, `core/storage/secure_storage.dart`, `core/error/failure.dart`, `anpej_service_datasource` / `referential_datasource` et leurs repositories : legacy, à supprimer ou réaligner.
- Clé `applicant_me_profile` codée en dur dans `ApplicantRepositoryImpl` (hors `HiveCacheKeys`).
- `isar`, `retrofit`, `freezed` déclarés mais inutilisés ; police Gilroy non embarquée.
- Couverture de tests faible (3 fichiers unitaires, `test/widget/` vide) ; `flutter analyze` à exécuter en CI.

---

## 14. Journal des modifications

Format : `AAAA-MM-JJ — [zone] résumé`. Ajouter les entrées les plus récentes en haut.

- 2026-09-30 — [docs] Réécriture du README (état réel) et création de `doc.md` ; règle de mise à jour de la doc ajoutée à `AGENTS.md` / `CLAUDE.md`.
- 2026-07 → 2026-09 — *(travail en grande partie non encore commité sur `profile-completion` ; dernier commit : 2026-07-17)*
  - [profile] Complétion du profil pondérée, écrans d'édition par section, « se souvenir de moi », sanitisation des payloads avant cache Hive.
  - [reclamation] Feature chat demandeur ↔ conseiller offline-first (outbox + messages locaux).
  - [offres] Branchement API réel : emploi, formation, externes, candidature, état « déjà postulé ».
  - [core] Offline-first (`OfflineFirstMixin`, Hive chiffré), `SAppBar` avec indicateur de connectivité animé, `SSearchableDropdown`, correctifs `connectivityStreamProvider` / `RouterNotifier`, correctif de contamination du cache `ReferenceEntity`, certificat TLS intermédiaire, bootstrap sans flash blanc.
- 2026-07-10 — [core] Début de la stratégie offline-first.
- 2026-07-03 — [design] Personnalisation du design system (charte ANPEJ) + initialisation des endpoints.

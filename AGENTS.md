## Imported Claude Cowork project instructions

The goal is to build a modern, user-friendly, and high-performance application based on Clean Architecture principles with an Offline-First approach.

The application should deliver a smooth, responsive, and intuitive user experience, enhanced with polished UI elements and elegant animations that make every interaction feel seamless.

It must remain fully functional even without an internet connection. Users should be able to continue working offline, with all data stored locally and automatically synchronized with the server once connectivity is restored.

Offline and online states should be clearly communicated through the user interface, allowing users to easily understand the application's current connectivity status. During synchronization, the app should provide visually appealing feedback—such as subtle animations in the AppBar, status indicators, or dedicated sync components—so users always know when data is being uploaded or synchronized.

Overall, the application should feel fast, reliable, and polished, providing a premium user experience regardless of network conditions.

## Documentation — règle obligatoire

La documentation du projet vit dans deux fichiers à la racine :

- `README.md` — vue d'ensemble concise (stack, tableau des fonctionnalités, démarrage, structure).
- `doc.md` — documentation technique détaillée (architecture, offline-first, cache, routes, endpoints, points ouverts, journal).

**À chaque modification du projet (feature, écran, endpoint, clé de cache/box Hive, route, dépendance, configuration, correctif notable), mettre à jour `doc.md` dans la même tâche / le même commit, sans attendre qu'on le demande :**

1. Mettre à jour les sections concernées (voir le tableau « Maintenir cette documentation », §12 de `doc.md`).
2. Ajouter une ligne datée en haut du « Journal des modifications » (§14) et mettre à jour la date « Dernière mise à jour » en tête du fichier.
3. Déplacer/retirer les éléments résolus de « Points ouverts & dette technique » (§13) et y ajouter tout nouveau point connu (endpoint présumé, mock, TODO).
4. Mettre à jour `README.md` seulement si la vue d'ensemble change.
5. Ne documenter que ce qui est réellement dans le code (vérifier chemins, noms de classes et endpoints avant d'écrire).
